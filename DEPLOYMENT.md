# Thông Tin Deploy — Checkpoint 5

## Thông Tin Học Viên

| Mục | Nội dung |
|-----|----------|
| Họ và tên | Ha Tan Phong |
| Mã học viên | 2A202601577 |
| Repo | https://github.com/hatanphong44/DAY12-2A202601577-HaTanPhong |

## Service

| Mục | Nội dung |
|-----|----------|
| Public URL | https://day12-2a202601577-hatanphong.onrender.com |
| Platform | Render |
| Ngày deploy | 2026-08-10 |

## Biến Môi Trường Đã Set Trên Cloud

| Biến | Đã set | Ghi chú |
|------|--------|---------|
| `PORT` | ✅ | platform tự gán |
| `AGENT_API_KEY` | ✅ | đặt trong dashboard |
| `REDIS_URL` | ✅ | Redis add-on của Railway |
| `RATE_LIMIT_PER_MINUTE` | ✅ | 10 |
| `MONTHLY_BUDGET_USD` | ✅ | 10.0 |
| `LOG_LEVEL` | ✅ | INFO |

## Lệnh Kiểm Tra

```bash
# 1. Liveness — mong đợi 200
curl -i https://day12-2a202601577-hatanphong.onrender.com/health

# 2. Readiness — mong đợi 200
curl -i https://day12-2a202601577-hatanphong.onrender.com/ready

# 3. Không có API key — mong đợi 401
curl -i -X POST https://day12-2a202601577-hatanphong.onrender.com/ask \
  -H "Content-Type: application/json" \
  -d '{"question":"Hello"}'

# 4. Có API key — mong đợi 200
curl -i -X POST https://day12-2a202601577-hatanphong.onrender.com/ask \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $AGENT_API_KEY" \
  -H "X-User-Id: sv-test" \
  -d '{"question":"Deploy là gì?"}'
```

## Kết Quả Chạy Thật

```
Health check: 200 OK
Ready check: 200 OK  
API without key: 401 Unauthorized
API with key: 200 OK
```
