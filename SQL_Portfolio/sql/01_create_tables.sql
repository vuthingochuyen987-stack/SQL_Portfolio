-- ============================================================
-- FILE: 01_create_tables.sql
-- MỤC ĐÍCH: Tạo schema cho 2 bảng nguồn từ WORKBank dataset
-- LƯU Ý: Ban đầu tạo KHÔNG có PRIMARY KEY để import dữ liệu thô trước, tránh BULK INSERT rollback toàn bộ nếu có dòng
--        vi phạm ràng buộc. PK/FK sẽ được thêm ở bước 04 sau khi đã kiểm chứng dữ liệu sạch.
-- ============================================================

CREATE TABLE domain_worker_desires (
    TaskID                          INT,
    Occupation                      NVARCHAR(150),
    Task                            NVARCHAR(MAX),
    UserID                          UNIQUEIDENTIFIER,
    RatingDate                      NVARCHAR(20),   -- giữ dạng text, convert sang DATE sau nếu cần dùng
    SelfReportedExpertise           NVARCHAR(30),
    AutomationDesireRating          TINYINT,        -- thang Likert 1-5
    TimeSpent                       TINYINT,
    CoreSkillRating                 TINYINT,
    JobSecurityRating               TINYINT,
    EnjoymentRating                 TINYINT,
    -- Các cột Reason_* để NVARCHAR thay vì BIT vì dữ liệu gốc là text "TRUE"/"FALSE", BULK INSERT không tự convert được
    Reason_AutoDesire_FreeTime      NVARCHAR(10),
    Reason_AutoDesire_Repetitive    NVARCHAR(10),
    Reason_AutoDesire_HumanError    NVARCHAR(10),
    Reason_AutoDesire_Stress        NVARCHAR(10),
    Reason_AutoDesire_Difficulty    NVARCHAR(10),
    Reason_AutoDesire_Scale         NVARCHAR(10),
    PhysicalActionRequirement       TINYINT,
    InterpersonalCommRequirement    TINYINT,
    InvolvedUncertainty             TINYINT,
    DomainExpertiseRequirement      TINYINT,
    HumanAgencyScaleRating          TINYINT,
    Reason_HAS_Physical             NVARCHAR(10),
    Reason_HAS_Control              NVARCHAR(10),
    Reason_HAS_DomainKnowledge      NVARCHAR(10),
    Reason_HAS_Empathy              NVARCHAR(10),
    Reason_HAS_QualityOversight     NVARCHAR(10),
    Reason_HAS_Dynamic              NVARCHAR(10),
    Reason_HAS_Ethical              NVARCHAR(10),
    OtherReason_AutoDesire          NVARCHAR(MAX),
    OtherReason_HAS                 NVARCHAR(MAX)
);

CREATE TABLE domain_worker_metadata (
    UserID                          UNIQUEIDENTIFIER,
    Occupation                      NVARCHAR(150),
    Gender                          NVARCHAR(30),
    Race                            NVARCHAR(50),
    Income                          NVARCHAR(30),
    Age                             TINYINT,
    Education                       NVARCHAR(100),
    Experience                      NVARCHAR(30),
    AI_TediousWorkAttitude          NVARCHAR(50),
    AI_JobImportanceAttitude        NVARCHAR(50),
    AI_DailyInterestAttitude        NVARCHAR(50),
    AI_SufferingAttitude            NVARCHAR(50),
    ZipCode                         NVARCHAR(10),   -- text, không phải INT (tránh mất số 0 đầu)
    PoliticalAffiliation            NVARCHAR(50),
    LLM_Familiarity                 NVARCHAR(100),
    LLM_UseInWork                   NVARCHAR(100),
    LLM_Usage_InformationAccess     NVARCHAR(20),
    LLM_Usage_Edit                  NVARCHAR(20),
    LLM_Usage_IdeaGeneration        NVARCHAR(20),
    LLM_Usage_Communication         NVARCHAR(20),
    LLM_Usage_Analysis              NVARCHAR(20),
    LLM_Usage_Decision              NVARCHAR(20),
    LLM_Usage_Coding                NVARCHAR(20),
    LLM_Usage_SystemDesign          NVARCHAR(20),
    LLM_Usage_DataProcessing        NVARCHAR(20),
    RecruitmentSource               NVARCHAR(50)
);