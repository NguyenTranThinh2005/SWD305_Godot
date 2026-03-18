-- RUN THIS SCRIPT IN SQL SERVER MANAGEMENT STUDIO (SSMS) 
-- TO FIX THE "Invalid column name" ERROR

USE VNEG_System
GO

-- 1. Thêm các cột còn thiếu vào bảng profiles
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[profiles]') AND name = N'TotalCoins')
BEGIN
    ALTER TABLE [dbo].[profiles] ADD [TotalCoins] INT DEFAULT 0;
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[profiles]') AND name = N'TotalStars')
BEGIN
    ALTER TABLE [dbo].[profiles] ADD [TotalStars] INT DEFAULT 0;
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[profiles]') AND name = N'Level')
BEGIN
    ALTER TABLE [dbo].[profiles] ADD [Level] INT DEFAULT 1;
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[profiles]') AND name = N'Exp')
BEGIN
    ALTER TABLE [dbo].[profiles] ADD [Exp] INT DEFAULT 0;
END
GO

-- 2. Đảm bảo dữ liệu cũ có giá trị mặc định (không null)
UPDATE [dbo].[profiles] SET TotalCoins = 0 WHERE TotalCoins IS NULL;
UPDATE [dbo].[profiles] SET TotalStars = 0 WHERE TotalStars IS NULL;
UPDATE [dbo].[profiles] SET [Level] = 1 WHERE [Level] IS NULL;
UPDATE [dbo].[profiles] SET [Exp] = 0 WHERE [Exp] IS NULL;
GO

PRINT 'Database schema updated successfully!';
