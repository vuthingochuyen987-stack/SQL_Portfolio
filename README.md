# P3 – SQL: LLM Usage & Automation Desire (WORKBank)

## Business Question
Người lao động đang dùng LLM (ChatGPT, Claude…) trong công việc có mong muốn AI tự động hóa công việc của họ nhiều hơn hay ít hơn so với người ít/không dùng? Trong 9 loại tác vụ dùng LLM, loại nào liên hệ mạnh nhất với automation desire?

## Data
- WORKBank (Shao et al., 2025, Stanford SALT Lab): [Hugging Face](https://huggingface.co/datasets/SALT-NLP/WORKBank) · paper: arXiv:2506.06576
- `domain_worker_desires.csv`: 5.731 lượt đánh giá (task, user)
- `domain_worker_metadata.csv`: 1.500 người lao động
- Dữ liệu không nằm trong repo, xem hướng dẫn tải ở [data/README.md](data/README.md)

## Tools
SQL Server · SSMS · BULK INSERT · CTE · UNPIVOT · PRIMARY/FOREIGN KEY

## Pipeline
| File | Mục đích |
|---|---|
| `01_create_tables.sql` | Tạo 2 bảng thô (chưa có PK để import không bị rollback) |
| `02_load_data.sql` | BULK INSERT từ CSV |
| `03_data_quality_checks.sql` | Kiểm tra số dòng, trùng (TaskID, UserID), UserID mồ côi, NULL |
| `04_add_constraints.sql` | Thêm PK/FK sau khi dữ liệu đã được kiểm chứng sạch |
| `05_analysis.sql` | 3 truy vấn phân tích chính |

## Data Quality Issues (khi import)
1. **Lệch cột**: dấu phẩy nằm trong trường có ngoặc kép → thêm `FORMAT='CSV'`, `FIELDQUOTE='"'`.
2. **Sai kiểu dữ liệu**: cột TRUE/FALSE dạng text không tự convert sang BIT → import dạng NVARCHAR trước.
3. **ROWTERMINATOR**: file dùng CRLF → đặt `0x0d0a` để ký tự `\r` không dính vào cột cuối.

## Method
Chỉ giữ user có ≥ 3 lượt đánh giá để trung bình từng user đủ tin cậy: còn **991/1.500 user** (509 user bị loại do chưa có hoặc chỉ có 1–2 đánh giá).

## Key Findings
**1. Dùng LLM càng thường xuyên, automation desire càng cao** (thang 1–5):

| Mức dùng LLM trong công việc | Số user | Desire TB | Độ lệch chuẩn |
|---|---|---|---|
| Hằng ngày | 351 | 3,37 | 0,87 |
| Hằng tuần | 201 | 3,02 | 0,83 |
| Thỉnh thoảng | 275 | 2,89 | 0,89 |
| Không dùng cho công việc | 154 | 2,45 | 1,01 |

(Nhóm "chưa từng nghe đến LLM" có n = 10, quá nhỏ nên không đưa vào xu hướng.)

**2. Loại tác vụ có chênh lệch lớn nhất** (chênh lệch avg_desire giữa mức dùng cao nhất và thấp nhất): Edit 0,53 · Information Access 0,51 · Communication 0,45 · System Design 0,43 · Coding 0,41 · Idea Generation 0,35 · Analysis 0,33 · Decision 0,29 · Data Processing 0,29. Các tác vụ văn phòng, rủi ro thấp dẫn đầu, nhưng khoảng cách với nhóm kỹ thuật không lớn.

## Recommendations
Nếu doanh nghiệp triển khai AI theo từng giai đoạn: chọn nhóm dùng AI hằng ngày làm pilot, bắt đầu với use case Edit / Information Access / Communication, và có hỗ trợ riêng cho nhóm chưa dùng AI. Chi tiết xem report.

## Limitations
- Dữ liệu cắt ngang: chỉ cho thấy tương quan, không chứng minh nhân quả.
- Dữ liệu tự báo cáo (self-report).
- Số lượt đánh giá mỗi user không đồng đều (đã lọc ≥ 3, chưa loại bỏ hoàn toàn).
- Chưa kiểm định ý nghĩa thống kê (p-value).

## How to run
1. Tải 2 file CSV từ link ở mục Data, đặt vào một thư mục trên máy.
2. Mở `sql/02_load_data.sql`, sửa 2 đường dẫn `FROM '...'` cho đúng thư mục của bạn.
3. Chạy lần lượt `01` → `05` trong SSMS.
