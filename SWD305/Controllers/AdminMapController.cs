using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SWD305.DTO;
using SWD305.Models;

using Microsoft.AspNetCore.Authorization;

namespace SWD305.Controllers
{
    [Authorize(Roles = "admin")]
    [Route("api/admin/maps")]
    [ApiController]
    public class AdminMapController : ControllerBase
    {
        private readonly VnegSystemContext _context;

        public AdminMapController(VnegSystemContext context)
        {
            _context = context;
        }

        // ✅ GET ALL
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var maps = await _context.Maps
                .Include(m => m.Grade)
                .ToListAsync();

            return Ok(maps);
        }

        // ✅ GET BY ID
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var map = await _context.Maps
                .Include(m => m.Grade)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (map == null)
                return NotFound("Map not found");

            return Ok(map);
        }

        // ✅ CREATE
        [HttpPost]
        public async Task<IActionResult> Create(CreateMapDto dto)
        {
            // kiểm tra grade tồn tại nếu có truyền vào
            if (dto.GradeId.HasValue)
            {
                var gradeExists = await _context.Grades
                    .AnyAsync(g => g.Id == dto.GradeId.Value);

                if (!gradeExists)
                    return BadRequest("GradeId does not exist.");
            }

            var map = new Map
            {
                GradeId = dto.GradeId,
                Name = dto.Name,
                OrderIndex = dto.OrderIndex,
                IsActive = dto.IsActive
            };

            _context.Maps.Add(map);
            await _context.SaveChangesAsync();

            return Ok(map);
        }

        // ✅ UPDATE
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, UpdateMapDto dto)
        {
            var map = await _context.Maps.FindAsync(id);

            if (map == null)
                return NotFound("Map not found");

            if (dto.GradeId.HasValue)
            {
                var gradeExists = await _context.Grades
                    .AnyAsync(g => g.Id == dto.GradeId.Value);

                if (!gradeExists)
                    return BadRequest("GradeId does not exist.");
            }

            map.GradeId = dto.GradeId;
            map.Name = dto.Name;
            map.OrderIndex = dto.OrderIndex;
            map.IsActive = dto.IsActive;

            await _context.SaveChangesAsync();

            return Ok(map);
        }

        // ✅ DELETE
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var map = await _context.Maps
                .Include(m => m.Games)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (map == null)
                return NotFound("Map not found");

            if (map.Games.Any())
                return BadRequest("Cannot delete map because it contains games.");

            _context.Maps.Remove(map);
            await _context.SaveChangesAsync();

            return Ok("Deleted successfully");
        }
    }
}
