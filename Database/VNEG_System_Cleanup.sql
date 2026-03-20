-- ====================================================================
-- VNEG_System_Cleanup.sql
-- KỊCH BẢN DỌN DẸP CÁC CHẾ ĐỘ CHƠI / BẢN ĐỒ TRỐNG (KHÔNG CÓ CÂU HỎI)
-- Chạy script này để ẩn các mục chưa được Data nhồi vào trên giao diện
-- ====================================================================
USE VNEG_System;
GO

PRINT N'BAT DAU QUET VA DON DEP DU LIEU TRONG...';

-- 1. Vô hiệu hóa (Ẩn) các Game không có câu hỏi nào đang hoạt động
UPDATE dbo.games 
SET is_active = 0 
WHERE id NOT IN (SELECT DISTINCT game_id FROM dbo.questions WHERE is_active = 1);

-- 2. Vô hiệu hóa (Ẩn) các Bản đồ (Map) không có Game nào đang hoạt động
UPDATE dbo.maps
SET is_active = 0
WHERE id NOT IN (SELECT DISTINCT map_id FROM dbo.games WHERE is_active = 1);

PRINT N'DA DON DEP THANH CONG! CAC MAP/GAME TRONG DA BI AN KHOI UI.';
GO
