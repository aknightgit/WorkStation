#!/usr/bin/env python3
"""
HR platform bootstrap + local vector retrieval.

能力：
1) 初始化人才池/知识库/人才地图基础目录 + SQLite结构化库
2) 初始化本地 Chroma 向量库 collections
3) 导入文档到向量库（md/txt/csv/json）
4) 语义检索
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import math
import os
import re
import sqlite3
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, List, Dict

import chromadb


ROOT = Path(__file__).resolve().parents[1]
DB_PATH = ROOT / "hr_core.db"
CHROMA_PATH = ROOT / "chroma_db"
SCHEMA_SQL = ROOT / "sql" / "talent_schema.sql"

DEFAULT_COLLECTIONS = [
    "talent_profiles",
    "enterprise_kb",
    "talent_map",
]

SUPPORTED_EXT = {".md", ".txt", ".csv", ".json", ".yml", ".yaml"}


@dataclass
class Chunk:
    chunk_id: str
    text: str
    metadata: Dict


class LocalHashEmbeddingFunction:
    """离线可用：基于 token hashing 的轻量 embedding。"""

    def __init__(self, dim: int = 384):
        self.dim = dim
        self.token_re = re.compile(r"[A-Za-z0-9_]+|[\u4e00-\u9fff]")

    def _tokens(self, text: str) -> List[str]:
        return self.token_re.findall(text.lower())

    def _hash_to_index_sign(self, token: str):
        digest = hashlib.blake2b(token.encode("utf-8"), digest_size=16).digest()
        idx = int.from_bytes(digest[:8], "little") % self.dim
        sign = 1.0 if (digest[8] & 1) == 0 else -1.0
        return idx, sign

    def __call__(self, input: List[str]) -> List[List[float]]:
        vectors: List[List[float]] = []
        for text in input:
            vec = [0.0] * self.dim
            for token in self._tokens(text):
                idx, sign = self._hash_to_index_sign(token)
                vec[idx] += sign
            norm = math.sqrt(sum(v * v for v in vec))
            if norm > 0:
                vec = [v / norm for v in vec]
            vectors.append(vec)
        return vectors


def ensure_dirs() -> None:
    (ROOT / "人才资料" / "候选人简历").mkdir(parents=True, exist_ok=True)
    (ROOT / "人才资料" / "员工档案").mkdir(parents=True, exist_ok=True)
    (ROOT / "人才资料" / "面试评估").mkdir(parents=True, exist_ok=True)

    (ROOT / "企业流程" / "入职流程").mkdir(parents=True, exist_ok=True)
    (ROOT / "企业流程" / "离职流程").mkdir(parents=True, exist_ok=True)
    (ROOT / "企业流程" / "晋升流程").mkdir(parents=True, exist_ok=True)
    (ROOT / "企业流程" / "调薪流程").mkdir(parents=True, exist_ok=True)

    (ROOT / "招聘管理" / "职位描述").mkdir(parents=True, exist_ok=True)
    (ROOT / "招聘管理" / "招聘渠道").mkdir(parents=True, exist_ok=True)
    (ROOT / "招聘管理" / "面试题库").mkdir(parents=True, exist_ok=True)

    (ROOT / "员工手册" / "公司简介").mkdir(parents=True, exist_ok=True)
    (ROOT / "员工手册" / "行为准则").mkdir(parents=True, exist_ok=True)
    (ROOT / "员工手册" / "福利政策").mkdir(parents=True, exist_ok=True)

    (ROOT / "制度规范" / "考勤制度").mkdir(parents=True, exist_ok=True)
    (ROOT / "制度规范" / "绩效考核").mkdir(parents=True, exist_ok=True)
    (ROOT / "制度规范" / "奖惩条例").mkdir(parents=True, exist_ok=True)

    (ROOT / "templates").mkdir(parents=True, exist_ok=True)
    (ROOT / "scripts").mkdir(parents=True, exist_ok=True)
    (ROOT / "sql").mkdir(parents=True, exist_ok=True)
    CHROMA_PATH.mkdir(parents=True, exist_ok=True)


def init_sqlite() -> None:
    conn = sqlite3.connect(DB_PATH)
    with SCHEMA_SQL.open("r", encoding="utf-8") as f:
        conn.executescript(f.read())
    conn.commit()
    conn.close()


def get_client() -> chromadb.PersistentClient:
    return chromadb.PersistentClient(path=str(CHROMA_PATH))


def init_collections(collections: Iterable[str]) -> None:
    client = get_client()
    for name in collections:
        client.get_or_create_collection(name=name)


def _read_file(path: Path) -> str:
    ext = path.suffix.lower()
    if ext in {".md", ".txt", ".yml", ".yaml"}:
        return path.read_text(encoding="utf-8", errors="ignore")
    if ext == ".json":
        data = json.loads(path.read_text(encoding="utf-8", errors="ignore"))
        return json.dumps(data, ensure_ascii=False, indent=2)
    if ext == ".csv":
        rows = []
        with path.open("r", encoding="utf-8", errors="ignore") as f:
            reader = csv.DictReader(f)
            for row in reader:
                rows.append(" | ".join(f"{k}:{v}" for k, v in row.items()))
        return "\n".join(rows)
    return ""


def _chunk_text(text: str, chunk_size: int = 800, overlap: int = 120) -> List[str]:
    text = re.sub(r"\s+", " ", text).strip()
    if not text:
        return []
    chunks = []
    start = 0
    while start < len(text):
        end = min(len(text), start + chunk_size)
        chunks.append(text[start:end])
        if end == len(text):
            break
        start = max(0, end - overlap)
    return chunks


def build_chunks(source: Path, category: str, chunk_size: int, overlap: int) -> List[Chunk]:
    source = source.resolve()
    files: List[Path] = []
    if source.is_file():
        files = [source]
    else:
        files = [p for p in source.rglob("*") if p.is_file() and p.suffix.lower() in SUPPORTED_EXT]

    out: List[Chunk] = []
    for f in files:
        content = _read_file(f)
        if not content.strip():
            continue
        rel = f.relative_to(ROOT).as_posix() if str(f).startswith(str(ROOT)) else f.name
        pieces = _chunk_text(content, chunk_size=chunk_size, overlap=overlap)
        for i, piece in enumerate(pieces):
            cid = hashlib.sha1(f"{rel}::{i}::{piece[:50]}".encode("utf-8")).hexdigest()
            out.append(
                Chunk(
                    chunk_id=cid,
                    text=piece,
                    metadata={
                        "source": rel,
                        "category": category,
                        "chunk_index": i,
                    },
                )
            )
    return out


def ingest(source: Path, collection_name: str, category: str, chunk_size: int, overlap: int, batch: int = 100) -> int:
    chunks = build_chunks(source=source, category=category, chunk_size=chunk_size, overlap=overlap)
    if not chunks:
        return 0

    client = get_client()
    emb = LocalHashEmbeddingFunction()
    collection = client.get_or_create_collection(name=collection_name)

    total = 0
    for i in range(0, len(chunks), batch):
        group = chunks[i : i + batch]
        docs = [c.text for c in group]
        collection.upsert(
            ids=[c.chunk_id for c in group],
            documents=docs,
            embeddings=emb(docs),
            metadatas=[c.metadata for c in group],
        )
        total += len(group)
    return total


def search(collection_name: str, query: str, top_k: int, category: str | None = None):
    client = get_client()
    emb = LocalHashEmbeddingFunction()
    collection = client.get_or_create_collection(name=collection_name)
    where = {"category": category} if category else None
    q = emb([query])[0]
    result = collection.query(query_embeddings=[q], n_results=top_k, where=where)
    return result


def write_templates() -> None:
    people_csv = ROOT / "templates" / "talent_people_template.csv"
    if not people_csv.exists():
        people_csv.write_text(
            "person_id,full_name,person_type,title,department,level,location,phone,email,source_channel,status\n"
            "p001,张三,candidate,数据工程师,数据平台,P6,上海,13800000000,zhangsan@example.com,内推,active\n",
            encoding="utf-8",
        )

    skills_csv = ROOT / "templates" / "talent_skills_template.csv"
    if not skills_csv.exists():
        skills_csv.write_text(
            "person_id,skill_name,skill_category,proficiency,years_experience,evidence\n"
            "p001,Python,技术,4,5,数据平台项目\n",
            encoding="utf-8",
        )

    map_csv = ROOT / "templates" / "talent_map_edges_template.csv"
    if not map_csv.exists():
        map_csv.write_text(
            "from_node_id,to_node_id,relation_type,weight\n"
            "team_data,role_bi_engineer,owns_role,1\n",
            encoding="utf-8",
        )


def cmd_init(_: argparse.Namespace) -> None:
    ensure_dirs()
    init_sqlite()
    init_collections(DEFAULT_COLLECTIONS)
    write_templates()
    print(f"[ok] initialized dirs + sqlite + chroma at {ROOT}")


def cmd_ingest(args: argparse.Namespace) -> None:
    source = Path(args.source)
    if not source.exists():
        raise SystemExit(f"source not found: {source}")
    total = ingest(
        source=source,
        collection_name=args.collection,
        category=args.category,
        chunk_size=args.chunk_size,
        overlap=args.overlap,
    )
    print(f"[ok] upserted {total} chunks into collection '{args.collection}'")


def cmd_search(args: argparse.Namespace) -> None:
    result = search(
        collection_name=args.collection,
        query=args.query,
        top_k=args.top_k,
        category=args.category,
    )

    docs = result.get("documents", [[]])[0]
    metas = result.get("metadatas", [[]])[0]
    dists = result.get("distances", [[]])[0]

    print(json.dumps({
        "collection": args.collection,
        "query": args.query,
        "hits": [
            {
                "distance": dists[i] if i < len(dists) else None,
                "metadata": metas[i] if i < len(metas) else {},
                "preview": docs[i][:220] + ("..." if len(docs[i]) > 220 else ""),
            }
            for i in range(len(docs))
        ],
    }, ensure_ascii=False, indent=2))


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="HR talent+knowledge vector platform")
    sub = parser.add_subparsers(required=True)

    p_init = sub.add_parser("init", help="initialize base infrastructure")
    p_init.set_defaults(func=cmd_init)

    p_ingest = sub.add_parser("ingest", help="ingest docs into vector collection")
    p_ingest.add_argument("--source", required=True, help="file or directory")
    p_ingest.add_argument("--collection", required=True, choices=DEFAULT_COLLECTIONS)
    p_ingest.add_argument("--category", default="general", help="metadata category")
    p_ingest.add_argument("--chunk-size", type=int, default=800)
    p_ingest.add_argument("--overlap", type=int, default=120)
    p_ingest.set_defaults(func=cmd_ingest)

    p_search = sub.add_parser("search", help="semantic retrieval")
    p_search.add_argument("--collection", required=True, choices=DEFAULT_COLLECTIONS)
    p_search.add_argument("--query", required=True)
    p_search.add_argument("--top-k", type=int, default=5)
    p_search.add_argument("--category", default=None)
    p_search.set_defaults(func=cmd_search)

    return parser


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
