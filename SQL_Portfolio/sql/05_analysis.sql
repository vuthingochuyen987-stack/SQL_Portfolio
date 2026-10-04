-- ============================================================
-- FILE: 05_analysis.sql
-- CÂU HỎI PHÂN TÍCH: Mối liên hệ giữa mức độ sử dụng LLM hiện tại trong công việc và mong muốn tự động hóa (Automation
-- Desire) của người lao động có khác nhau không?
-- QUYẾT ĐỊNH XỬ LÝ DỮ LIỆU:
-- Chỉ giữ user có >= 3 lượt đánh giá task (num_tasks_rated >= 3) để tránh nhiễu từ cỡ mẫu nhỏ - trung bình tính từ 1-2 quan sát
-- dễ bị lệch cực đoan, không phản ánh xu hướng thật của user đó.
-- (Xem tỷ lệ user bị loại trong báo cáo, mục Data Quality)
-- ============================================================

WITH user_avg_desire AS (
    SELECT 
		UserID,
        AVG(CAST(AutomationDesireRating AS FLOAT)) AS avg_desire,
        COUNT(*) AS num_tasks_rated
    FROM domain_worker_desires
    GROUP BY UserID
    HAVING COUNT(*) >= 3
)
SELECT 
    m.LLM_UseInWork,
    COUNT(*) AS so_luong_user,
    AVG(u.avg_desire) AS avg_desire_theo_nhom,
    STDEV(u.avg_desire) AS do_lech_chuan
FROM domain_worker_metadata m
JOIN user_avg_desire u ON m.UserID = u.UserID
GROUP BY m.LLM_UseInWork
ORDER BY avg_desire_theo_nhom DESC;

-- ============================================================
-- MỤC ĐÍCH: So sánh avg_desire theo TỪNG LOẠI sử dụng LLM
-- (Coding, Analysis, Communication...) trong 1 bảng kết quả
-- duy nhất, để xác định loại nào có mối liên hệ mạnh nhất
-- với automation desire - thay vì chỉ nhìn tần suất dùng
-- LLM chung chung như phân tích trước.
-- ============================================================

WITH user_avg_desire AS (
    SELECT UserID, AVG(CAST(AutomationDesireRating AS FLOAT)) AS avg_desire
    FROM domain_worker_desires
    GROUP BY UserID
    HAVING COUNT(*) >= 3
),
-- Chuyển 9 cột LLM_Usage_* từ dạng "hàng ngang" sang "hàng dọc"
-- để có thể GROUP BY theo (loại usage, mức độ) trong 1 lần duy nhất
unpivoted AS (
    SELECT UserID, UsageType, UsageLevel
    FROM domain_worker_metadata
    UNPIVOT (
        UsageLevel FOR UsageType IN (
            LLM_Usage_InformationAccess,
            LLM_Usage_Edit,
            LLM_Usage_IdeaGeneration,
            LLM_Usage_Communication,
            LLM_Usage_Analysis,
            LLM_Usage_Decision,
            LLM_Usage_Coding,
            LLM_Usage_SystemDesign,
            LLM_Usage_DataProcessing
        )
    ) AS up
)
SELECT 
    up.UsageType,
    up.UsageLevel,
    COUNT(*) AS so_luong_user,
    AVG(u.avg_desire) AS avg_desire
FROM unpivoted up
JOIN user_avg_desire u ON up.UserID = u.UserID
GROUP BY up.UsageType, up.UsageLevel
ORDER BY up.UsageType, avg_desire DESC;

WITH user_avg_desire AS (
    SELECT UserID, AVG(CAST(AutomationDesireRating AS FLOAT)) AS avg_desire
    FROM domain_worker_desires
    GROUP BY UserID
    HAVING COUNT(*) >= 3
),
unpivoted AS (
    SELECT UserID, UsageType, UsageLevel
    FROM domain_worker_metadata
    UNPIVOT (
        UsageLevel FOR UsageType IN (
            LLM_Usage_InformationAccess, LLM_Usage_Edit, LLM_Usage_IdeaGeneration,
            LLM_Usage_Communication, LLM_Usage_Analysis, LLM_Usage_Decision,
            LLM_Usage_Coding, LLM_Usage_SystemDesign, LLM_Usage_DataProcessing
        )
    ) AS up
),
summary AS (
    SELECT up.UsageType, up.UsageLevel, AVG(u.avg_desire) AS avg_desire
    FROM unpivoted up
    JOIN user_avg_desire u ON up.UserID = u.UserID
    GROUP BY up.UsageType, up.UsageLevel
)
SELECT 
    UsageType,
    MAX(avg_desire) - MIN(avg_desire) AS chenh_lech_desire
FROM summary
GROUP BY UsageType
ORDER BY chenh_lech_desire DESC;