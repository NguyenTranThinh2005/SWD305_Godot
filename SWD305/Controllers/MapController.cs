using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SWD305.Models;

namespace SWD305.Controllers
{
    [Route("api/maps")]
    [ApiController]
    public class MapController : ControllerBase
    {
        private readonly VnegSystemContext _context;

        public MapController(VnegSystemContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetMaps()
        {
            var maps = await _context.Maps
                .Where(m => m.IsActive == true)
                .Select(m => new
                {
                    m.Id,
                    m.Name,
                    m.OrderIndex
                })
                .ToListAsync();

            return Ok(maps);
        }
    }
}
