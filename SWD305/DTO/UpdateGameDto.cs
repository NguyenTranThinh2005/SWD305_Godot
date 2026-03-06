namespace SWD305.DTO
{
    public class UpdateGameDto
    {
        public int MapId { get; set; }
        public string Name { get; set; } = null!;
        public string? GameType { get; set; }
        public string? Flow { get; set; }
        public int? OrderIndex { get; set; }
        public bool? IsPremium { get; set; }
    }


}
