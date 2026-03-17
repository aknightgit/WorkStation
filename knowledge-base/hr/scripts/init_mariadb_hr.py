#!/usr/bin/env python3
"""Initialize HumanResource schema in MariaDB."""

from __future__ import annotations

import argparse
from pathlib import Path
import pymysql

ROOT = Path(__file__).resolve().parents[1]
SCHEMA_PATH = ROOT / "sql" / "talent_schema_mariadb.sql"


def parse_sql_statements(sql_text: str):
    statements = []
    buf = []
    for line in sql_text.splitlines():
        line_strip = line.strip()
        if not line_strip or line_strip.startswith("--"):
            continue
        buf.append(line)
        if line_strip.endswith(";"):
            stmt = "\n".join(buf).strip()
            if stmt:
                statements.append(stmt)
            buf = []
    if buf:
        stmt = "\n".join(buf).strip()
        if stmt:
            statements.append(stmt)
    return statements


def main() -> None:
    parser = argparse.ArgumentParser(description="Init HumanResource DB in MariaDB")
    parser.add_argument("--host", required=True)
    parser.add_argument("--port", type=int, default=3306)
    parser.add_argument("--user", required=True)
    parser.add_argument("--password", required=True)
    parser.add_argument("--database", default="HumanResource")
    args = parser.parse_args()

    sql_text = SCHEMA_PATH.read_text(encoding="utf-8")
    # allow overriding DB name on CLI
    sql_text = sql_text.replace("`HumanResource`", f"`{args.database}`")
    statements = parse_sql_statements(sql_text)

    conn = pymysql.connect(
        host=args.host,
        port=args.port,
        user=args.user,
        password=args.password,
        charset="utf8mb4",
        autocommit=True,
    )

    try:
        with conn.cursor() as cur:
            for stmt in statements:
                cur.execute(stmt)

            cur.execute("SELECT DATABASE()")
            current_db = cur.fetchone()[0]

            cur.execute(
                "SELECT table_name FROM information_schema.tables WHERE table_schema=%s ORDER BY table_name",
                (args.database,),
            )
            tables = [r[0] for r in cur.fetchall()]

        print(f"[ok] initialized MariaDB database: {args.database}")
        print(f"[ok] current database: {current_db}")
        print(f"[ok] tables({len(tables)}): {', '.join(tables)}")
    finally:
        conn.close()


if __name__ == "__main__":
    main()
