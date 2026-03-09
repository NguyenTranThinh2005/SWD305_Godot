using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SWD305.Models;

namespace SWD305.Controllers
{
    [Route("api/questions")]
    [ApiController]
    public class QuestionController : ControllerBase
    {
        private readonly VnegSystemContext _context;

        public QuestionController(VnegSystemContext context)
        {
            _context = context;
        }

        [HttpGet("by-game/{gameId}")]
        public async Task<IActionResult> GetQuestionsByGame(int gameId)
        {
            var questions = await _context.Questions
                .Where(q => q.GameId == gameId && q.IsActive == true)
                .Select(q => new
                {
                    q.Id,
                    q.QuestionType,
                    q.Difficulty,
                    q.Data,
                    q.Answer,
                    q.ImageUrl,
                    q.AudioUrl
                })
                .ToListAsync();

            return Ok(questions);
        }
    }
}
