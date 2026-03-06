using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SWD305.Models;
using SWD305.Security;

namespace SWD305.Controllers
{
    [ApiController]
    [Route("api/grammar")]
    public class GrammarController : ControllerBase
    {
        private readonly VnegSystemContext _context;

        public GrammarController(VnegSystemContext context)
        {
            _context = context;
        }

        private async Task<User?> GetMe()
        {
            var token = Request.Headers["X-Session-Token"].ToString();
            return await SessionAuth.GetActiveUserByToken(_context, token);
        }

        // Public-ish: show active grammar topics
        [HttpGet("topics")]
        public async Task<IActionResult> GetTopics([FromQuery] int? grade)
        {
            var topics = await _context.GrammarTopics
                .Where(t => t.IsActive == true)
                .Where(t => grade == null ||
                            (t.GradeMin == null || t.GradeMin <= grade) &&
                            (t.GradeMax == null || t.GradeMax >= grade))
                .OrderBy(t => t.ParentId)
                .ThenBy(t => t.Id)
                .Select(t => new
                {
                    t.Id,
                    t.ParentId,
                    t.Code,
                    t.Name,
                    t.Description,
                    t.Example,
                    t.GradeMin,
                    t.GradeMax,
                    t.Difficulty
                })
                .ToListAsync();

            return Ok(topics);
        }

        // Me: get progress for all topics the user has touched
        [HttpGet("progress/me")]
        public async Task<IActionResult> GetMyProgress()
        {
            var me = await GetMe();
            if (me == null) return Unauthorized("Invalid or expired token.");

            var progress = await _context.UserGrammarProgresses
                .Where(p => p.UserId == me.Id)
                .Include(p => p.GrammarTopic)
                .OrderByDescending(p => p.LastPracticedAt)
                .Select(p => new
                {
                    p.GrammarTopicId,
                    topicName = p.GrammarTopic.Name,
                    topicCode = p.GrammarTopic.Code,
                    p.MasteryLevel,
                    correct = p.CorrectCount,
                    wrong = p.WrongCount,
                    p.LastPracticedAt
                })
                .ToListAsync();

            return Ok(new
            {
                me.Id,
                me.Email,
                progress
            });
        }
    }
}

