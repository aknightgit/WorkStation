#!/usr/bin/env python3
"""按交易日批量更新全市场日线到 stock_daily_tushare。"""

from __future__ import annotations

from datetime import datetime
import pymysql
import tushare as ts

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


def yyyymmdd_to_date(s: str) -> str:
    return f"{s[0:4]}-{s[4:6]}-{s[6:8]}"


def upsert_trade_date(trade_date: str) -> int:
    pro = ts.pro_api(TOKEN)
    df = pro.daily(trade_date=trade_date)
    if df is None or len(df) == 0:
        return 0

    conn = pymysql.connect(**DB_CONFIG)
    cur = conn.cursor()

    sql = """
    INSERT INTO stock_daily_tushare
    (ts_code, trade_date, open_price, high_price, low_price, close_price, pre_close, price_change, pct_change, volume, amount)
    VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
    ON DUPLICATE KEY UPDATE
      open_price=VALUES(open_price),
      high_price=VALUES(high_price),
      low_price=VALUES(low_price),
      close_price=VALUES(close_price),
      pre_close=VALUES(pre_close),
      price_change=VALUES(price_change),
      pct_change=VALUES(pct_change),
      volume=VALUES(volume),
      amount=VALUES(amount)
    """

    rows = []
    for _, r in df.iterrows():
        rows.append(
            (
                r["ts_code"],
                yyyymmdd_to_date(str(r["trade_date"])),
                r.get("open"),
                r.get("high"),
                r.get("low"),
                r.get("close"),
                r.get("pre_close"),
                r.get("change"),
                r.get("pct_chg"),
                r.get("vol"),
                r.get("amount"),
            )
        )

    cur.executemany(sql, rows)
    conn.commit()
    cur.close()
    conn.close()

    return len(rows)


def main():
    trade_date = datetime.now().strftime("%Y%m%d")
    start = datetime.now()
    inserted = upsert_trade_date(trade_date)
    print(f"[{datetime.now()}] trade_date={trade_date} 完成，写入/更新 {inserted} 行，用时 {datetime.now()-start}")


if __name__ == "__main__":
    main()
