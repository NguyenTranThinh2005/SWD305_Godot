namespace SWD305.DTO
{
    public class CreateMapDto
    {
        public int? GradeId { get; set; }
        public string Name { get; set; } = null!;
        public int? OrderIndex { get; set; }
        public bool? IsActive { get; set; }
    }

    public class UpdateMapDto
    {
        public int? GradeId { get; set; }
        public string Name { get; set; } = null!;
        public int? OrderIndex { get; set; }
        public bool? IsActive { get; set; }
    }
}
