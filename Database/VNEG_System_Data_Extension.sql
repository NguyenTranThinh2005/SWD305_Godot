-- ====================================================================
-- VNEG_System_Data_Extension.sql
-- KỊCH BẢN THÊM 40 CÂU HỎI MỚI CHO 8 CHẾ ĐỘ CHƠI (MAP 1)
-- Anh chạy script này trong SSMS sau khi đã chạy file Full nhé!
-- ====================================================================
USE VNEG_System;
GO

SET IDENTITY_INSERT dbo.questions OFF;

-- 1. multiple_choice (game_id = 1) -> 5 câu
INSERT dbo.questions (game_id, question_type, difficulty, data, answer, image_url, audio_url, explanation, is_active) VALUES
(1, 'multiple_choice', 1, N'{"question":"m + e + huyền = ?","options":["mẻ","mẹ","mè","mé"]}', N'mè', NULL, NULL, N'Dấu huyền', 1),
(1, 'multiple_choice', 1, N'{"question":"b + ố = ?","options":["bố","bộ","bồ","bổ"]}', N'bố', NULL, NULL, N'Ghép âm b và ố', 1),
(1, 'multiple_choice', 1, N'{"question":"Vần nào viết đúng?","options":["ong","oong","ogn","onng"]}', N'ong', NULL, NULL, N'Vần ong', 1),
(1, 'multiple_choice', 1, N'{"question":"c + á = ?","options":["cá","cà","cả","cạ"]}', N'cá', NULL, NULL, N'Dấu sắc', 1),
(1, 'multiple_choice', 1, N'{"question":"ch + ó = ?","options":["chó","chò","chỏ","chọ"]}', N'chó', NULL, NULL, N'Âm ch', 1);

-- 2. fill_blank (game_id = 2) -> 5 câu
INSERT dbo.questions (game_id, question_type, difficulty, data, answer, image_url, audio_url, explanation, is_active) VALUES
(2, 'fill_blank', 1, N'{"question":"Trời ___ tuôn rơi.","hint":"Nước từ trên mây rơi xuống"}', N'mưa', NULL, NULL, N'Hiện tượng thời tiết', 1),
(2, 'fill_blank', 1, N'{"question":"Tôi đi ___ về.","hint":"Nơi có thầy cô giáo"}', N'học', NULL, NULL, N'Trường lớp', 1),
(2, 'fill_blank', 1, N'{"question":"Mẹ đi ___ mua rau.","hint":"Nơi bán thức đồ ăn uống"}', N'chợ', NULL, NULL, N'Chợ', 1),
(2, 'fill_blank', 1, N'{"question":"Chim ___ trên cành cây.","hint":"Tiếng của chim"}', N'hót', NULL, NULL, N'Tiếng chim hót', 1),
(2, 'fill_blank', 1, N'{"question":"Bé ăn ___ rất ngon.","hint":"Món ăn vặt ngọt"}', N'chè', NULL, NULL, N'Món chè', 1);

-- 3. find_error (game_id = 3) -> 5 câu
INSERT dbo.questions (game_id, question_type, difficulty, data, answer, image_url, audio_url, explanation, is_active) VALUES
(3, 'find_error', 1, N'["Con","mèo","kêu","meo","meoo"]', N'meoo', NULL, NULL, N'Phải là: meo', 1),
(3, 'find_error', 1, N'["Tôi","học","bài","rất","chăm"]', N'hóc', NULL, NULL, N'Phải là: học', 1),
(3, 'find_error', 1, N'["Quyển","sát","này","rất","hay"]', N'sát', NULL, NULL, N'Phải là: sách', 1),
(3, 'find_error', 1, N'["Cây","cối","xanh","tươi","mátt"]', N'mátt', NULL, NULL, N'Phải là: mát', 1),
(3, 'find_error', 1, N'["Hôm","lay","tôi","đi","chơi"]', N'lay', NULL, NULL, N'Phải là: nay', 1);

-- 4. drag_drop_sentence (game_id = 4) -> 5 câu
INSERT dbo.questions (game_id, question_type, difficulty, data, answer, image_url, audio_url, explanation, is_active) VALUES
(4, 'drag_drop_sentence', 1, N'["Trời","đang","mưa","to"]', N'Trời đang mưa to', NULL, NULL, N'Câu miêu tả thời tiết', 1),
(4, 'drag_drop_sentence', 1, N'["Mẹ","nấu","cơm","rất","ngon"]', N'Mẹ nấu cơm rất ngon', NULL, NULL, N'Câu miêu tả hành động', 1),
(4, 'drag_drop_sentence', 1, N'["Chim","bay","lượn","trên","trời"]', N'Chim bay lượn trên trời', NULL, NULL, N'Câu miêu tả cảnh vật', 1),
(4, 'drag_drop_sentence', 1, N'["Hoa","nở","vào","mùa","xuân"]', N'Hoa nở vào mùa xuân', NULL, NULL, N'Quy luật tự nhiên', 1),
(4, 'drag_drop_sentence', 1, N'["Tôi","rất","yêu","gia","đình"]', N'Tôi rất yêu gia đình', NULL, NULL, N'Câu bộc lộ tình cảm', 1);

-- 5. listen_choose (game_id = 5) -> 5 câu
INSERT dbo.questions (game_id, question_type, difficulty, data, answer, image_url, audio_url, explanation, is_active) VALUES
(5, 'listen_choose', 1, N'{"question":"Nghe và chọn từ đúng:","options":["Sách","Xách"]}', N'Sách', NULL, 'res://assets/audio/sach.mp3', N'Phân biệt S/X', 1),
(5, 'listen_choose', 1, N'{"question":"Nghe và chọn từ đúng:","options":["Nước","Lước"]}', N'Nước', NULL, 'res://assets/audio/nuoc.mp3', N'Phân biệt L/N', 1),
(5, 'listen_choose', 1, N'{"question":"Nghe và chọn từ đúng:","options":["Sông","Xông"]}', N'Sông', NULL, 'res://assets/audio/song.mp3', N'Phân biệt S/X', 1),
(5, 'listen_choose', 1, N'{"question":"Nghe và chọn từ đúng:","options":["Rắn","Dắn"]}', N'Rắn', NULL, 'res://assets/audio/ran.mp3', N'Phân biệt R/D', 1),
(5, 'listen_choose', 1, N'{"question":"Nghe và chọn từ đúng:","options":["Trời","Chời"]}', N'Trời', NULL, 'res://assets/audio/troi.mp3', N'Phân biệt TR/CH', 1);

-- 6. picture_guess (game_id = 6) -> 5 câu
INSERT dbo.questions (game_id, question_type, difficulty, data, answer, image_url, audio_url, explanation, is_active) VALUES
(6, 'picture_guess', 1, N'{"question":"Đây là cái gì?"}', N'sách', 'res://assets/images/book_vneg.png', NULL, N'Quyển sách', 1),
(6, 'picture_guess', 1, N'{"question":"Đây là gì?"}', N'cây', 'res://assets/images/tree_vneg.png', NULL, N'Cái cây cối', 1),
(6, 'picture_guess', 1, N'{"question":"Đây là phương tiện gì?"}', N'xe', 'res://assets/images/car_vneg.png', NULL, N'Xe hơi / ô tô', 1),
(6, 'picture_guess', 1, N'{"question":"Cái gì sáng rực ban ngày?"}', N'mặt trời', 'res://assets/images/sun_vneg.png', NULL, N'Ông mặt trời', 1),
(6, 'picture_guess', 1, N'{"question":"Nơi gia đình sinh sống gọi là gì?"}', N'nhà', 'res://assets/images/house_vneg.png', NULL, N'Ngôi nhà', 1);

-- 7. listen_catch (Ngọng) (game_id = 49) -> 5 câu
INSERT dbo.questions (game_id, question_type, difficulty, data, answer, image_url, audio_url, explanation, is_active) VALUES
(49, 'listen_catch', 1, N'{"question":"Nghe và bắt từ đánh vần đúng","options":["làm lụng", "nàm nụng"]}', N'làm lụng', NULL, 'res://assets/audio/lam_lung.mp3', N'Chữ L', 1),
(49, 'listen_catch', 1, N'{"question":"Nghe và bắt từ đánh vần đúng","options":["chăm chỉ", "trăm chỉ"]}', N'chăm chỉ', NULL, 'res://assets/audio/cham_chi.mp3', N'Chữ CH', 1),
(49, 'listen_catch', 1, N'{"question":"Nghe và bắt từ đánh vần đúng","options":["lấp lánh", "lấp nánh"]}', N'lấp lánh', NULL, 'res://assets/audio/lap_lanh.mp3', N'Chữ L', 1),
(49, 'listen_catch', 1, N'{"question":"Nghe và bắt từ đánh vần đúng","options":["trong trẻo", "chong trẻo"]}', N'trong trẻo', NULL, 'res://assets/audio/trong_treo.mp3', N'Chữ TR', 1),
(49, 'listen_catch', 1, N'{"question":"Nghe và bắt từ đánh vần đúng","options":["nỗ lực", "lỗ lực"]}', N'nỗ lực', NULL, 'res://assets/audio/no_luc.mp3', N'Chữ N và L', 1);

-- 8. rhythm_reading (Đọc nhịp tránh lắp) (game_id = 50) -> 5 câu
INSERT dbo.questions (game_id, question_type, difficulty, data, answer, image_url, audio_url, explanation, is_active) VALUES
(50, 'rhythm_reading', 1, N'{"bpm":65,"lyrics":["Tôi","đi","học","rất","ngoan","và","chăm"]}', N'Tôi đi học rất ngoan và chăm', NULL, NULL, N'Luyện đọc nhịp độ trung bình 65 BPM', 1),
(50, 'rhythm_reading', 1, N'{"bpm":75,"lyrics":["Mặt","trời","lên","cao","chiếu","sáng","chói"]}', N'Mặt trời lên cao chiếu sáng chói', NULL, NULL, N'Luyện đọc nhịp độ 75 BPM', 1),
(50, 'rhythm_reading', 1, N'{"bpm":60,"lyrics":["Đường","về","nhà","rất","đẹp","và","vui"]}', N'Đường về nhà rất đẹp và vui', NULL, NULL, N'Luyện đọc chậm rãi 60 BPM', 1),
(50, 'rhythm_reading', 1, N'{"bpm":80,"lyrics":["Lá","rơi","lác","đác","mùa","thu","đến"]}', N'Lá rơi lác đác mùa thu đến', NULL, NULL, N'Luyện đọc nhanh 80 BPM', 1),
(50, 'rhythm_reading', 1, N'{"bpm":65,"lyrics":["Nước","chảy","róc","rách","qua","khe","đá"]}', N'Nước chảy róc rách qua khe đá', NULL, NULL, N'Luyện phát âm phụ âm R', 1);

PRINT N'DA THEM THANH CONG 40 CAU HOI MOI CHO 8 CHE DO VNEG!';
GO
