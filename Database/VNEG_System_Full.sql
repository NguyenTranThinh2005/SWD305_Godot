-- ============================================================
-- VNEG_System — Complete Database Script (One-Shot)
-- Schema + Data + Gameplay (6 chế độ chơi đầy đủ)
-- Execute: F5 in SSMS
-- ============================================================
CREATE DATABASE VNEG_System
GO
USE VNEG_System
GO

-- ============================================================
-- 1. XÓA BẢNG CŨ (nếu có, theo thứ tự FK)
-- ============================================================
IF OBJECT_ID('dbo.game_error_grammar','U') IS NOT NULL DROP TABLE dbo.game_error_grammar;
IF OBJECT_ID('dbo.game_errors','U') IS NOT NULL DROP TABLE dbo.game_errors;
IF OBJECT_ID('dbo.game_sessions','U') IS NOT NULL DROP TABLE dbo.game_sessions;
IF OBJECT_ID('dbo.question_grammar','U') IS NOT NULL DROP TABLE dbo.question_grammar;
IF OBJECT_ID('dbo.questions','U') IS NOT NULL DROP TABLE dbo.questions;
IF OBJECT_ID('dbo.games','U') IS NOT NULL DROP TABLE dbo.games;
IF OBJECT_ID('dbo.maps','U') IS NOT NULL DROP TABLE dbo.maps;
IF OBJECT_ID('dbo.user_grammar_progress','U') IS NOT NULL DROP TABLE dbo.user_grammar_progress;
IF OBJECT_ID('dbo.grammar_topics','U') IS NOT NULL DROP TABLE dbo.grammar_topics;
IF OBJECT_ID('dbo.grades','U') IS NOT NULL DROP TABLE dbo.grades;
IF OBJECT_ID('dbo.profiles','U') IS NOT NULL DROP TABLE dbo.profiles;
IF OBJECT_ID('dbo.task_progress','U') IS NOT NULL DROP TABLE dbo.task_progress;
IF OBJECT_ID('dbo.tasks','U') IS NOT NULL DROP TABLE dbo.tasks;
IF OBJECT_ID('dbo.team_members','U') IS NOT NULL DROP TABLE dbo.team_members;
IF OBJECT_ID('dbo.teams','U') IS NOT NULL DROP TABLE dbo.teams;
IF OBJECT_ID('dbo.reports','U') IS NOT NULL DROP TABLE dbo.reports;
IF OBJECT_ID('dbo.system_logs','U') IS NOT NULL DROP TABLE dbo.system_logs;
IF OBJECT_ID('dbo.sessions','U') IS NOT NULL DROP TABLE dbo.sessions;
IF OBJECT_ID('dbo.users','U') IS NOT NULL DROP TABLE dbo.users;
GO

-- ============================================================
-- 2. TẠO BẢNG
-- ============================================================
CREATE TABLE dbo.users (
  id int IDENTITY(1,1) PRIMARY KEY, email nvarchar(255) NOT NULL UNIQUE,
  phone nvarchar(255) NULL, password_hash nvarchar(255) NOT NULL,
  avatar_url nvarchar(255) NULL, grade int NULL, region nvarchar(50) NULL,
  role nvarchar(50) DEFAULT 'user', is_active bit DEFAULT 1,
  created_at datetime DEFAULT GETDATE(), updated_at datetime DEFAULT GETDATE());
GO
CREATE TABLE dbo.grades (id int PRIMARY KEY, name nvarchar(255) NULL);
GO
CREATE TABLE dbo.grammar_topics (
  id int IDENTITY(1,1) PRIMARY KEY, parent_id int NULL REFERENCES dbo.grammar_topics(id),
  code nvarchar(255) UNIQUE, name nvarchar(255) NOT NULL,
  description nvarchar(max) NULL, example nvarchar(max) NULL,
  grade_min int NULL, grade_max int NULL, difficulty int NULL, is_active bit DEFAULT 1);
GO
CREATE TABLE dbo.maps (
  id int IDENTITY(1,1) PRIMARY KEY, grade_id int NULL REFERENCES dbo.grades(id),
  name nvarchar(255) NOT NULL, order_index int NULL, is_active bit DEFAULT 1);
GO
CREATE TABLE dbo.games (
  id int IDENTITY(1,1) PRIMARY KEY, map_id int NOT NULL REFERENCES dbo.maps(id),
  name nvarchar(255) NOT NULL, game_type nvarchar(50) NULL, flow nvarchar(max) NULL,
  order_index int NULL, is_premium bit DEFAULT 0, is_active bit NOT NULL DEFAULT 1);
GO
CREATE TABLE dbo.questions (
  id int IDENTITY(1,1) PRIMARY KEY, game_id int NOT NULL REFERENCES dbo.games(id),
  question_type nvarchar(255) NOT NULL, difficulty int NULL,
  data nvarchar(max) NOT NULL, answer nvarchar(max) NOT NULL,
  image_url nvarchar(500) NULL, audio_url nvarchar(500) NULL,
  explanation nvarchar(max) NULL, is_active bit DEFAULT 1);
GO
CREATE TABLE dbo.question_grammar (
  id int IDENTITY(1,1) PRIMARY KEY,
  question_id int NOT NULL REFERENCES dbo.questions(id),
  grammar_topic_id int NOT NULL REFERENCES dbo.grammar_topics(id),
  weight int DEFAULT 1, CONSTRAINT uq_question_grammar UNIQUE(question_id, grammar_topic_id));
GO
CREATE TABLE dbo.game_sessions (
  id int IDENTITY(1,1) PRIMARY KEY, user_id int NOT NULL REFERENCES dbo.users(id),
  game_id int NOT NULL REFERENCES dbo.games(id),
  score int NULL, stars int NULL, coins int NULL,
  accuracy decimal(5,2) NULL, completed_at datetime NULL);
GO
CREATE TABLE dbo.game_errors (
  id int IDENTITY(1,1) PRIMARY KEY,
  game_session_id int NOT NULL REFERENCES dbo.game_sessions(id),
  question_id int NOT NULL REFERENCES dbo.questions(id), error_type nvarchar(255) NULL);
GO
CREATE TABLE dbo.game_error_grammar (
  id int IDENTITY(1,1) PRIMARY KEY,
  game_error_id int NOT NULL REFERENCES dbo.game_errors(id),
  grammar_topic_id int NOT NULL REFERENCES dbo.grammar_topics(id));
GO
CREATE TABLE dbo.user_grammar_progress (
  id int IDENTITY(1,1) PRIMARY KEY, user_id int NOT NULL REFERENCES dbo.users(id),
  grammar_topic_id int NOT NULL REFERENCES dbo.grammar_topics(id),
  mastery_level decimal(5,2) NULL, correct_count int DEFAULT 0, wrong_count int DEFAULT 0,
  last_practiced_at datetime NULL, CONSTRAINT uq_user_grammar UNIQUE(user_id, grammar_topic_id));
GO
CREATE TABLE dbo.profiles (
  id int IDENTITY(1,1) PRIMARY KEY, user_id int NOT NULL REFERENCES dbo.users(id),
  grammar_tree nvarchar(max) NULL, top_errors nvarchar(max) NULL,
  badges nvarchar(max) NULL, weekly_graph nvarchar(max) NULL,
  total_coins int DEFAULT 0, total_stars int DEFAULT 0,
  [level] int DEFAULT 1, exp int DEFAULT 0);
GO
CREATE TABLE dbo.sessions (
  id int IDENTITY(1,1) PRIMARY KEY, user_id int NOT NULL REFERENCES dbo.users(id),
  jwt_token nvarchar(max) NOT NULL, expires_at datetime NOT NULL,
  created_at datetime DEFAULT GETDATE());
GO
CREATE TABLE dbo.teams (
  id int IDENTITY(1,1) PRIMARY KEY, owner_id int NOT NULL REFERENCES dbo.users(id),
  name nvarchar(255) NULL, description nvarchar(max) NULL,
  invite_code nvarchar(255) UNIQUE, created_at datetime DEFAULT GETDATE(),
  is_active bit NOT NULL DEFAULT 1);
GO
CREATE TABLE dbo.team_members (
  id int IDENTITY(1,1) PRIMARY KEY, team_id int NOT NULL REFERENCES dbo.teams(id),
  user_id int NOT NULL REFERENCES dbo.users(id), role nvarchar(50) DEFAULT 'member',
  join_date datetime NULL, CONSTRAINT uq_team_member UNIQUE(team_id, user_id));
GO
CREATE TABLE dbo.tasks (
  id int IDENTITY(1,1) PRIMARY KEY, team_id int NULL REFERENCES dbo.teams(id),
  type nvarchar(50) NULL, criteria nvarchar(max) NULL, reward nvarchar(max) NULL,
  created_by int NOT NULL REFERENCES dbo.users(id), due_date datetime NULL,
  is_active bit DEFAULT 1, created_at datetime DEFAULT GETDATE(), updated_at datetime DEFAULT GETDATE());
GO
CREATE TABLE dbo.task_progress (
  id int IDENTITY(1,1) PRIMARY KEY, task_id int NOT NULL REFERENCES dbo.tasks(id),
  user_id int NOT NULL REFERENCES dbo.users(id),
  current_progress int NULL, target_value int NULL, status nvarchar(50) NULL,
  completed_at datetime NULL, CONSTRAINT uq_task_progress UNIQUE(task_id, user_id));
GO
CREATE TABLE dbo.reports (
  id int IDENTITY(1,1) PRIMARY KEY, user_id int NULL REFERENCES dbo.users(id),
  type nvarchar(50) NULL, description nvarchar(max) NULL, status nvarchar(50) NULL,
  resolved_by int NULL REFERENCES dbo.users(id), resolved_at datetime NULL);
GO
CREATE TABLE dbo.system_logs (
  id int IDENTITY(1,1) PRIMARY KEY, user_id int NULL REFERENCES dbo.users(id),
  action nvarchar(255) NULL, details nvarchar(max) NULL, created_at datetime DEFAULT GETDATE());
GO

-- Indexes
CREATE INDEX ix_users_0 ON dbo.users(grade, region);
CREATE INDEX ix_users_1 ON dbo.users(role);
CREATE INDEX ix_maps ON dbo.maps(grade_id, order_index);
CREATE INDEX ix_games_map ON dbo.games(map_id, order_index);
CREATE INDEX ix_games_type ON dbo.games(game_type);
CREATE INDEX ix_questions_game ON dbo.questions(game_id);
CREATE INDEX ix_questions_type ON dbo.questions(question_type);
CREATE INDEX ix_qg ON dbo.question_grammar(grammar_topic_id);
CREATE INDEX ix_ugp ON dbo.user_grammar_progress(mastery_level);
CREATE INDEX ix_gs1 ON dbo.game_sessions(user_id, completed_at);
CREATE INDEX ix_gs2 ON dbo.game_sessions(game_id);
GO

-- Check Constraints
ALTER TABLE dbo.users ADD CHECK (role IN ('admin','staff','team_owner','user','guest'));
ALTER TABLE dbo.users ADD CHECK (region IN ('Bac','Trung','Nam'));
ALTER TABLE dbo.games ADD CHECK (game_type IN (
  'spelling','punctuation','image_sentence','regional_meaning','grammar','review',
  'multiple_choice','fill_blank','find_error','drag_drop_sentence','listen_choose','picture_guess',
  'listen_catch','rhythm_reading')); -- Cập nhật thêm loại game chữa nói ngọng (listen_catch) và nói lắp (rhythm_reading)
ALTER TABLE dbo.reports ADD CHECK (type IN ('bug','abuse','content'));
ALTER TABLE dbo.reports ADD CHECK (status IN ('pending','investigated','resolved'));
ALTER TABLE dbo.task_progress ADD CHECK (status IN ('pending','in_progress','completed','failed'));
ALTER TABLE dbo.tasks ADD CHECK (type IN ('chapter_completion','coins_target','stars_target','accuracy_target','streak_target'));
ALTER TABLE dbo.team_members ADD CHECK (role IN ('member','leader'));
GO

-- ============================================================
-- 3. BASE DATA
-- ============================================================
INSERT dbo.grades VALUES (1,N'Lớp 1'),(2,N'Lớp 2'),(3,N'Lớp 3'),(4,N'Lớp 4'),(5,N'Lớp 5'),(6,N'Lớp 6'),(7,N'Lớp 7'),(8,N'Lớp 8'),(9,N'Lớp 9'),(10,N'Lớp 10');
GO
SET IDENTITY_INSERT dbo.users ON;
INSERT dbo.users (id,email,phone,password_hash,avatar_url,grade,region,role,is_active,created_at,updated_at) VALUES
(1,N'admin@vneg.vn',N'0901000001',N'$2b$10$hash_admin',N'https://cdn.vneg.vn/av/admin.png',NULL,NULL,N'admin',1,'2026-03-03','2026-03-03'),
(2,N'staff01@vneg.vn',N'0901000002',N'$2b$10$hash_staff1',N'https://cdn.vneg.vn/av/staff1.png',NULL,N'Bac',N'staff',1,'2026-03-03','2026-03-03'),
(3,N'owner01@vneg.vn',N'0901000003',N'$2b$10$hash_own1',N'https://cdn.vneg.vn/av/own1.png',5,N'Trung',N'team_owner',1,'2026-03-03','2026-03-03'),
(4,N'nguyen.van.a@gmail.com',N'0912345601',N'$2b$10$hash_u4',N'https://cdn.vneg.vn/av/u4.png',3,N'Bac',N'user',1,'2026-03-03','2026-03-03'),
(5,N'tran.thi.b@gmail.com',N'0912345602',N'$2b$10$hash_u5',N'https://cdn.vneg.vn/av/u5.png',4,N'Nam',N'user',1,'2026-03-03','2026-03-03'),
(6,N'le.van.c@gmail.com',N'0912345603',N'$2b$10$hash_u6',N'https://cdn.vneg.vn/av/u6.png',6,N'Trung',N'user',1,'2026-03-03','2026-03-03'),
(7,N'pham.thi.d@gmail.com',N'0912345604',N'$2b$10$hash_u7',N'https://cdn.vneg.vn/av/u7.png',2,N'Bac',N'user',1,'2026-03-03','2026-03-03'),
(8,N'hoang.van.e@gmail.com',N'0912345605',N'$2b$10$hash_u8',N'https://cdn.vneg.vn/av/u8.png',5,N'Nam',N'user',1,'2026-03-03','2026-03-03'),
(9,N'do.thi.f@gmail.com',N'0912345606',N'$2b$10$hash_u9',N'https://cdn.vneg.vn/av/u9.png',7,N'Trung',N'user',0,'2026-03-03','2026-03-03'),
(10,N'guest001@vneg.vn',NULL,N'$2b$10$hash_g1',NULL,NULL,N'Bac',N'guest',1,'2026-03-03','2026-03-03');
SET IDENTITY_INSERT dbo.users OFF;
GO
SET IDENTITY_INSERT dbo.grammar_topics ON;
INSERT dbo.grammar_topics (id,parent_id,code,name,description,example,grade_min,grade_max,difficulty,is_active) VALUES
(1,NULL,N'G01',N'Dấu câu',N'Các loại dấu câu trong tiếng Việt',N'Tôi đi học.',1,5,1,1),
(2,NULL,N'G02',N'Viết hoa',N'Quy tắc viết hoa chữ cái',N'Việt Nam là đất nước tôi.',1,9,1,1),
(3,NULL,N'G03',N'Ghép vần',N'Cách ghép âm và vần',N'b + an = ban',1,3,1,1),
(4,NULL,N'G04',N'Chính tả',N'Viết đúng chính tả tiếng Việt',N'quả cam',1,9,2,1),
(5,1,N'G01_01',N'Dấu chấm',N'Dùng dấu chấm kết thúc câu kể',N'Trời hôm nay đẹp.',1,5,1,1),
(6,1,N'G01_02',N'Dấu phẩy',N'Dùng dấu phẩy liệt kê',N'Tôi có bút, thước, sách.',2,9,2,1),
(7,1,N'G01_03',N'Dấu chấm hỏi',N'Dùng sau câu hỏi',N'Bạn tên là gì?',1,9,1,1),
(8,1,N'G01_04',N'Dấu chấm than',N'Dùng sau câu cảm thán',N'Ôi trời ơi!',2,9,2,1),
(9,2,N'G02_01',N'Viết hoa đầu câu',N'Viết hoa chữ cái đầu tiên',N'Hôm nay trời đẹp.',1,3,1,1),
(10,2,N'G02_02',N'Viết hoa tên riêng',N'Viết hoa tên người, địa danh',N'Nguyễn Văn An, Hà Nội',3,9,2,1);
SET IDENTITY_INSERT dbo.grammar_topics OFF;
GO
SET IDENTITY_INSERT dbo.maps ON;
INSERT dbo.maps (id,grade_id,name,order_index,is_active) VALUES
(1,1,N'Bản đồ Rừng Chữ',1,1),(2,1,N'Bản đồ Thung Lũng Vần',2,1),
(3,2,N'Bản đồ Đảo Dấu Câu',1,1),(4,2,N'Bản đồ Núi Chính Tả',2,1),
(5,3,N'Bản đồ Biển Ngữ Pháp',1,1),(6,3,N'Bản đồ Hồ Từ Vựng',2,1),
(7,4,N'Bản đồ Thành Phố Câu',1,1),(8,5,N'Bản đồ Vương Quốc Văn',1,1),
(9,6,N'Bản đồ Thiên Hà Tiếng Việt',1,1),(10,7,N'Bản đồ Vũ Trụ Ngôn Ngữ',1,1);
SET IDENTITY_INSERT dbo.maps OFF;
GO
SET IDENTITY_INSERT dbo.profiles ON;
INSERT dbo.profiles (id,user_id,grammar_tree,top_errors,badges,weekly_graph) VALUES
(1,1,N'{"nodes":[]}',N'[]',N'["admin_badge"]',N'{"week":[0,0,0,0,0,0,0]}'),
(2,2,N'{"nodes":[]}',N'[]',N'["staff_badge"]',N'{"week":[0,0,0,0,0,0,0]}'),
(3,3,N'{"nodes":["G01","G02"]}',N'["dấu câu","viết hoa"]',N'["owner","streak_7"]',N'{"week":[5,3,6,4,7,2,5]}'),
(4,4,N'{"nodes":["G01"]}',N'["dấu phẩy","dấu chấm"]',N'["first_game","streak_3"]',N'{"week":[2,1,3,2,4,1,3]}'),
(5,5,N'{"nodes":["G01","G03"]}',N'["viết hoa"]',N'["first_game"]',N'{"week":[1,2,1,3,2,4,2]}'),
(6,6,N'{"nodes":["G02","G04"]}',N'["ghép vần"]',N'["streak_5","coins_100"]',N'{"week":[4,5,3,6,5,4,6]}'),
(7,7,N'{"nodes":["G01"]}',N'["dấu chấm hỏi"]',N'["first_game"]',N'{"week":[1,0,2,1,0,2,1]}'),
(8,8,N'{"nodes":["G01","G02"]}',N'["viết hoa","dấu phẩy"]',N'["streak_10","coins_500"]',N'{"week":[6,7,5,8,6,7,9]}'),
(9,9,N'{"nodes":[]}',N'[]',N'[]',N'{"week":[0,0,1,0,0,1,0]}'),
(10,10,N'{"nodes":[]}',N'[]',N'[]',N'{"week":[0,0,0,0,0,0,0]}');
SET IDENTITY_INSERT dbo.profiles OFF;
GO
SET IDENTITY_INSERT dbo.teams ON;
INSERT dbo.teams (id,owner_id,name,description,invite_code,created_at,is_active) VALUES
(1,3,N'Đội Sao Bắc Đẩu',N'Nhóm luyện tiếng Việt',N'TEAM_ABC123','2026-03-03',1),
(2,3,N'Nhóm Rồng Vàng',N'Nhóm luyện thi chính tả',N'TEAM_DEF456','2026-03-03',1),
(3,3,N'CLB Tiếng Việt Hay',N'Câu lạc bộ yêu tiếng Việt',N'TEAM_GHI789','2026-03-03',1);
SET IDENTITY_INSERT dbo.teams OFF;
GO
SET IDENTITY_INSERT dbo.team_members ON;
INSERT dbo.team_members (id,team_id,user_id,role,join_date) VALUES
(1,1,3,N'leader','2026-02-01'),(2,1,4,N'member','2026-02-03'),(3,1,5,N'member','2026-02-06'),
(4,1,6,N'member','2026-02-11'),(5,2,3,N'leader','2026-02-11'),(6,2,7,N'member','2026-02-13'),
(7,2,8,N'member','2026-02-16'),(8,3,3,N'leader','2026-02-21'),(9,3,4,N'member','2026-02-23');
SET IDENTITY_INSERT dbo.team_members OFF;
GO
SET IDENTITY_INSERT dbo.tasks ON;
INSERT dbo.tasks (id,team_id,type,criteria,reward,created_by,due_date,is_active,created_at,updated_at) VALUES
(1,1,N'coins_target',N'{"target":100}',N'{"coins":50}',3,'2026-03-10',1,'2026-03-03','2026-03-03'),
(2,1,N'stars_target',N'{"target":30}',N'{"coins":30}',3,'2026-03-10',1,'2026-03-03','2026-03-03');
SET IDENTITY_INSERT dbo.tasks OFF;
GO
SET IDENTITY_INSERT dbo.sessions ON;
INSERT dbo.sessions (id,user_id,jwt_token,expires_at,created_at) VALUES
(1,1,N'eyJ.admin001','2026-04-10','2026-03-03'),
(2,2,N'eyJ.staff001','2026-04-10','2026-03-03'),
(3,3,N'eyJ.owner001','2026-04-10','2026-03-03'),
(4,4,N'eyJ.user004','2026-04-04','2026-03-03'),
(5,5,N'eyJ.user005','2026-04-04','2026-03-03');
SET IDENTITY_INSERT dbo.sessions OFF;
GO
SET IDENTITY_INSERT dbo.user_grammar_progress ON;
INSERT dbo.user_grammar_progress (id,user_id,grammar_topic_id,mastery_level,correct_count,wrong_count,last_practiced_at) VALUES
(1,4,1,75.00,15,5,'2026-03-02'),(2,4,3,60.00,12,8,'2026-03-01'),
(3,5,1,80.00,20,5,'2026-03-02'),(4,6,2,90.00,27,3,'2026-03-02'),
(5,8,1,95.00,38,2,'2026-03-03');
SET IDENTITY_INSERT dbo.user_grammar_progress OFF;
GO


-- ============================================================
-- 4. GAMEPLAY — Games (48 trò, 6 chế độ) + Questions (100+)
-- ============================================================
SET IDENTITY_INSERT dbo.games ON;
INSERT dbo.games (id,map_id,name,game_type,flow,order_index,is_premium,is_active) VALUES
(1,1,N'Ghép Vần Cơ Bản','multiple_choice','{"steps":["intro","question","result"]}',1,0,1),
(2,1,N'Điền Vần Thiếu','fill_blank','{"steps":["intro","question","result"]}',2,0,1),
(3,1,N'Tìm Vần Sai','find_error','{"steps":["intro","question","result"]}',3,0,1),
(4,1,N'Xếp Từ Thành Câu','drag_drop_sentence','{"steps":["intro","question","result"]}',4,0,1),
(5,1,N'Nghe Và Chọn Vần','listen_choose','{"steps":["intro","question","result"]}',5,0,1),
(6,1,N'Nhìn Tranh Đoán Chữ','picture_guess','{"steps":["intro","question","result"]}',6,0,1),
(7,2,N'Đánh Vần Nâng Cao','multiple_choice','{"steps":["intro","question","result"]}',1,0,1),
(8,2,N'Điền Âm Đúng','fill_blank','{"steps":["intro","question","result"]}',2,0,1),
(9,2,N'Soi Lỗi Đánh Vần','find_error','{"steps":["intro","question","result"]}',3,0,1),
(10,2,N'Ghép Câu Từ Vần','drag_drop_sentence','{"steps":["intro","question","result"]}',4,0,1),
(11,2,N'Nghe Phân Biệt Vần','listen_choose','{"steps":["intro","question","result"]}',5,0,1),
(12,2,N'Đoán Vần Qua Ảnh','picture_guess','{"steps":["intro","question","result"]}',6,0,1),
(13,3,N'Chọn Dấu Câu Đúng','multiple_choice','{"steps":["intro","question","result"]}',1,0,1),
(14,3,N'Điền Dấu Câu','fill_blank','{"steps":["intro","question","result"]}',2,0,1),
(15,3,N'Tìm Dấu Sai','find_error','{"steps":["intro","question","result"]}',3,0,1),
(16,3,N'Xếp Câu Có Dấu','drag_drop_sentence','{"steps":["intro","question","result"]}',4,0,1),
(17,3,N'Nghe Và Chọn Dấu','listen_choose','{"steps":["intro","question","result"]}',5,0,1),
(18,3,N'Dấu Câu Qua Ảnh','picture_guess','{"steps":["intro","question","result"]}',6,0,1),
(19,4,N'Chọn Từ Viết Đúng','multiple_choice','{"steps":["intro","question","result"]}',1,0,1),
(20,4,N'Điền Chính Tả','fill_blank','{"steps":["intro","question","result"]}',2,0,1),
(21,4,N'Soi Lỗi Chính Tả','find_error','{"steps":["intro","question","result"]}',3,0,1),
(22,4,N'Xếp Câu Chính Tả','drag_drop_sentence','{"steps":["intro","question","result"]}',4,0,1),
(23,4,N'Nghe Viết Đúng','listen_choose','{"steps":["intro","question","result"]}',5,0,1),
(24,4,N'Chính Tả Qua Ảnh','picture_guess','{"steps":["intro","question","result"]}',6,0,1),
(25,5,N'Ngữ Pháp Câu Đơn','multiple_choice','{"steps":["intro","question","result"]}',1,0,1),
(26,5,N'Điền Từ Ngữ Pháp','fill_blank','{"steps":["intro","question","result"]}',2,0,1),
(27,5,N'Tìm Lỗi Ngữ Pháp','find_error','{"steps":["intro","question","result"]}',3,1,1),
(28,5,N'Xếp Câu Hoàn Chỉnh','drag_drop_sentence','{"steps":["intro","question","result"]}',4,0,1),
(29,5,N'Nghe Hiểu Câu','listen_choose','{"steps":["intro","question","result"]}',5,0,1),
(30,5,N'Ngữ Pháp Qua Ảnh','picture_guess','{"steps":["intro","question","result"]}',6,0,1),
(31,6,N'Chọn Nghĩa Đúng','multiple_choice','{"steps":["intro","question","result"]}',1,0,1),
(32,6,N'Điền Từ Vựng','fill_blank','{"steps":["intro","question","result"]}',2,0,1),
(33,6,N'Tìm Từ Sai Nghĩa','find_error','{"steps":["intro","question","result"]}',3,0,1),
(34,6,N'Xếp Câu Từ Vựng','drag_drop_sentence','{"steps":["intro","question","result"]}',4,0,1),
(35,6,N'Nghe Đoán Nghĩa','listen_choose','{"steps":["intro","question","result"]}',5,0,1),
(36,6,N'Từ Vựng Qua Ảnh','picture_guess','{"steps":["intro","question","result"]}',6,0,1),
(37,7,N'Phân Loại Câu','multiple_choice','{"steps":["intro","question","result"]}',1,1,1),
(38,7,N'Xây Câu Hoàn Chỉnh','drag_drop_sentence','{"steps":["intro","question","result"]}',2,0,1),
(39,7,N'Nghe Và Chọn Câu','listen_choose','{"steps":["intro","question","result"]}',3,0,1),
(40,8,N'Tu Từ và Cấu Trúc','multiple_choice','{"steps":["intro","question","result"]}',1,0,1),
(41,8,N'Điền Từ Văn Học','fill_blank','{"steps":["intro","question","result"]}',2,0,1),
(42,8,N'Di Sản Qua Ảnh','picture_guess','{"steps":["intro","question","result"]}',3,0,1),
(43,9,N'Ôn Tập Tổng Hợp','multiple_choice','{"steps":["intro","question","result"]}',1,0,1),
(44,9,N'Nghe Hiểu Sâu','listen_choose','{"steps":["intro","question","result"]}',2,0,1),
(45,9,N'Tìm Lỗi Nâng Cao','find_error','{"steps":["intro","question","result"]}',3,0,1),
(46,10,N'Xếp Câu Văn Học','drag_drop_sentence','{"steps":["intro","question","result"]}',1,1,1),
(47,10,N'Câu Hỏi Thử Thách','multiple_choice','{"steps":["intro","question","result"]}',2,0,1),
(48,10,N'Điền Từ Thử Thách','fill_blank','{"steps":["intro","question","result"]}',3,0,1),
-- === GAME CHỮA NGỌNG & LẮP ===
(49,1,N'Bắt Chữ Tránh Ngọng (L/N)','listen_catch','{"steps":["intro","gameplay","result"]}',7,0,1),
(50,1,N'Đọc Nhịp Tránh Lắp','rhythm_reading','{"steps":["intro","gameplay","result"]}',8,0,1);
SET IDENTITY_INSERT dbo.games OFF;
GO

-- === DATA CÂU HỎI (Hỗ trợ Ảnh & Âm thanh) ===
SET IDENTITY_INSERT dbo.questions ON;

-- Header thống nhất: (id, game_id, question_type, difficulty, data, answer, image_url, audio_url, explanation, is_active)

-- MAP 1
INSERT dbo.questions (id, game_id, question_type, difficulty, data, answer, image_url, audio_url, explanation, is_active) VALUES
(1, 1, 'multiple_choice', 1, N'{"question":"Vần nào viết đúng?","options":["an","ann","anh","ang"]}', N'an', NULL, NULL, N'Vần "an" chuẩn', 1),
(2, 1, 'multiple_choice', 1, N'{"question":"b + a = ?","options":["ba","bà","bá","bả"]}', N'ba', NULL, NULL, N'Ghép vần cơ bản', 1),
(6, 2, 'fill_blank', 1, N'{"question":"Hôm ___ trời rất đẹp.","hint":"Thời gian"}', N'nay', NULL, NULL, N'Hôm nay', 1),
(11, 3, 'find_error', 1, N'["Tôi","đi","trương"]', N'trương', NULL, NULL, N'trường', 1),
(16, 4, 'drag_drop_sentence', 1, N'["Em","đi","học"]', N'Em đi học', NULL, NULL, N'Câu đơn', 1),
(21, 5, 'listen_choose', 1, N'{"question":"Chọn từ đúng:","options":["Trường","Chường","Xường"]}', N'Trường', NULL, '', N'Tr- đúng', 1),
(24, 6, 'picture_guess', 1, N'{"question":"Con vật này là gì?"}', N'mèo', 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4d/Cat_November_2010-1a.jpg/320px-Cat_November_2010-1a.jpg', NULL, N'Con mèo', 1),
(25, 6, 'picture_guess', 1, N'{"question":"Đây là quả gì?"}', N'táo', 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Red_Apple.jpg/320px-Red_Apple.jpg', NULL, N'Quả táo', 1);

-- MAP 2
INSERT dbo.questions (id, game_id, question_type, difficulty, data, answer, image_url, audio_url, explanation, is_active) VALUES
(26, 7, 'multiple_choice', 1, N'{"question":"Vần đúng: ___ời?","options":["tr","ch","s","x"]}', N'tr', NULL, NULL, N'Trời', 1),
(31, 8, 'fill_blank', 1, N'{"question":"Con ___ bay trên trời.","hint":"Có cánh"}', N'chim', NULL, NULL, N'Con chim', 1),
(36, 9, 'find_error', 1, N'["Trời","nai","đẹp"]', N'nai', NULL, NULL, N'nay', 1),
(41, 10, 'drag_drop_sentence', 1, N'["Bố","đi","làm"]', N'Bố đi làm', NULL, NULL, N'Hành động', 1),
(46, 11, 'listen_choose', 1, N'{"question":"Chọn từ đúng:","options":["Xin chào","Sin chào"]}', N'Xin chào', NULL, '', N'x- chuẩn', 1),
(51, 12, 'picture_guess', 1, N'{"question":"Đây là con vật gì?"}', N'chó', 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/YellowLabradorLooking_new.jpg/320px-YellowLabradorLooking_new.jpg', NULL, N'Con chó', 1);

-- MAP 3
INSERT dbo.questions (id, game_id, question_type, difficulty, data, answer, image_url, audio_url, explanation, is_active) VALUES
(56, 13, 'multiple_choice', 2, N'{"question":"Câu đúng dấu?","options":["Tôi đi học.","Tôi đi học"]}', N'Tôi đi học.', NULL, NULL, N'Dấu chấm', 1),
(61, 14, 'fill_blank', 2, N'{"question":"Bạn tên là gì___","hint":"Hỏi"}', N'?', NULL, NULL, N'Dấu hỏi', 1),
(66, 15, 'find_error', 2, N'["Bạn","ơi.","đợi","tôi"]', N'ơi.', NULL, NULL, N'ơi!', 1),
(71, 16, 'drag_drop_sentence', 2, N'["Bạn","tên","là","gì","?"]', N'Bạn tên là gì ?', NULL, NULL, N'Câu hỏi', 1),
(76, 17, 'listen_choose', 2, N'{"question":"Câu nào là câu hỏi?","options":["Bạn đi đâu?","Tôi đi học."]}', N'Bạn đi đâu?', NULL, '', N'Dấu ?', 1),
(81, 18, 'picture_guess', 2, N'{"question":"Dấu câu phù hợp?"}', N'!', 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/79/Face-surprise.svg/320px-Face-surprise.svg.png', NULL, N'Cảm thán', 1);

-- MAP 4
INSERT dbo.questions (id, game_id, question_type, difficulty, data, answer, image_url, audio_url, explanation, is_active) VALUES
(86, 19, 'multiple_choice', 2, N'{"question":"Từ viết đúng?","options":["quả cam","quã cam"]}', N'quả cam', 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c4/Orange-Fruit-Pieces.jpg/320px-Orange-Fruit-Pieces.jpg', NULL, N'Chính tả', 1),
(91, 20, 'fill_blank', 2, N'{"question":"Tiếng Việt dùng hệ chữ ___.","hint":"Latinh"}', N'Latinh', NULL, NULL, N'Lịch sử', 1),
(96, 21, 'find_error', 2, N'["Mùa","xuân","hoa","đào","nỡ"]', N'nỡ', NULL, NULL, N'nở', 1),
(101, 22, 'drag_drop_sentence', 2, N'["Tiếng Việt","rất","giàu","thanh điệu"]', N'Tiếng Việt rất giàu thanh điệu', NULL, NULL, N'Ngữ pháp', 1),
(106, 23, 'listen_choose', 2, N'{"question":"Chọn phiên âm đúng:","options":["Giáo dục","Záo dục"]}', N'Giáo dục', NULL, '', N'gi-', 1),
(111, 24, 'picture_guess', 2, N'{"question":"Đây là di sản nào?"}', N'vịnh hạ long', 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/18/Ha_Long_Bay_%28V%E1%BB%8Bnh_H%E1%BA%A1_Long%29.jpg/320px-Ha_Long_Bay_%28V%E1%BB%8Bnh_H%E1%BA%A1_Long%29.jpg', NULL, N'Vịnh Hạ Long', 1),
(112, 24, 'picture_guess', 2, N'{"question":"Trang phục này là gì?"}', N'áo dài', 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/07/Ao_dai%2C_bao_tang_ao_dai%2C_HCMC.jpg/320px-Ao_dai%2C_bao_tang_ao_dai%2C_HCMC.jpg', NULL, N'Áo dài', 1);

-- MAP 5 & 6
INSERT dbo.questions (id, game_id, question_type, difficulty, data, answer, image_url, audio_url, explanation, is_active) VALUES
(116, 25, 'multiple_choice', 2, N'{"question":"Từ loại là tính từ?","options":["Xinh đẹp","Chạy nhảy"]}', N'Xinh đẹp', NULL, NULL, N'Tính từ', 1),
(121, 26, 'fill_blank', 2, N'{"question":"Từ ___ nghĩa là từ giống nhau.","hint":"đồng"}', N'đồng', NULL, NULL, N'Đồng nghĩa', 1),
(126, 27, 'find_error', 2, N'["Em","thường","xuyên","độp","sách"]', N'độp', NULL, NULL, N'đọc', 1),
(131, 28, 'drag_drop_sentence', 2, N'["Quê hương","là","chùm khế ngọt"]', N'Quê hương là chùm khế ngọt', NULL, NULL, N'Thơ', 1),
(136, 29, 'listen_choose', 2, N'{"question":"Câu đúng:","options":["Tôi đang đi học.","Đang tôi đi học."]}', N'Tôi đang đi học.', NULL, '', N'Trạng từ', 1),
(141, 30, 'picture_guess', 2, N'{"question":"Đây là món gì?"}', N'phở', 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Pho-Beef-Noodles-2008.jpg/320px-Pho-Beef-Noodles-2008.jpg', NULL, N'Phở', 1),
(146, 31, 'multiple_choice', 2, N'{"question":"Miền Bắc gọi bắp là?","options":["ngô","khoai"]}', N'ngô', 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/af/Corn_on_the_cob__yellow_corn.JPG/320px-Corn_on_the_cob__yellow_corn.JPG', NULL, N'Phương ngữ', 1),
(151, 33, 'find_error', 2, N'["Quả","xoài","ngọc","lịm"]', N'ngọc', NULL, NULL, N'ngọt', 1),
(152, 33, 'find_error', 2, N'["Tôi","rất","thik","ăn","phở"]', N'thik', NULL, NULL, N'thích', 1);

-- MAP NÂNG CAO (7-10)
INSERT dbo.questions (id, game_id, question_type, difficulty, data, answer, image_url, audio_url, explanation, is_active) VALUES
(161, 37, 'multiple_choice', 3, N'{"question":"Càng học ___ thấy thiếu sót.","options":["càng","thì"]}', N'càng', NULL, NULL, N'Cấu trúc', 1),
(166, 38, 'drag_drop_sentence', 3, N'["Chúng ta","cần","bảo tồn","di sản"]', N'Chúng ta cần bảo tồn di sản', NULL, NULL, N'Câu dài', 1),
(171, 40, 'multiple_choice', 3, N'{"question":"Vì trời mưa ___ đường trơn.","options":["nên","nhưng"]}', N'nên', NULL, NULL, N'Nguyên nhân', 1),
(176, 42, 'picture_guess', 3, N'{"question":"Di tích nào đây?"}', N'chùa một cột', 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7f/Chua_Mot_Cot.jpg/320px-Chua_Mot_Cot.jpg', NULL, N'Lịch sử', 1),
(181, 46, 'drag_drop_sentence', 3, N'["Sách","là","kho tàng","tri thức"]', N'Sách là kho tàng tri thức', NULL, NULL, N'Danh ngôn', 1),
(186, 48, 'fill_blank', 3, N'{"question":"Ẩn ___ là so sánh ngầm.","hint":"dụ"}', N'dụ', NULL, NULL, N'Biện pháp tu từ', 1),

-- ============================================================
-- === CHỮA NÓI NGỌNG (L/N, TR/CH) (game_type = 'listen_catch')
-- ============================================================
-- HƯỚNG DẪN UPDATE: Thêm cặp từ dễ nhầm lẫn vào mảng 'options' trong cột 'data'.
-- 'audio_url' là link file âm thanh đọc chuẩn của hệ thống để học sinh nghe.
(191, 49, 'listen_catch', 1, N'{"question":"Nghe và bắt từ đánh vần đúng","options":["lên non", "nên non"]}', N'lên non', NULL, 'res://assets/audio/len_non.mp3', N'Phân biệt L/N', 1),
(192, 49, 'listen_catch', 1, N'{"question":"Nghe và bắt từ đánh vần đúng","options":["trời trong", "chời chong"]}', N'trời trong', NULL, 'res://assets/audio/troi_trong.mp3', N'Phân biệt TR/CH', 1),

-- ============================================================
-- === CHỮA NÓI LẮP (RHYTHM READING) (game_type = 'rhythm_reading')
-- ============================================================
-- HƯỚNG DẪN UPDATE: 'bpm' là tốc độ nhịp (nhịp/phút) quy định tốc độ nhảy của chữ. 
-- Điều chỉnh BPM thấp (khoảng 60) để đọc thong thả. 
-- 'lyrics' là mảng các từ ngữ, chúng sẽ sáng lên lần lượt theo nhịp BPM.
(196, 50, 'rhythm_reading', 1, N'{"bpm":60,"lyrics":["Hôm","nay","trời","rất","đẹp","và","trong","xanh"]}', N'Hôm nay trời rất đẹp và trong xanh', NULL, NULL, N'Tốc độ chậm để uốn giọng', 1);

SET IDENTITY_INSERT dbo.questions OFF;
GO

-- === MAPPING TIẾN TRÌNH (Grammar Progress) ===
INSERT dbo.question_grammar (question_id, grammar_topic_id, weight) VALUES
-- Dấu câu (Topic 1, 7, 8)
(56, 1, 1), (61, 7, 1), (66, 8, 1), (71, 1, 1), (76, 1, 1), (81, 1, 1),
-- Ghép vần (Topic 3)
(1, 3, 1), (2, 3, 1), (6, 3, 1), (11, 3, 1), (16, 3, 1), (21, 3, 1), (24, 3, 1),
-- Chính tả (Topic 4)
(86, 4, 1), (91, 4, 1), (96, 4, 1), (101, 4, 1), (106, 4, 1), (111, 4, 1),
-- Viết hoa & Câu (Topic 2, 9, 10)
(161, 2, 1), (166, 10, 1), (181, 10, 1),
-- Ngọng & Lắp (Topic 3: Ghép vần, Topic 1: Dấu câu (nhịp))
(191, 3, 1), (192, 3, 1), (196, 1, 1);
GO

UPDATE dbo.questions 
SET audio_url = 'https://actions.google.com/sounds/v1/alarms/beep_short.ogg' 
WHERE game_id = 49;

UPDATE dbo.questions 
SET audio_url = 'res://assets/audio/len_non.mp3' 
WHERE id = 191;

UPDATE dbo.questions 
SET audio_url = 'res://assets/audio/troi_trong.mp3' 
WHERE id = 192;


-- KIỂM TRA
SELECT N'Maps' AS [Bảng], COUNT(*) AS [Số lượng] FROM dbo.maps
UNION ALL SELECT N'Games', COUNT(*) FROM dbo.games
UNION ALL SELECT N'Questions', COUNT(*) FROM dbo.questions;
GO
PRINT N'VNEG_System - HOAN TAT!';
PRINT N'10 Maps - 50 Games - 100+ Cau hoi';
PRINT N'8 che do: multiple_choice, fill_blank, find_error, drag_drop_sentence, listen_choose, picture_guess, listen_catch (Ngọng), rhythm_reading (Lắp)';
GO