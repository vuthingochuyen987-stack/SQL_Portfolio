-- ============================================================
-- FILE: 03_data_quality_checks.sql
-- MỤC ĐÍCH: Kiểm chứng dữ liệu TRƯỚC khi áp ràng buộc PK/FK (nguyên tắc "explore before enforce" - tránh mất
--           dữ liệu oan nếu set PK ngay từ đầu rồi BULK INSERT rollback do 1 dòng vi phạm)
-- ============================================================

-- Check 1: Đối chiếu số dòng import với số dòng thực tế trong CSV
SELECT COUNT(*) AS total_desires FROM domain_worker_desires;
SELECT COUNT(*) AS total_metadata FROM domain_worker_metadata;

-- Check 2: Có cặp (TaskID, UserID) nào bị trùng không? (nếu có, PK ghép (TaskID, UserID) sẽ không tạo được)
SELECT TaskID, UserID, COUNT(*) AS so_lan_trung
FROM domain_worker_desires
GROUP BY TaskID, UserID
HAVING COUNT(*) > 1;

-- Check 3: Có UserID nào trong desires mà không tồn tại trong metadata không? (nếu có, JOIN sau này sẽ mất dữ liệu, và FK
-- constraint sẽ không tạo được)
SELECT DISTINCT d.UserID
FROM domain_worker_desires d
LEFT JOIN domain_worker_metadata m ON d.UserID = m.UserID
WHERE m.UserID IS NULL;

-- Check 4: Có dòng nào NULL ở cột dự kiến làm PK không?
SELECT COUNT(*) AS null_UserID_metadata
FROM domain_worker_metadata WHERE UserID IS NULL;

SELECT 
    SUM(CASE WHEN TaskID IS NULL THEN 1 ELSE 0 END) AS null_TaskID,
    SUM(CASE WHEN UserID IS NULL THEN 1 ELSE 0 END) AS null_UserID
FROM domain_worker_desires;