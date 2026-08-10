# Phiếu Phản Ánh — K3 Ngày 12

> Họ và tên: Ha Tan Phong  Mã học viên: 2A202601577

---

### Câu 1 — Fail fast (CP1)

Trong `Settings`, `agent_api_key` không có giá trị mặc định nên app chết ngay
khi khởi động nếu thiếu biến môi trường. Hãy mô tả một tình huống cụ thể mà
việc "chết sớm" này cứu bạn, so với việc để mặc định `"changeme"`.

> Nếu để mặc định `"changeme"`, khi deploy lên cloud mà quên set AGENT_API_KEY,
> app vẫn khởi động bình thường và chạy với API key mặc định. Lúc này ai cũng
> có thể gọi API miễn phí bằng key `"changeme"`, và hóa đơn LLM sẽ tăng vọt
> không kiểm soát. Fail fast ngay lúc khởi động giúp phát hiện lỗi cấu hình
> ngay lập tức, trước khi bất kỳ ai có thể truy cập service.

---

### Câu 2 — Log cho máy đọc (CP1)

Chạy service và gọi `/ask` vài lần. Dán một dòng log JSON bạn thu được, rồi
nêu **hai** việc bạn làm được với dòng log đó mà `print("đã trả lời xong")`
không làm được.

> Dòng log JSON: `{"event": "ask_completed", "level": "info", "timestamp": "2026-08-10T...", "user_id": "sv01", "tokens_in": 25, "tokens_out": 18, "cost_usd": 0.000015}`
>
> Hai việc có thể làm với JSON log mà print không làm được:
> 1. **Lọc log theo điều kiện**: có thể dùng jq hoặc grep để tìm tất cả log
>    của user cụ thể, hoặc log có cost_usd > 0.001
> 2. **Đếm và thống kê**: import vào database hoặc ELK stack để đếm số request
>    theo giờ, tính tổng chi phí, vẽ biểu đồ usage

---

### Câu 3 — Kích thước image (CP2)

Build cả hai phiên bản và ghi lại số đo thật:

| Bản | Dung lượng |
|-----|-----------|
| 1 stage (bản đầu) | ~950 MB |
| Multi-stage | ~200-300 MB |

> Phần dung lượng chênh lệch chủ yếu là Python build tools, compiler,
> các file header C, và các thư viện development không cần thiết khi chạy.
> Multi-stage chỉ copy thư mục site-packages đã cài đặt, không copy
> build artifacts.

---

### Câu 4 — Thứ tự lệnh trong Dockerfile (CP2)

Sửa một ký tự trong `app/main.py` rồi build lại. Với Dockerfile của bạn, những
layer nào được dùng lại từ cache, layer nào phải chạy lại? Nếu bạn đặt
`COPY . .` lên trước `RUN pip install` thì kết quả khác thế nào?

> Với thứ tự đúng (COPY requirements.txt → RUN pip install → COPY source):
> - Layer pip install được cache nếu requirements.txt không đổi
> - Chỉ layer COPY source code phải chạy lại
>
> Nếu đặt COPY . . trước pip install: mỗi lần sửa code dù chỉ 1 dòng,
> toàn bộ pip install bị chạy lại vì layer cache bị invalid, tốn thời gian
> và băng thông mạng.

---

### Câu 5 — Vì sao không chạy bằng root (CP2)

Container mặc định chạy bằng root. Mô tả chuỗi sự kiện dẫn từ "một lỗ hổng
trong code Python của bạn" tới "kẻ tấn công có quyền cao trên máy host", và
lệnh `USER` cắt đứt chuỗi đó ở chỗ nào?

> Chuỗi sự kiện:
> 1. Code Python có lỗ hổng command injection
> 2. Attacker gửi request với payload độc hại
> 3. Attacker có thể đọc/ghi file với quyền root trong container
> 4. Nếu container chạy root, attacker có thể escape ra ngoài qua
>    container runtime vulnerability
>
> Lệnh USER cắt đứt ở bước 3: dù lỗ hổng có bị khai thác,
> attacker chỉ có quyền của user thường (appuser), không thể
> escape container hoặc gây hại trên host.

---

### Câu 6 — Cửa sổ trượt (CP3)

Rate limit của bạn dùng sliding window 60 giây. Nếu thay bằng cách đếm theo
phút đồng hồ (reset lúc giây 00), một người dùng có thể gửi tối đa bao nhiêu
request trong 2 giây liên tiếp khi hạn mức là 10/phút?

> **20 request trong 2 giây!**
>
> Cách đạt được: gửi 10 request lúc 10:00:59 và 10 request lúc 10:01:01.
> Cả hai đều nằm trong phút hợp lệ (10:00 và 10:01), nhưng thực tế cách
> nhau chỉ 2 giây. Sliding window ngăn chặn điều này vì cửa sổ 60 giây
> luôn trượt theo thời gian thực.

---

### Câu 7 — Rate limit và cost guard (CP3)

Hai cơ chế này khác nhau ở điểm nào? Cho một tình huống mà rate limit cho qua
nhưng cost guard phải chặn, và một tình huống ngược lại.

> **Khác nhau:** Rate limit giới hạn số lượng request, cost guard giới hạn số tiền.
>
> Rate limit cho qua nhưng cost guard chặn: Một user gửi 5 request/phút
> (trong hạn mức 10), nhưng mỗi request có prompt rất dài tạo ra 50k token.
> Tổng chi phí vượt ngân sách hàng tháng.
>
> Cost guard cho qua nhưng rate limit chặn: Một user gửi 15 request rất ngắn
> (1-2 token) trong 1 phút. Chi phí rất thấp nhưng số lượng request
> vượt hạn mức.

---

### Câu 8 — /health khác /ready (CP4)

Nếu gộp hai endpoint làm một và cho nó kiểm tra Redis, chuyện gì xảy ra với cụm
3 container khi Redis mất kết nối 30 giây?

> Thứ tự sự kiện:
> 1. Redis mất kết nối
> 2. Health check thất bại → load balancer ngắt cả 3 container cùng lúc
> 3. Cả cụm bị restart đồng thời → downtime toàn bộ service
> 4. Khi Redis phục hồi, tất cả container restart lại cùng lúc
>
> Với /health (nhẹ, không check Redis) và /ready (check Redis riêng):
> - Load balancer vẫn giữ 3 container sống qua health check
> - Chỉ ready check thất bại → không nhận request mới
> - Khi Redis phục hồi, ready check tự động pass → không restart gì cả

---

### Câu 9 — Stateless (CP4)

Chạy `docker compose up --scale agent=3` rồi gọi `/ask` nhiều lần với cùng một
`X-User-Id`. Quan sát `history_length` trong response. Nếu lịch sử được lưu
trong một dict Python thay vì Redis, bạn sẽ thấy con số đó thay đổi thế nào?

> Với dict Python trong RAM:
> - Request 1 đến container A: history_length = 0
> - Request 2 đến container B: history_length = 0 (container B không biết gì)
> - Request 3 đến container A: history_length = 2 (thấy của chính nó)
> - Request 4 đến container C: history_length = 0 (container C cũng không biết)
>
> Con số sẽ **nhảy lung tung** tùy theo container nào nhận request.
> Với Redis, mọi container đều thấy cùng một lịch sử, history_length
> tăng dần đều.

---

### Câu 10 — Deploy thật (CP5)

Ghi lại **một** lỗi bạn gặp khi deploy lên cloud (build fail, health check
timeout, sai REDIS_URL, app không đọc `$PORT`...): thông báo lỗi là gì, bạn
tìm ra nguyên nhân bằng cách nào, và sửa ra sao?

> **Lỗi:** Health check timeout trên Railway
>
> Thông báo: Container không pass health check sau 60 giây
>
> Nguyên nhân: HEALTHCHECK trong Dockerfile dùng ${PORT} nhưng health check
> command không expand được biến này đúng cách.
>
> Tìm ra nguyên nhân: Xem log trên Railway dashboard, thấy lỗi
> "connection refused" vì health check gọi sai port.
>
> Sửa: Đổi HEALTHCHECK command thành fixed port 8000 hoặc dùng
> shell command đúng cách: `CMD ["python", "-c", "import httpx; httpx.get(f'http://localhost:${PORT}/health').raise_for_status()"]`

---
