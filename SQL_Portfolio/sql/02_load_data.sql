-- FILE: 02_load_data.sql
-- MỤC ĐÍCH: Import dữ liệu thô từ CSV vào 2 bảng đã tạo
-- LƯU Ý QUAN TRỌNG:
--   - FORMAT='CSV' + FIELDQUOTE='"' để xử lý đúng các ô có dấu phẩy bên trong (VD: "Professional Degree (e.g., MD, JD)")
--   - ROWTERMINATOR='0x0d0a' (CRLF) vì file gốc dùng xuống dòng kiểu Windows \r\n. Dùng '0x0a' (chỉ LF) sẽ khiến \r thừa
--     dính vào cột cuối, gây lỗi parse khi cột cuối có dấu ngoặc kép (đã gặp thực tế ở dòng 1385 của desires.csv)

BULK INSERT domain_worker_desires
FROM 'C:\path\to\data\domain_worker_desires.csv' -- Sửa lại đường dẫn của bạn
WITH (
    FIRSTROW = 2,               -- bỏ qua dòng header
    FORMAT = 'CSV',
    FIELDQUOTE = '"',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0d0a',
    CODEPAGE = '65001',         -- UTF-8
    TABLOCK
);

BULK INSERT domain_worker_metadata
FROM 'C:\path\to\data\domain_worker_desires.csv' -- Sửa lại đường dẫn của bạn
WITH (
    FIRSTROW = 2,
    FORMAT = 'CSV',
    FIELDQUOTE = '"',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0d0a',
    CODEPAGE = '65001',
    TABLOCK
);