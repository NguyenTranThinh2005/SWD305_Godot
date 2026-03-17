using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SWD305.Models;
using SystemTask = System.Threading.Tasks.Task;

namespace SWD305.Controllers
{
    [Route("api/admin/seed-fix")]
    [ApiController]
    public class SeedFixController : ControllerBase
    {
        private readonly VnegSystemContext _context;

        public SeedFixController(VnegSystemContext context)
        {
            _context = context;
        }

        private static string GetWikiUrl(string filename)
        {
            return $"https://commons.wikimedia.org/wiki/Special:Redirect/file/{Uri.EscapeDataString(filename.Replace(" ", "_"))}";
        }

        [HttpPost]
        public async Task<IActionResult> Seed()
        {
            await _context.Database.ExecuteSqlRawAsync("DELETE FROM dbo.game_error_grammar;");
            await _context.Database.ExecuteSqlRawAsync("DELETE FROM dbo.game_errors;");
            await _context.Database.ExecuteSqlRawAsync("DELETE FROM dbo.game_sessions;");
            await _context.Database.ExecuteSqlRawAsync("DELETE FROM dbo.question_grammar;");
            await _context.Database.ExecuteSqlRawAsync("DELETE FROM dbo.questions;");
            await _context.Database.ExecuteSqlRawAsync("DELETE FROM dbo.games;");
            await _context.Database.ExecuteSqlRawAsync("DELETE FROM dbo.maps;");

            await _context.Database.ExecuteSqlRawAsync("DBCC CHECKIDENT ('dbo.maps', RESEED, 0); DBCC CHECKIDENT ('dbo.games', RESEED, 0); DBCC CHECKIDENT ('dbo.questions', RESEED, 0);");

            if (!await _context.Grades.AnyAsync(g => g.Id == 1)) _context.Grades.Add(new Grade { Id = 1, Name = "Lớp 1" });
            if (!await _context.Grades.AnyAsync(g => g.Id == 2)) _context.Grades.Add(new Grade { Id = 2, Name = "Lớp 2" });
            if (!await _context.Grades.AnyAsync(g => g.Id == 3)) _context.Grades.Add(new Grade { Id = 3, Name = "Lớp 3" });
            await _context.SaveChangesAsync();

            var mapSoCap   = new Map { GradeId = 1, Name = "Sơ Cấp",   OrderIndex = 1, IsActive = true };
            var mapTrungCap = new Map { GradeId = 2, Name = "Trung Cấp", OrderIndex = 2, IsActive = true };
            var mapCaoCap  = new Map { GradeId = 3, Name = "Cao Cấp",   OrderIndex = 3, IsActive = true };
            _context.Maps.AddRange(mapSoCap, mapTrungCap, mapCaoCap);
            await _context.SaveChangesAsync();

            await SeedMap(_context, mapSoCap,    1);
            await SeedMap(_context, mapTrungCap, 2);
            await SeedMap(_context, mapCaoCap,   3);

            return Ok(new
            {
                Message = "Seeding completed with real question bank (V6-ULTIMATE)!",
                TotalQuestions = await _context.Questions.CountAsync()
            });
        }

        [HttpGet("debug-questions")]
        public async Task<IActionResult> DebugQuestions()
        {
            var questions = await _context.Questions
                .Where(q => q.QuestionType == "listen_choose" || q.QuestionType == "picture_guess")
                .ToListAsync();
            return Ok(questions);
        }

        private static async System.Threading.Tasks.Task SeedMap(VnegSystemContext ctx, Map map, int difficulty)
        {
            var gameTypes = new (string Name, string Type)[]
            {
                ("Ngữ Pháp",   "multiple_choice"),
                ("Chính Tả",   "fill_blank"),
                ("Nhìn Tranh", "picture_guess"),
                ("Vùng Miền",  "listen_choose"),
                ("Xếp Câu",    "drag_drop_sentence"),
                ("Ôn Tập",     "find_error"),
            };

            foreach (var (name, type) in gameTypes.Select((x, i) => (x, i)))
            {
                var game = new Game
                {
                    MapId      = map.Id,
                    Name       = name.Name,
                    GameType   = name.Type,
                    OrderIndex = type + 1,
                    IsPremium  = false
                };
                ctx.Games.Add(game);
                await ctx.SaveChangesAsync();

                var questions = BuildQuestions(game.Id, name.Type, difficulty);
                ctx.Questions.AddRange(questions);
                await ctx.SaveChangesAsync();
            }
        }

        private static List<Question> BuildQuestions(int gameId, string gameType, int difficulty)
        {
            return gameType switch
            {
                "multiple_choice"    => MultipleChoice(gameId, difficulty),
                "fill_blank"         => FillBlank(gameId, difficulty),
                "picture_guess"      => PictureGuess(gameId, difficulty),
                "listen_choose"      => ListenChoose(gameId, difficulty),
                "drag_drop_sentence" => DragDropSentence(gameId, difficulty),
                "find_error"         => FindError(gameId, difficulty),
                _                    => MultipleChoice(gameId, difficulty),
            };
        }

        private static List<Question> MultipleChoice(int gameId, int diff)
        {
            var banks = new Dictionary<int, List<(string data, string answer, string explanation)>>
            {
                [1] = new()
                {
                    ("[\"Hôm nay em đi học ở trường.\", \"Hôm nay em học ở đi trường.\", \"Trường học ở em hôm nay đi.\"]", "Hôm nay em đi học ở trường.", "Chọn câu có trật tự từ đúng nhất:"),
                    ("[\"Con mèo đang nằm ngủ trên sân.\", \"Nằm ngủ đang con mèo trên sân.\", \"Trên sân con mèo nằm ngủ đang.\"]", "Con mèo đang nằm ngủ trên sân.", "Chọn câu miêu tả hành động đúng:"),
                    ("[\"Mẹ em đang nấu cơm ở trong bếp.\", \"Bếp trong ở cơm nấu đang mẹ em.\", \"Mẹ em nấu cơm đang bếp ở trong.\"]", "Mẹ em đang nấu cơm ở trong bếp.", "Chọn cấu trúc câu khẳng định đúng:"),
                    ("[\"Bầu trời hôm nay rất xanh và cao.\", \"Bầu trời xanh và cao rất hôm nay.\", \"Hôm nay rất xanh và cao bầu trời.\"]", "Bầu trời hôm nay rất xanh và cao.", "Chọn câu miêu tả thời tiết đúng:"),
                    ("[\"Em rất thích ăn quả táo đỏ này.\", \"Em quả táo đỏ này rất thích ăn.\", \"Thích ăn rất em quả táo đỏ này.\"]", "Em rất thích ăn quả táo đỏ này.", "Chọn câu thể hiện sở thích đúng:"),
                    ("[\"Bố em đi làm lúc bảy giờ sáng.\", \"Bảy giờ sáng lúc bố em đi làm.\", \"Làm đi bố em lúc bảy giờ sáng.\"]", "Bố em đi làm lúc bảy giờ sáng.", "Chọn câu chỉ thời gian hành động:"),
                },
                [2] = new()
                {
                    ("[\"Mặc dù trời mưa to nhưng tôi vẫn đi học.\", \"Trời mưa to mặc dù nhưng tôi vẫn đi học.\", \"Tôi vẫn đi học nhưng mặc dù trời mưa to.\"]", "Mặc dù trời mưa to nhưng tôi vẫn đi học.", "Chọn cặp quan hệ từ tương phản đúng:"),
                    ("[\"Cuốn sách mà bạn cho tôi mượn rất hay.\", \"Hay rất cuốn sách mà bạn cho tôi mượn.\", \"Bạn cho tôi mượn cuốn sách mà rất hay.\"]", "Cuốn sách mà bạn cho tôi mượn rất hay.", "Chọn câu có mệnh đề phụ quan hệ đúng:"),
                    ("[\"Nếu không chăm chỉ thì kết quả sẽ kém.\", \"Thì kết quả sẽ kém nếu không chăm chỉ.\", \"Chăm chỉ không nếu thì kết quả sẽ kém.\"]", "Nếu không chăm chỉ thì kết quả sẽ kém.", "Chọn cặp quan hệ từ giả thiết - kết quả:"),
                    ("[\"Cô ấy vừa xinh đẹp lại vừa thông minh.\", \"Cô ấy xinh đẹp lại thông minh vừa vừa.\", \"Vừa vừa xinh đẹp cô ấy lại thông minh.\"]", "Cô ấy vừa xinh đẹp lại vừa thông minh.", "Chọn cấu trúc liệt kê tính chất:"),
                    ("[\"Tôi đã hoàn thành bài tập về nhà rồi.\", \"Bài tập về nhà tôi đã hoàn thành rồi.\", \"Tôi hoàn thành bài tập về nhà đã rồi.\"]", "Tôi đã hoàn thành bài tập về nhà rồi.", "Chọn câu ở thì hoàn thành đúng nhất:"),
                    ("[\"Họ đang thảo luận về dự án mới này.\", \"Dự án mới này họ đang thảo luận về.\", \"Thảo luận về họ dự án mới này đang.\"]", "Họ đang thảo luận về dự án mới này.", "Chọn cấu trúc thảo luận vấn đề:"),
                },
                [3] = new()
                {
                    ("[\"Bức tranh này do chính tay họa sĩ vẽ.\", \"Vẽ bức tranh này họa sĩ do chính tay.\", \"Họa sĩ vẽ chính tay do bức tranh này.\"]", "Bức tranh này do chính tay họa sĩ vẽ.", "Chọn cấu trúc nhấn mạnh tác giả (bị động):"),
                    ("[\"Anh ấy làm việc một cách rất chuyên nghiệp.\", \"Cách một làm việc một anh ấy rất chuyên nghiệp.\", \"Chuyên nghiệp rất cách một anh ấy làm việc.\"]", "Anh ấy làm việc một cách rất chuyên nghiệp.", "Chọn cấu trúc trạng ngữ chỉ cách thức:"),
                    ("[\"Vì lợi ích chung, chúng ta cần đoàn kết.\", \"Chúng ta cần đoàn kết vì lợi ích chung.\", \"Lợi ích chung vì chúng ta cần đoàn kết.\"]", "Vì lợi ích chung, chúng ta cần đoàn kết.", "Chọn cấu trúc nêu mục đích đảo lên đầu:"),
                    ("[\"Quyển sách được viết bởi một tác giả nổi tiếng.\", \"Được viết bởi một tác giả nổi tiếp quyển sách.\", \"Một tác giả nổi tiếng bởi viết được quyển sách.\"]", "Quyển sách được viết bởi một tác giả nổi tiếng.", "Chọn cấu trúc câu bị động chuẩn mực:"),
                    ("[\"Càng học, chúng ta càng thấy mình còn thiếu sót.\", \"Chúng ta càng thấy mình còn thiếu sót càng học.\", \"Càng thấy mình thiếu sót chúng ta càng học.\"]", "Càng học, chúng ta càng thấy mình còn thiếu sót.", "Chọn cấu trúc so sánh tăng tiến:"),
                    ("[\"Chẳng những học giỏi mà Nam còn rất lễ phép.\", \"Học giỏi chẳng những mà Nam còn rất lễ phép.\", \"Nam còn rất lễ phép chẳng những học giỏi mà.\"]", "Chẳng những học giỏi mà Nam còn rất lễ phép.", "Chọn cặp quan hệ từ tăng cường:"),
                },
            };

            var result = new List<Question>();
            var bank = banks[diff];
            foreach (var item in bank)
            {
                result.Add(new Question
                {
                    GameId = gameId,
                    QuestionType = "multiple_choice",
                    Difficulty = diff,
                    Data = item.data,
                    Answer = item.answer,
                    Explanation = item.explanation,
                    IsActive = true,
                });
            }
            return result;
        }

        private static List<Question> FillBlank(int gameId, int diff)
        {
            var banks = new Dictionary<int, List<(string data, string answer)>>
            {
                [1] = new()
                {
                    ("Con m..o kêu meo meo", "è"),
                    ("Bầu tr..i xanh biếc", "ờ"),
                    ("Em ..i học về", "đ"),
                    ("Hoa hồng m..u đỏ", "à"),
                    ("Trường h..c của em", "ọ"),
                    ("Nắng m..a vàng óng", "ặ"),
                },
                [2] = new()
                {
                    ("Tiếng Việt dùng hệ ch.. Latinh", "ữ"),
                    ("Chữ 'ng' là phụ âm g..p", "h"),
                    ("Dấu hỏi đặt tr..n chữ cái", "ê"),
                    ("Câu ghép gồm hai m..nh đề", "ệ"),
                    ("Từ đồng âm g..y hiểu nhầm", "â"),
                    ("Trạng ngữ đứng đ..u câu", "ầ"),
                },
                [3] = new()
                {
                    ("Phong cách ngôn ngữ khoa h..c", "ọ"),
                    ("Biện pháp tu từ nh..n hoá", "â"),
                    ("Sử dụng d..u chấm lửng đúng lúc", "ấ"),
                    ("Câu rút g..n thường thiếu chủ ngữ", "ọ"),
                    ("Liên kết c..u bằng phép nối", "â"),
                    ("Diễn đạt bóng b..y dùng ẩn dụ", "ẩ"),
                },
            };

            return MakeQuestions(gameId, "fill_blank", diff, banks[diff]);
        }

        private static List<Question> PictureGuess(int gameId, int diff)
        {
            var banks = new Dictionary<int, List<(string data, string answer, string? imgUrl, string hint)>>
            {
                [1] = new()
                {
                    ("Con vật này là gì?", "Con mèo", "https://upload.wikimedia.org/wikipedia/commons/3/3a/Cat03.jpg", "[V6-ULTIMATE] Con vật này hay kêu meo meo và thích bắt chuột."),
                    ("Con vật này là gì?", "Con chó", "https://upload.wikimedia.org/wikipedia/commons/0/0a/B%E1%BA%AFc_H%C3%A0_dog_side.jpg", "[V6-ULTIMATE] Loài vật trung thành, hay sủa gâu gâu."),
                    ("Đây là quả gì?", "Quả táo", "https://upload.wikimedia.org/wikipedia/commons/1/15/Red_Apple.jpg", "[V6-ULTIMATE] Quả có màu đỏ, giòn và ngọt, rất tốt cho sức khỏe."),
                    ("Đây là quả gì?", "Quả chuối", "https://upload.wikimedia.org/wikipedia/commons/9/98/Bananas_on_black_background_02.jpg", "[V6-ULTIMATE] Quả có hình dáng dài, vỏ màu vàng khi chín."),
                    ("Phương tiện này là gì?", "Xe đạp", "https://upload.wikimedia.org/wikipedia/commons/3/33/Hue_Vietnam_Nun-with-bicycle-01.jpg", "[V6-ULTIMATE] Phương tiện có hai bánh, chạy bằng sức người đạp."),
                    ("Phương tiện này là gì?", "Xe máy", "https://upload.wikimedia.org/wikipedia/commons/d/d2/Honda_Super_Cub_with_watering_can.jpg", "[V6-ULTIMATE] Phương tiện phổ biến nhất tại Việt Nam, có động cơ và hai bánh."),
                },
                [2] = new()
                {
                    ("Hình ảnh này biểu trưng cho?", "Hòa bình", "https://upload.wikimedia.org/wikipedia/commons/4/44/A_White_Dove_at_Alnwick_gardens_-_panoramio_%281%29.jpg", "[V6-ULTIMATE] Chim bồ câu trắng mang thông điệp này."),
                    ("Đây là loài cây biểu tượng của VN?", "Cây tre", "https://upload.wikimedia.org/wikipedia/commons/2/20/Bamboo_tree_showing_stalk_and_leaves.jpg", "[V6-ULTIMATE] Loài cây thân đốt, dẻo dai, gắn liền với làng quê Việt."),
                    ("Loài hoa này thường mọc ở đầm lầy?", "Hoa sen", "https://upload.wikimedia.org/wikipedia/commons/4/48/Lotus_flowers_Vietnam_%2838834388684%29.jpg", "[V6-ULTIMATE] Gần bùn mà chẳng hôi tanh mùi bùn."),
                    ("Địa danh nổi tiếng này ở Quảng Ninh?", "Vịnh Hạ Long", "https://upload.wikimedia.org/wikipedia/commons/2/2d/Halong_Bay_in_Vietnam.jpg", "[V6-ULTIMATE] Di sản thiên nhiên thế giới với hàng ngàn đảo đá vôi."),
                    ("Nhạc cụ truyền thống VN?", "Đàn bầu", "https://upload.wikimedia.org/wikipedia/commons/a/a4/Vietnamese_musical_instrument_Dan_bau_2.jpg", "[V6-ULTIMATE] Nhạc cụ chỉ có một dây nhưng phát ra âm thanh rất độc đáo."),
                    ("Trang phục truyền thống của VN?", "Áo dài", "https://upload.wikimedia.org/wikipedia/commons/c/cb/Vietnamese_girl_wearing_ao_dai_3.jpg", "[V6-ULTIMATE] Trang phục tôn vinh vẻ đẹp của người phụ nữ Việt Nam."),
                },
                [3] = new()
                {
                    ("Tác phẩm văn học kinh điển này là?", "Truyện Kiều", "https://upload.wikimedia.org/wikipedia/commons/b/b1/Kim_V%C3%A2n_Ki%E1%BB%81u_t%C3%A2n_truy%E1%BB%87n.jpg", "[V6-ULTIMATE] Tác phẩm tiêu biểu nhất của Nguyễn Du."),
                    ("Đại thi hào dân tộc này là ai?", "Nguyễn Du", "https://upload.wikimedia.org/wikipedia/commons/3/37/T%C6%B0%E1%BB%A3ng_%C4%90%E1%BA%A1i_thi_h%C3%A0o_Nguy%E1%BB%85n_Du.jpg", "[V6-ULTIMATE] Tác giả của tác phẩm 'Đoạn trường tân thanh'."),
                    ("Vùng đồng bằng lớn nhất miền Nam?", "Đồng bằng sông Cửu Long", "https://upload.wikimedia.org/wikipedia/commons/9/95/Delta_Mekong_mappa.png", "[V6-ULTIMATE] Vùng đất trù phú với mạng lưới sông ngòi chằng chịt."),
                    ("Nơi yên nghỉ của Bác Hồ?", "Lăng Bác", "https://upload.wikimedia.org/wikipedia/commons/d/dd/Hanoi_Vietnam_Mausoleum-of-Ho-Chi-Minh-01.jpg", "[V6-ULTIMATE] Công trình tại quảng trường Ba Đình lịch sử."),
                    ("Ký hiệu này dùng để làm gì?", "Dấu chấm phẩy", "https://upload.wikimedia.org/wikipedia/commons/4/4a/Semicolon.png", "[V6-ULTIMATE] Dùng để ngăn cách các vế câu trong câu ghép phức tạp."),
                    ("Thể thơ 6 chữ và 8 chữ?", "Thơ lục bát", "https://upload.wikimedia.org/wikipedia/commons/8/83/Tam_t%E1%BB%B1_kinh_l%E1%BB%A5c_b%C3%A1t_di%E1%BB%85n_%C3%A2m_second_page.png", "[V6-ULTIMATE] Thể thơ dân tộc truyền thống của Việt Nam."),
                },
            };

            var result = new List<Question>();
            var bank = banks[diff];
            foreach (var item in bank)
            {
                result.Add(new Question
                {
                    GameId = gameId,
                    QuestionType = "picture_guess",
                    Difficulty = diff,
                    Data = item.data,
                    Answer = item.answer,
                    ImageUrl = item.imgUrl,
                    Explanation = item.hint,
                    IsActive = true,
                });
            }
            return result;
        }

        private static List<Question> ListenChoose(int gameId, int diff)
        {
            var banks = new Dictionary<int, List<(string data, string answer, string? audioUrl)>>
            {
                [1] = new()
                {
                    ("[\"Hà Nội (Bắc) [V5]\", \"Sài Gòn (Nam) [v5]\"]", "Hà Nội (Bắc) [V5]", "https://upload.wikimedia.org/wikipedia/commons/d/d3/Ha_Noi_Northern.ogg"),
                    ("[\"Hà Nội (Bắc) [v5]\", \"Sài Gòn (Nam) [V5]\"]", "Sài Gòn (Nam) [V5]", "https://upload.wikimedia.org/wikipedia/commons/9/9b/Dong_Nai.ogg"),
                    ("[\"Hải Phòng (Bắc) [v5]\", \"Bình Dương (Nam) [v5]\"]", "Hải Phòng (Bắc) [v5]", "https://upload.wikimedia.org/wikipedia/commons/c/cb/Hai_Phong.ogg"),
                    ("[\"Hải Phòng (Bắc) [v5]\", \"Bình Dương (Nam) [v5]\"]", "Bình Dương (Nam) [v5]", "https://upload.wikimedia.org/wikipedia/commons/4/4a/Binh_Duong.ogg"),
                    ("[\"Hà Nội (v5)\", \"Sài Gòn (v5)\"]", "Hà Nội (v5)", "https://upload.wikimedia.org/wikipedia/commons/6/6c/Ha_noi.ogg"),
                    ("[\"Hà Nội (v5)\", \"Sài Gòn (v5)\"]", "Sài Gòn (v5)", "https://upload.wikimedia.org/wikipedia/commons/9/9b/Dong_Nai.ogg"),
                },
                [2] = new()
                {
                    ("[\"Huế (Trung) [V5]\", \"Vũng Tàu (Nam) [v5]\", \"Hà Nội (Bắc) [v5]\"]", "Huế (Trung) [V5]", "https://upload.wikimedia.org/wikipedia/commons/b/bb/Hue_Northern.ogg"),
                    ("[\"Huế (v5)\", \"Vũng Tàu (Nam) [V5]\", \"Hà Nội (v5)\"]", "Vũng Tàu (Nam) [V5]", "https://upload.wikimedia.org/wikipedia/commons/c/c6/Vung_Tau_Northern.ogg"),
                    ("[\"Đà Nẵng [V5]\", \"Sài Gòn [v5]\", \"Hà Nội [v5]\"]", "Đà Nẵng [V5]", "https://upload.wikimedia.org/wikipedia/commons/0/0c/Da_Nang.ogg"),
                    ("[\"Cần Thơ [V5]\", \"Hà Nội [v5]\", \"Huế [v5]\"]", "Cần Thơ [V5]", "https://upload.wikimedia.org/wikipedia/commons/f/f8/Can_Tho.ogg"),
                    ("[\"Long An [V5]\", \"Bắc Giang [v5]\", \"Hải Phòng [v5]\"]", "Long An [V5]", "https://upload.wikimedia.org/wikipedia/commons/b/bc/Long_An.ogg"),
                },
                [3] = new()
                {
                    ("[\"Giọng Miền Bắc [V5]\", \"Giọng Miền Trung [v5]\", \"Giọng Miền Nam [v5]\"]", "Giọng Miền Bắc [V5]", "https://upload.wikimedia.org/wikipedia/commons/d/d3/Ha_Noi_Northern.ogg"),
                    ("[\"Giọng Miền Bắc [v5]\", \"Giọng Miền Trung [V5]\", \"Giọng Miền Nam [v5]\"]", "Giọng Miền Trung [V5]", "https://upload.wikimedia.org/wikipedia/commons/0/09/Hue.ogg"),
                    ("[\"Giọng Miền Bắc [v5]\", \"Giọng Miền Trung [v5]\", \"Giọng Miền Nam [V5]\"]", "Giọng Miền Nam [V5]", "https://upload.wikimedia.org/wikipedia/commons/5/56/Ben_Tre.ogg"),
                    ("[\"Bến Tre [V5]\", \"Tiền Giang [v5]\", \"Vĩnh Long [v5]\"]", "Bến Tre [V5]", "https://upload.wikimedia.org/wikipedia/commons/5/56/Ben_Tre.ogg"),
                    ("[\"Tiền Giang [V5]\", \"Vĩnh Long [v5]\", \"Long An [v5]\"]", "Tiền Giang [V5]", "https://upload.wikimedia.org/wikipedia/commons/a/a0/Tien_Giang.ogg"),
                    ("[\"Vĩnh Long [V5]\", \"Bến Tre [v5]\", \"Cần Thơ [v5]\"]", "Vĩnh Long [V5]", "https://upload.wikimedia.org/wikipedia/commons/5/5c/Vinh_Long.ogg"),
                },
            };

            var result = new List<Question>();
            var bank = banks[diff];
            foreach (var item in bank)
            {
                result.Add(new Question
                {
                    GameId = gameId,
                    QuestionType = "listen_choose",
                    Difficulty = diff,
                    Data = item.data,
                    Answer = item.answer,
                    AudioUrl = item.audioUrl,
                    Explanation = "[V5-ULTIMATE] Nghe và chọn giọng vùng miền chính xác:",
                    IsActive = true,
                });
            }
            return result;
        }

        private static List<Question> DragDropSentence(int gameId, int diff)
        {
            var banks = new Dictionary<int, List<(string data, string answer)>>
            {
                [1] = new()
                {
                    ("[\"Em\", \"đi\", \"học\"]", "Em đi học"),
                    ("[\"Tôi\", \"yêu\", \"Việt Nam\"]", "Tôi yêu Việt Nam"),
                    ("[\"Mẹ\", \"nấu\", \"cơm\"]", "Mẹ nấu cơm"),
                    ("[\"Con\", \"mèo\", \"ngủ\"]", "Con mèo ngủ"),
                    ("[\"Bầu\", \"trời\", \"xanh\"]", "Bầu trời xanh"),
                    ("[\"Hoa\", \"nở\", \"rộ\"]", "Hoa nở rộ"),
                },
                [2] = new()
                {
                    ("[\"Tiếng Việt\", \"rất\", \"giàu\", \"thanh điệu\"]", "Tiếng Việt rất giàu thanh điệu"),
                    ("[\"Học sinh\", \"đang\", \"chăm chỉ\", \"học bài\"]", "Học sinh đang chăm chỉ học bài"),
                    ("[\"Mùa xuân\", \"đến\", \"ngàn hoa\", \"đua nở\"]", "Mùa xuân đến ngàn hoa đua nở"),
                    ("[\"Ông bà\", \"thường\", \"kể\", \"chuyện cổ\"]", "Ông bà thường kể chuyện cổ"),
                    ("[\"Bè bạn\", \"phải\", \"biết\", \"giúp đỡ\", \"nhau\"]", "Bè bạn phải biết giúp đỡ nhau"),
                    ("[\"Quê hương\", \"là\", \"chùm khế ngọt\", \"của em\"]", "Quê hương là chùm khế ngọt của em"),
                },
                [3] = new()
                {
                    ("[\"Văn học\", \"dân gian\", \"là\", \"túi khôn\", \"của\", \"nhân dân\"]", "Văn học dân gian là túi khôn của nhân dân"),
                    ("[\"Nguyễn Du\", \"đã\", \"để lại\", \"kiệt tác\", \"Truyện Kiều\"]", "Nguyễn Du đã để lại kiệt tác Truyện Kiều"),
                    ("[\"Biện pháp\", \"ẩn dụ\", \"làm\", \"tăng\", \"sức\", \"gợi hình\"]", "Biện pháp ẩn dụ làm tăng sức gợi hình"),
                    ("[\"Chúng ta\", \"cần\", \"bảo tồn\", \"di sản\", \"văn hóa\"]", "Chúng ta cần bảo tồn di sản văn hóa"),
                    ("[\"Tinh thần\", \"tự học\", \"là\", \"chìa khóa\", \"thành công\"]", "Tinh thần tự học là chìa khóa thành công"),
                    ("[\"Sách\", \"là\", \"kho tàng\", \"tri thức\", \"của\", \"loài người\"]", "Sách là kho tàng tri thức của loài người"),
                },
            };

            return MakeQuestions(gameId, "drag_drop_sentence", diff, banks[diff]);
        }

        private static List<Question> FindError(int gameId, int diff)
        {
            var banks = new Dictionary<int, List<(string data, string answer)>>
            {
                [1] = new()
                {
                    ("[\"Tôi\", \"ĐI\", \"trương\"]", "trương"),
                    ("[\"Con\", \"chó\", \"sứa\"]", "sứa"),
                    ("[\"Hôm\", \"nai\", \"đẹp\"]", "nai"),
                    ("[\"Em\", \"yêu\", \"quê\", \"hưong\"]", "hưong"),
                    ("[\"Bầu\", \"trời\", \"xang\"]", "xang"),
                    ("[\"Mẹ\", \"nấu\", \"com\"]", "com"),
                },
                [2] = new()
                {
                    ("[\"Bạn\", \"phải\", \"biếc\", \"vâng lời\"]", "biếc"),
                    ("[\"Tiếng\", \"Viêt\", \"rất\", \"trong sáng\"]", "Viêt"),
                    ("[\"Em\", \"thường\", \"xuyên\", \"độp\", \"sách\"]", "độp"),
                    ("[\"Mùa\", \"xuân\", \"hoa\", \"đào\", \"nỡ\"]", "nỡ"),
                    ("[\"Dòng\", \"sông\", \"chảy\", \"hien\", \"hòa\"]", "hien"),
                    ("[\"Mặt\", \"trời\", \"mộc\", \"ở\", \"đằng đông\"]", "mộc"),
                },
                [3] = new()
                {
                    ("[\"Yếu\", \"tố\", \"biểu\", \"cãm\", \"trong\", \"văn\", \"bản\"]", "cãm"),
                    ("[\"Những\", \"câu\", \"thơ\", \"lọc\", \"bát\", \"ngọt\", \"ngào\"]", "lọc"),
                    ("[\"Biện\", \"pháp\", \"tu\", \"từ\", \"hoáng\", \"dụ\"]", "hoáng"),
                    ("[\"Phong\", \"cách\", \"ngôn\", \"ngữ\", \"nghệ\", \"thuộc\"]", "thuộc"),
                    ("[\"Sự\", \"nghiệp\", \"giáng\", \"dục\", \"con\", \"người\"]", "giáng"),
                    ("[\"Đoàn\", \"kết\", \"là\", \"sức\", \"mạnh\", \"vô\", \" điệc\"]", " điệc"),
                },
            };

            return MakeQuestions(gameId, "find_error", diff, banks[diff]);
        }

        private static List<Question> MakeQuestions(int gameId, string type, int diff, List<(string data, string answer)> bank)
        {
            var result = new List<Question>();
            for (int i = 0; i < Math.Min(6, bank.Count); i++)
            {
                result.Add(new Question
                {
                    GameId       = gameId,
                    QuestionType = type,
                    Difficulty   = diff,
                    Data         = bank[i].data,
                    Answer       = bank[i].answer,
                    IsActive     = true,
                });
            }
            return result;
        }
    }
}
