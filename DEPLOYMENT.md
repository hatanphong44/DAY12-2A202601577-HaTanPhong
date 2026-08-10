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

(.venv) PS C:\Users\Kaze\Downloads\VIN\Day12\DAY12-2A202601577-HaTanPhong> curl.exe -i "https://day12-2a202601577-hatanphong.onrender.com/health"
>> 
HTTP/1.1 200 OK
Date: Mon, 10 Aug 2026 05:50:29 GMT
Content-Type: application/json
Transfer-Encoding: chunked
Connection: keep-alive
cf-cache-status: DYNAMIC
rndr-id: b00145c1-e2c3-4c40
Server: cloudflare
vary: Accept-Encoding
x-render-origin-server: uvicorn
CF-RAY: a28cb92a0af204ee-HKG
alt-svc: h3=":443"; ma=86400

{"status":"ok","service":"day12-agent","version":"1.0.0"}




.venv) PS C:\Users\Kaze\Downloads\VIN\Day12\DAY12-2A202601577-HaTanPhong> curl.exe -i "https://day12-2a202601577-hatanphong.onrender.com/ready"
>> 
HTTP/1.1 200 OK
Date: Mon, 10 Aug 2026 05:50:46 GMT
Content-Type: application/json
Transfer-Encoding: chunked
Connection: keep-alive
cf-cache-status: DYNAMIC
rndr-id: d34a8efe-5b02-4ca5
Server: cloudflare
vary: Accept-Encoding
x-render-origin-server: uvicorn
CF-RAY: a28cb9915c9ffd7f-SIN
alt-svc: h3=":443"; ma=86400

{"status":"ready","redis":true}




(.venv) PS C:\Users\Kaze\Downloads\VIN\Day12\DAY12-2A202601577-HaTanPhong> curl.exe -i -X POST "https://day12-2a202601577-hatanphong.onrender.com/ask" `
>>   -H "Content-Type: application/json" `
>>   -d '{"question":"Hello"}'
HTTP/1.1 401 Unauthorized
Date: Mon, 10 Aug 2026 05:51:02 GMT
Content-Type: application/json
Transfer-Encoding: chunked
Connection: keep-alive
rndr-id: 08db709f-9d37-4001
Server: cloudflare
vary: Accept-Encoding
x-render-origin-server: uvicorn
cf-cache-status: DYNAMIC
CF-RAY: a28cb9f398f44dab-SIN
alt-svc: h3=":443"; ma=86400

{"detail":"invalid or missing API key"}




.venv) PS C:\Users\Kaze\Downloads\VIN\Day12\DAY12-2A202601577-HaTanPhong> $env:AGENT_API_KEY="LgZM6R4Qx12zqZfGkmLeBC4oyg-g81d6iyD8OJC9XKo"
>> 
>> curl.exe -i -X POST "https://day12-2a202601577-hatanphong.onrender.com/ask"   -H "Content-Type: application/json"-H "X-API-Key: $env:AGENT_API_KEY"   -H "X-User-Id: sv-test"-d '{"question":"Deploy là gì?"}'
HTTP/1.1 200 OK
Date: Mon, 10 Aug 2026 05:51:38 GMT
Content-Type: application/json
Transfer-Encoding: chunked
Connection: keep-alive
rndr-id: 49f4df47-75ba-4c00
Server: cloudflare
vary: Accept-Encoding
x-render-origin-server: uvicorn
cf-cache-status: DYNAMIC
CF-RAY: a28cbad63a21b5a9-SIN
alt-svc: h3=":443"; ma=86400

{"answer":"Câu hỏi hay. Deploy là gì thường được giải quyết bằng cách chuẩn hóa môi trường chạy: cùng một image chạy giống nhau ở laptop và trên cloud. (Mình đang nhớ 2 lượt trao đổi trước đó.)","user_id":"sv-test","history_length":2,"cost_usd":3.315e-05,"tokens":{"in":41,"out":45}}