using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SWD305.DTO;
using SWD305.Models;
using SWD305.Security;

using Microsoft.AspNetCore.Authorization;

namespace SWD305.Controllers
{
    [Authorize(Roles = "admin")]
    [ApiController]
    [Route("api/admin/teams")]
    public class AdminTeamController : ControllerBase
    {
        private readonly VnegSystemContext _context;

        public AdminTeamController(VnegSystemContext context)
        {
            _context = context;
        }

        private async Task<User?> GetMe()
        {
            var token = Request.Headers["X-Session-Token"].ToString();
            return await SessionAuth.GetActiveUserByToken(_context, token);
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {

            var teams = await _context.Teams
                .Include(t => t.Owner)
                .OrderByDescending(t => t.CreatedAt)
                .Select(t => new
                {
                    t.Id,
                    t.Name,
                    t.Description,
                    t.InviteCode,
                    OwnerId = t.OwnerId,
                    OwnerEmail = t.Owner.Email,
                    t.CreatedAt
                })
                .ToListAsync();

            return Ok(teams);
        }

        [HttpGet("{id:int}")]
        public async Task<IActionResult> GetById(int id)
        {

            var team = await _context.Teams
                .Include(t => t.Owner)
                .Select(t => new
                {
                    t.Id,
                    t.Name,
                    t.Description,
                    t.InviteCode,
                    OwnerId = t.OwnerId,
                    OwnerEmail = t.Owner.Email,
                    t.CreatedAt
                })
                .FirstOrDefaultAsync(t => t.Id == id);

            if (team == null) return NotFound("Team not found");

            return Ok(team);
        }

        [HttpDelete("{id:int}")]
        public async Task<IActionResult> DeleteTeam(int id)
        {

            var team = await _context.Teams.FindAsync(id);
            if (team == null) return NotFound("Team not found");

            // Must remove members first if not cascade deleted
            var members = await _context.TeamMembers.Where(tm => tm.TeamId == id).ToListAsync();
            _context.TeamMembers.RemoveRange(members);

            _context.Teams.Remove(team);
            await _context.SaveChangesAsync();

            return Ok("Team deleted by admin.");
        }
    }
}
