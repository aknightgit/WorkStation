#!/usr/bin/env python3
"""全量/增量回补 stock_daily_tushare 历史行情。"""

from __future__ import annotations

import argparse
import time
from datetime import datetime, date, timedelta

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

UPSERT_SQL = """
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


def yyyymmdd_to_date(s: str) -> str:
    return f"{s[0:4]}-{s[4:6]}-{s[6:8]}"


def parse_date(s: str) -> date:
    return datetime.strptime(s, "%Y%m%d").date()


def format_date(d: date) -> str:
    return d.strftime("%Y%m%d")


def detect_start_date(conn, full_refresh: bool) -> str:
    cur = conn.cursor()

    if full_refresh:
        cur.execute("SELECT MIN(list_date) FROM stocks_tushare WHERE list_date IS NOT NULL")
        min_list = cur.fetchone()[0]
        cur.close()
        if min_list:
            return min_list.strftime("%Y%m%d")
        return "20100101"

    cur.execute("SELECT MAX(trade_date) FROM stock_daily_tushare")
    max_trade = cur.fetchone()[0]
    if max_trade:
        start = (max_trade + timedelta(days=1)).strftime("%Y%m%d")
    else:
        start = "20100101"
    cur.close()
    return start


def main():
    parser = argparse.ArgumentParser(description="Backfill stock_daily_tushare by trade_date")
    parser.add_argument("--start-date", default=None, help="YYYYMMDD")
    parser.add_argument("--end-date", default=datetime.now().strftime("%Y%m%d"), help="YYYYMMDD")
    parser.add_argument("--full-refresh", action="store_true", help="TRUNCATE daily table before backfill")
    parser.add_argument("--sleep", type=float, default=0.2, help="seconds between API calls")
    args = parser.parse_args()

    pro = ts.pro_api(TOKEN)
    conn = pymysql.connect(**DB_CONFIG)
    cur = conn.cursor()

    if args.full_refresh:
        print("执行全量刷新：TRUNCATE stock_daily_tushare")
        cur.execute("TRUNCATE TABLE stock_daily_tushare")
        conn.commit()

    start_str = args.start_date or detect_start_date(conn, full_refresh=args.full_refresh)
    end_str = args.end_date

    start_d = parse_date(start_str)
    end_d = parse_date(end_str)

    print(f"[{datetime.now()}] 回补区间: {start_str} -> {end_str}")

    cur_date = start_d
    day_count = 0
    write_rows = 0
    non_empty_days = 0

    while cur_date <= end_d:
        # 仅工作日请求，减少无效调用
        if cur_date.weekday() >= 5:
            cur_date += timedelta(days=1)
            continue

        t = format_date(cur_date)
        day_count += 1

        try:
            df = pro.daily(trade_date=t)
            if df is not None and len(df) > 0:
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

                cur.executemany(UPSERT_SQL, rows)
                conn.commit()
                write_rows += len(rows)
                non_empty_days += 1

            if day_count % 50 == 0:
                print(
                    f"[{datetime.now()}] 进度: {t}, 请求日={day_count}, 有数据日={non_empty_days}, 写入累计={write_rows}"
                )

        except Exception as e:
            print(f"[{datetime.now()}] {t} 请求失败: {e}")

        if args.sleep > 0:
            time.sleep(args.sleep)

        cur_date += timedelta(days=1)

    cur.execute("SELECT COUNT(*) FROM stock_daily_tushare")
    total = cur.fetchone()[0]
    conn.commit()
    cur.close()
    conn.close()

    print(
        f"[{datetime.now()}] 回补完成: 请求日={day_count}, 有数据日={non_empty_days}, 本次写入累计={write_rows}, 表总行数={total}"
    )


if __name__ == "__main__":
    main()
