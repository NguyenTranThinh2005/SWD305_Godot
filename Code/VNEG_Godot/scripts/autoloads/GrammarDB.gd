extends Node
## VNEG_Godot/scripts/autoloads/GrammarDB.gd
##
## Lưu trữ toàn bộ dữ liệu Ngữ pháp, Học thuật và Câu hỏi trắc nghiệm của Tiếng Việt Quest.

const CONCEPTS = {
	"thu_cong_hu_tu": {
		"title": "Thực từ và Hư từ",
		"description": "Thực từ là từ có nghĩa cụ thể (danh từ, động từ, tính từ). Hư từ là từ không có nghĩa cụ thể, dùng để nối hoặc biến đổi ý nghĩa.",
	},
	"cau_khang_phu": {
		"title": "Câu khẳng định và Phủ định",
		"description": "Câu khẳng định thể hiện ý nghĩa đồng ý hoặc xác nhận. Câu phủ định dùng từ 'không', 'chưa', 'chẳng' để phủ nhận.",
	},
	"dau_cau": {
		"title": "Dấu câu",
		"description": "Dấu câu gồm: dấu chấm (.), dấu phẩy (,), dấu chấm hỏi (?), dấu chấm than (!). Mỗi loại có quy tắc sử dụng riêng.",
	},
	"tu_lai_ghep": {
		"title": "Từ láy và Từ ghép",
		"description": "Từ láy: các âm phần lặp lại (VD: lung lay). Từ ghép: ghép các từ đơn có nghĩa (VD: cây cối).",
	},
	"cau_don_cau_phuc": {
		"title": "Câu đơn và Câu phức",
		"description": "Câu đơn có 1 vế. Câu phức có nhiều vế nối bằng từ nối (và, nhưng, vì, nên...).",
	}
}

const DATABASE = {
	"soCapLevel": {
		"title": "🌱 SƠ CẤP",
		"color": "#4ade80",
		"colorDark": "#16a34a",
		"icon": "🌿",
		"chapters": [
			{
				"id": "sc_ch1",
				"title": "Chương 1: Thực từ & Hư từ",
				"conceptKey": "thu_cong_hu_tu",
				"stages": {
					"nguPhap": [
						{ "question": "Từ nào dưới đây là thực từ?", "options": ["nó", "đang", "cây cối", "với"], "correctIndices": [2], "type": "multi" },
						{ "question": "Từ nào là hư từ?", "options": ["nhà", "và", "xe", "sông"], "correctIndices": [1], "type": "multi" },
						{ "question": "Chọn các thực từ trong danh sách sau:", "options": ["của", "cái", "bảo", "cái xe"], "correctIndices": [3], "type": "multi" },
						{ "question": "Từ nào dưới đây là hư từ?", "options": ["núi", "rừng", "để", "cây"], "correctIndices": [2], "type": "multi" },
						{ "question": "Chọn các hư từ:", "options": ["baba", "mẹ", "với", "ba"], "correctIndices": [2], "type": "multi" }
					],
					"chinhTa": [
						{ "question": "Chính tả đúng của từ nào?", "options": ["lún tún", "lúng tún", "lúng túng", "lún túm"], "correctIndex": 2 },
						{ "question": "Từ nào đúng chính tả?", "options": ["sao sánh", "so sánh", "sao sanh", "sao sãnh"], "correctIndex": 1 }
					],
					"nhinTranh": [
						{ "question": "Nhìn tranh, đoán thành ngữ và cho biết hư từ là?", "image": "🌳🌳🌳", "imageDesc": "Ba cây cùng nhau lớn lên", "options": ["nên", "rừng", "núi", "chặt"], "correctIndex": 0, "thanGu": "Một cây làm chẳng nên non, ba cây chụm lại nên hòn núi cao" }
					],
					"xepCau": [
						{ "question": "Xếp câu đúng:", "scramble": ["tôi", "muốn", "ăn", "cơm", "cùng", "bạn"], "options": ["Tôi muốn ăn cơm cùng bạn.", "Bạn cùng tôi muốn ăn cơm.", "Ăn cơm tôi muốn cùng bạn.", "Cùng bạn ăn cơm tôi muốn."], "correctIndex": 0 }
					],
					"vuongMien": [
						{ "question": "Miền Nam dùng 'Đi đâu đi' thay bằng?", "options": ["Đi đâu vậy", "Đi đâu rồi", "Đi đâu không", "Đi đâu hả"], "correctIndex": 0 }
					]
				}
			},
			{
				"id": "sc_ch2",
				"title": "Chương 2: Câu Khẳng định & Phủ định",
				"conceptKey": "cau_khang_phu",
				"stages": {
					"nguPhap": [
						{ "question": "Câu nào là câu khẳng định?", "options": ["Tôi không đi.", "Anh ấy chưa đến.", "Em đã ăn rồi.", "Cô ấy chẳng muốn."], "correctIndices": [2], "type": "multi" },
						{ "question": "Chọn câu phủ định:", "options": ["Bé đang chơi.", "Mẹ đang nấu.", "Anh chưa đến.", "Bé ngoan lắm."], "correctIndices": [2], "type": "multi" }
					]
				}
			}
		]
	},
	"trungCapLevel": {
		"title": "📚 TRUNG CẤP",
		"color": "#60a5fa",
		"colorDark": "#2563eb",
		"icon": "📖",
		"chapters": [
			{
				"id": "tc_ch1",
				"title": "Chương 1: Câu Đơn & Câu Phức",
				"conceptKey": "cau_don_cau_phuc",
				"stages": {
					"nguPhap": [
						{ "question": "Câu đơn là câu?", "options": ["Có nhiều vế", "Có 1 vế", "Không có chủ ngữ", "Không có tuyên đề"], "correctIndices": [1], "type": "multi" },
						{ "question": "Câu nào là câu phức?", "options": ["Tôi ăn cơm.", "Tôi ăn cơm và uống nước.", "Bé ngoan.", "Mẹ về."], "correctIndices": [1], "type": "multi" }
					]
				}
			}
		]
	},
	"caoCapLevel": {
		"title": "🏆 CAO CẤP",
		"color": "#f59e0b",
		"colorDark": "#d97706",
		"icon": "⭐",
		"chapters": [
			{
				"id": "cc_ch1",
				"title": "Chương 1: Dấu Câu Nâng Cao",
				"conceptKey": "dau_cau",
				"stages": {
					"nguPhap": [
						{ "question": "Dấu chấm (.) dùng ở đâu?", "options": ["Cuối câu tuyên bố", "Cuối câu hỏi", "Cuối câu cảm thấy", "Giữa câu"], "correctIndices": [0], "type": "multi" }
					]
				}
			}
		]
	}
}

const STAGE_NAMES = {
	"nguPhap": "📖 Ngữ Pháp",
	"chinhTa": "✍️ Chính Tả",
	"nhinTranh": "🖼️ Nhìn Tranh",
	"xepCau": "🔀 Xếp Câu",
	"vuongMien": "🗺️ Vùng Miền",
	"onTap": "🎯 Ôn Tập"
}

func get_questions(map_key: String, chapter_id: String, stage_key: String) -> Array:
	if not DATABASE.has(map_key): return []
	
	for chapter in DATABASE[map_key]["chapters"]:
		if chapter["id"] == chapter_id:
			if chapter["stages"].has(stage_key):
				return chapter["stages"][stage_key]
			elif stage_key == "onTap":
				# Generate random questions from all stages for onTap
				var on_tap_questions = []
				for key in chapter["stages"].keys():
					var stage_qs = chapter["stages"][key]
					# Take up to 2 questions per stage
					for i in range(min(2, stage_qs.size())):
						var q = stage_qs[i].duplicate(true)
						q["fromStage"] = key
						on_tap_questions.append(q)
				return on_tap_questions
	return []

func get_concept(concept_key: String) -> Dictionary:
	return CONCEPTS.get(concept_key, {})
