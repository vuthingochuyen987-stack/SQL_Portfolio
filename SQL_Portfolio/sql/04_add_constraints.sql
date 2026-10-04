-- ============================================================
-- FILE: 04_add_constraints.sql
-- MỤC ĐÍCH: Thiết lập PK/FK chính thức, SAU KHI đã xác nhận dữ liệu sạch ở bước 03 (không NULL, không trùng, không có UserID mồ côi)
-- ============================================================

-- Bắt buộc NOT NULL trước khi set PK (yêu cầu kỹ thuật của SQL Server)
ALTER TABLE domain_worker_metadata
ALTER COLUMN UserID UNIQUEIDENTIFIER NOT NULL;

ALTER TABLE domain_worker_desires
ALTER COLUMN TaskID INT NOT NULL;

ALTER TABLE domain_worker_desires
ALTER COLUMN UserID UNIQUEIDENTIFIER NOT NULL;

-- Khóa chính: metadata có 1 dòng/user
ALTER TABLE domain_worker_metadata
ADD CONSTRAINT PK_worker_metadata PRIMARY KEY (UserID);

-- Khóa chính ghép: desires có 1 dòng/(task, user) - vì 1 user đánh giá nhiều task, và 1 task được nhiều user đánh giá
ALTER TABLE domain_worker_desires
ADD CONSTRAINT PK_worker_desires PRIMARY KEY (TaskID, UserID);

-- Khóa ngoại: bảo vệ tính toàn vẹn dữ liệu về lâu dài, chặn việc insert UserID không tồn tại trong metadata ở tương lai
ALTER TABLE domain_worker_desires
ADD CONSTRAINT FK_desires_metadata FOREIGN KEY (UserID)
REFERENCES domain_worker_metadata(UserID);