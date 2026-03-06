using Microsoft.EntityFrameworkCore;
using SWD305.Models;

namespace SWD305.Security
{
    public static class SessionAuth
    {
        public static async Task<User?> GetActiveUserByToken(VnegSystemContext context, string token)
        {
            if (string.IsNullOrWhiteSpace(token)) return null;

            var now = DateTime.Now;
            var session = await context.Sessions
                .Include(s => s.User)
                .FirstOrDefaultAsync(s => s.JwtToken == token && s.ExpiresAt > now);

            if (session?.User == null) return null;
            if (session.User.IsActive == false) return null;

            return session.User;
        }
    }
}

