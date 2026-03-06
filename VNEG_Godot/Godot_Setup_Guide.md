# Hướng Dẫn Thiết Lập Dự Án Godot VNEG

Chào mừng đến với phiên bản Godot của **VNEG (Việt Ngữ Edu Game)**. Godot Engine kết hợp giao diện trực quan với mã nguồn (GDScript). File này hướng dẫn bạn cách khởi tạo dự án và lắp ráp mã nguồn mà tôi đã viết vào đúng vị trí.

---

## Bước 1: Khởi tạo Project trong Godot 4
1. Mở **Godot Engine 4.x**.
2. Chọn **New Project**.
3. Chọn đường dẫn tới thư mục `c:\FPT Education\Semester 7\SWD392\Test\VNEngSystem-main\VNEG_Godot`.
4. Đặt tên: `VNEG_Godot`. Chọn Renderer là **Forward+** hoặc **Mobile** (tùy nhu cầu web/mobile).
5. Nhấn **Create & Edit**.

Bạn sẽ thấy thư mục con `scripts/` (đã được tạo bởi AI) hiện lên trong bảng `FileSystem` bên dưới cùng góc trái.

---

## Bước 2: Thiết lập Autoloads (Singletons)
Autoload là những script chạy ngầm xuyên suốt game, dùng để quản lý trạng thái, API request mà không phụ thuộc vào Scene hiện tại.

Vào menu: **Project > Project Settings... > tab Autoload**

1. Nhấn nút Browse thư mục (`..`), chọn `res://scripts/autoloads/API.gd`. Đặt "Node Name" là `API`, rồi nhấn **Add**.
2. Chọn `res://scripts/autoloads/AuthManager.gd`. Đặt tên: `AuthManager`, nhấn **Add**.
3. Chọn `res://scripts/autoloads/GameManager.gd`. Đặt tên: `GameManager`, nhấn **Add**.

*Bây giờ, mọi đoạn code trong game đều có thể gọi `API.get_games()`, `AuthManager.login()`, v.v...*

---

## Bước 3: Tạo Scene Đăng Nhập (LoginScreen.tscn)
1. Trong màn hình Godot, tạo mới Scene gốc là **Control** (User Interface). 
2. Đổi tên node gốc từ `Control` thành `LoginScreen`.
3. Kéo thả các node UI sau vào làm con của `LoginScreen`:
	- `TextureRect` (Làm background)
	- `VBoxContainer` (Để căn chỉnh các input)
		- `LineEdit` (Tên: `EmailInput`)
		- `LineEdit` (Tên: `PasswordInput` - nhớ check ô `Secret` trong Inspector)
		- `Button` (Tên: `LoginButton`)
		- `Button` (Tên: `RegisterButton`)
		- `Label` (Tên: `StatusLabel` - dùng hiện lỗi/loading)
4. Nhấn chuột phải vào node gốc `LoginScreen`, chọn **Attach Script**. Nhấn hình cái thư mục (`..`) và tìm chọn file `res://scripts/ui/LoginScreen.gd`. Nhấn Load.
5. Code trong `LoginScreen.gd` đã liên kết các tín hiệu `pressed` của Button. Hãy đảm bảo bạn đặt đúng Tên Node (`EmailInput`, `PasswordInput`...) như ở mục 3 để script nhận diện được.

---

## Bước 4: Tạo Scene Game Chính (AntigravityWorld.tscn)
1. Tạo Scene 2D mới (Node2D). Đổi tên gốc thành `AntigravityWorld`.
2. Tạo các node con:
	- `CanvasLayer` (Tên: `UI` - Để chứa UI cố định trên màn hình)
		- `Label` (Tên: `ScoreLabel`)
		- `Label` (Tên: `QuestionLabel`)
		- `VBoxContainer` (Tên: `ChoicesBox` - Để chứa các nút đáp án A B C D)
	- `CharacterBody2D` (Tên: `Player`)
		- Thêm Sprite2D và CollisionShape2D làm con của Player.
	- Chỗ nào cần đứng, thêm `StaticBody2D` + `CollisionShape2D` làm sàn nhà.
3. Node gốc `AntigravityWorld` -> **Attach Script** -> Chọn `res://scripts/game/AntigravityWorld.gd`.
4. Node `Player` -> **Attach Script** -> Chọn `res://scripts/game/Player.gd`.

Phần xử lý `Input` để cho nhân vật nhảy lên/di chuyển bạn sẽ cấu hình trong `Project Settings > Input Map`.

---

## Bước 5: Các Scene Phụ (Teams & Profile)
Ngoài màn chơi chính, bạn cần tạo thêm 2 scene để quản lý:
1. **Scene `TeamsMenu` (Control node)**: Nơi học sinh tham gia/tạo Nhóm. Cần các node:
   - `ScrollContainer > VBoxContainer` (Tên: `TeamList`)
   - Khung Tạo Nhóm: `LineEdit` (`NameInput`), `LineEdit` (`DescInput`), `Button` (`CreateButton`).
   - Khung Join Nhóm: `LineEdit` (`CodeInput`), `Button` (`JoinButton`).
   - `Label` (`StatusLabel`) và `Button` (`BackButton`).
   - 👉 Gắn Script: `res://scripts/ui/TeamsMenu.gd`

2. **Scene `ProfileMenu` (Control node)**: Xem tiến trình Grammar. Cần các node:
   - `Label` (`UserInfoLabel`), `Label` (`StatsLabel`), `Label` (`StatusLabel`)
   - `ScrollContainer > VBoxContainer` (Tên: `GrammarList`)
   - `Button` (`BackButton`)
   - 👉 Gắn Script: `res://scripts/ui/ProfileMenu.gd`

Ở `MainMenu.gd`, bạn có thể thêm Nút để `change_scene_to_file("res://scenes/TeamsMenu.tscn")` nhé.

---

## Bước 6: Chạy Game!
1. Đảm bảo API Backend ASP.NET của bạn đang chạy ở `http://localhost:5290` (Hoặc sửa URL trong `API.gd`).
2. Mở Scene `LoginScreen.tscn`.
3. Nhấn **F6 (Play Current Scene)** để thử nghiệm luồng đăng nhập!

> Nếu gặp lỗi code hay UI, bạn hãy thông báo vào khung Chat AI này để tớ hướng dẫn sửa nhé!
