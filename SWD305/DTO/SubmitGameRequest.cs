namespace SWD305.DTO
{
    public class SubmitGameRequest
    {
        public List<AnswerDto> Answers { get; set; } = new();
    }

    public class AnswerDto
    {
        public int QuestionId { get; set; }
        public bool IsCorrect { get; set; }
    }

}
