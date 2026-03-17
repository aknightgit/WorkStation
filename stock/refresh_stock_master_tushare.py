#!/usr/bin/env python3
"""刷新股票基础信息到 stocks_tushare。"""

from __future__ import annotations

from datetime import datetime
import pymysql
import tushare as ts
import akshare as ak

TOKEN = "805ef9262c76ad3bf00bb8871a05942973a20c0afe83972a39543e6f"

DB_CONFIG = {
    "host": "192.168.3.241",
    "port": 33061,
    "user": "root",
    "password": "root",
    "database": "openclaw",
    "charset": "utf8mb4",
    "autocommit": False,
}


def clean(v):
    # 兼容 pandas NaN
    if v is None:
        return None
    if isinstance(v, float) and str(v) == "nan":
        return None
    s = str(v).strip()
    if s.lower() == "nan" or s == "":
        return None
    return v


def normalize_date(value: str):
    value = clean(value)
    if value is None:
        return None
    value = str(value).strip()
    if len(value) == 8 and value.isdigit():
        return f"{value[0:4]}-{value[4:6]}-{value[6:8]}"
    return None


def _symbol_to_ts(symbol: str) -> str:
    s = str(symbol)
    if s.startswith(("60", "68", "90", "11", "5")):
        return f"{s}.SH"
    if s.startswith(("8", "4")):
        return f"{s}.BJ"
    return f"{s}.SZ"


def _fallback_from_akshare():
    print("stock_basic 受限，使用 akshare 代码名称兜底刷新")
    df = ak.stock_info_a_code_name()
    df = df.rename(columns={"code": "symbol", "name": "name"})
    df["ts_code"] = df["symbol"].apply(_symbol_to_ts)
    df["area"] = None
    df["industry"] = None
    df["market"] = None
    df["list_date"] = None
    df["delist_date"] = None
    df["is_hs"] = None
    return df[["ts_code", "symbol", "name", "area", "industry", "market", "list_date", "delist_date", "is_hs"]]


def main():
    print(f"[{datetime.now()}] 开始刷新 stocks_tushare")
    pro = ts.pro_api(TOKEN)

    import pandas as pd

    frames = []
    try:
        for status in ["L", "D", "P"]:
            df = pro.stock_basic(
                exchange="",
                list_status=status,
                fields="ts_code,symbol,name,area,industry,market,list_date,delist_date,is_hs",
            )
            if df is not None and len(df) > 0:
                frames.append(df)
        all_df = pd.concat(frames, ignore_index=True).drop_duplicates(subset=["ts_code"])
    except Exception as e:
        print(f"stock_basic 调用失败: {e}")
        all_df = _fallback_from_akshare()

    if all_df is None or len(all_df) == 0:
        print("未获取到任何股票基础信息")
        return

    conn = pymysql.connect(**DB_CONFIG)
    cur = conn.cursor()

    sql = """
    INSERT INTO stocks_tushare
    (ts_code, symbol, name, area, industry, market, list_date, delist_date, is_hs)
    VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)
    ON DUPLICATE KEY UPDATE
      symbol=VALUES(symbol),
      name=VALUES(name),
      area=VALUES(area),
      industry=VALUES(industry),
      market=VALUES(market),
      list_date=VALUES(list_date),
      delist_date=VALUES(delist_date),
      is_hs=VALUES(is_hs)
    """

    rows = []
    for _, r in all_df.iterrows():
        rows.append(
            (
                clean(r.get("ts_code")),
                clean(r.get("symbol")),
                clean(r.get("name")),
                clean(r.get("area")),
                clean(r.get("industry")),
                clean(r.get("market")),
                normalize_date(r.get("list_date")),
                normalize_date(r.get("delist_date")),
                clean(r.get("is_hs")),
            )
        )

    cur.executemany(sql, rows)
    conn.commit()

    cur.execute("SELECT COUNT(*) FROM stocks_tushare")
    total = cur.fetchone()[0]

    cur.close()
    conn.close()

    print(f"刷新完成：本次写入/更新 {len(rows)}，当前 stocks_tushare 总数 {total}")


if __name__ == "__main__":
    main()
