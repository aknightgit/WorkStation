# NONPROD 环境

> ⚠️ **凭证文件不在此处**，统一存放在 `/data/LS_ENV/NONPROD/`
> 此文件仅作为信息索引，不包含任何密码/密钥

## 环境文件位置

| 文件 | 路径 | 内容 |
|------|------|------|
| 连接信息 | `/data/LS_ENV/NONPROD/NONPROD.md` | EC2/RDS/Redshift 连接详情 |
| SSH 密钥 (PPK) | `/data/LS_ENV/NONPROD/New_NonProd_Prism.ppk` | PuTTY 格式密钥 |
| SSH 密钥 (OpenSSH) | `/data/LS_ENV/NONPROD/New_NonProd_Prism_openssh` | OpenSSH 格式密钥 |

## 环境概览

| 资源 | 说明 |
|------|------|
| EC2 × 2 | 69.235.153.162 / 52.83.163.30 |
| RDS (MySQL) | ls-datahub-nonprod-db |
| Redshift | levis-cn-dw-np |

> 详细连接信息请查看 `/data/LS_ENV/NONPROD/NONPROD.md`
