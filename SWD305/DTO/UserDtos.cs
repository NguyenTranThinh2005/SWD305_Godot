namespace SWD305.DTO
{
    public class RegisterUserDto
    {
        public string Email { get; set; } = null!;
        public string Password { get; set; } = null!;
        public string? Phone { get; set; }
        public int? Grade { get; set; }
        public string? Region { get; set; }
        public string? AvatarUrl { get; set; }
    }

    public class LoginUserDto
    {
        public string Email { get; set; } = null!;
        public string Password { get; set; } = null!;
    }

    public class LogoutDto
    {
        public string Token { get; set; } = null!;
    }

    public class UpdateMeDto
    {
        public string? Phone { get; set; }
        public int? Grade { get; set; }
        public string? Region { get; set; }
        public string? AvatarUrl { get; set; }
    }

    public class ChangePasswordDto
    {
        public string CurrentPassword { get; set; } = null!;
        public string NewPassword { get; set; } = null!;
    }
}

