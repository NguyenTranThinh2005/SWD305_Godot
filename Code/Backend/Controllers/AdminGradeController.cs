using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SWD305.Models;

using Microsoft.AspNetCore.Authorization;

namespace SWD305.Controllers
{
    [Authorize(Roles = "admin")]
    [ApiController]
    [Route("api/admin/grades")]
    public class AdminGradeController : ControllerBase
    {
        private readonly VnegSystemContext _context;

        public AdminGradeController(VnegSystemContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var grades = await _context.Grades
                .OrderBy(g => g.Id)
                .ToListAsync();

            return Ok(grades);
        }

        [HttpGet("{id:int}")]
        public async Task<IActionResult> GetById(int id)
        {
            var grade = await _context.Grades.FindAsync(id);
            if (grade == null) return NotFound("Grade not found");

            return Ok(grade);
        }

        [HttpPost]
        public async Task<IActionResult> Create(Grade grade)
        {
            var exists = await _context.Grades.AnyAsync(g => g.Id == grade.Id);
            if (exists) return BadRequest("Grade with the same Id already exists.");

            _context.Grades.Add(grade);
            await _context.SaveChangesAsync();

            return Ok(grade);
        }

        [HttpPut("{id:int}")]
        public async Task<IActionResult> Update(int id, Grade input)
        {
            var grade = await _context.Grades.FindAsync(id);
            if (grade == null) return NotFound("Grade not found");

            grade.Name = input.Name;
            await _context.SaveChangesAsync();

            return Ok(grade);
        }

        [HttpDelete("{id:int}")]
        public async Task<IActionResult> Delete(int id)
        {
            var grade = await _context.Grades
                .Include(g => g.Maps)
                .FirstOrDefaultAsync(g => g.Id == id);

            if (grade == null) return NotFound("Grade not found");
            if (grade.Maps.Any()) return BadRequest("Cannot delete grade because it is used by maps.");

            _context.Grades.Remove(grade);
            await _context.SaveChangesAsync();

            return Ok("Deleted successfully");
        }
    }
}

