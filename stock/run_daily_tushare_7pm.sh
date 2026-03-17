#!/bin/bash
set -euo pipefail
cd /home/node/.openclaw/workspace
python3 /home/node/.openclaw/workspace/stock/update_tushare_daily_all.py >> /home/node/.openclaw/workspace/stock/cron_tushare.log 2>&1
