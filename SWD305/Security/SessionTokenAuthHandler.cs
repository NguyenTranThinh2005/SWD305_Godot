using Microsoft.AspNetCore.Authentication;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Security.Claims;
using System.Text.Encodings.Web;
using System.Threading.Tasks;
using SWD305.Models;

namespace SWD305.Security
{
    public class SessionTokenAuthHandler : AuthenticationHandler<AuthenticationSchemeOptions>
    {
        private readonly VnegSystemContext _context;

        public SessionTokenAuthHandler(
            IOptionsMonitor<AuthenticationSchemeOptions> options,
            ILoggerFactory logger,
            UrlEncoder encoder,
            VnegSystemContext context)
            : base(options, logger, encoder)
        {
            _context = context;
        }

        protected override async Task<AuthenticateResult> HandleAuthenticateAsync()
        {
            // First look for X-Session-Token
            if (!Request.Headers.TryGetValue("X-Session-Token", out var tokenValues))
            {
                // Fallback to Bearer token just in case
                if (Request.Headers.TryGetValue("Authorization", out var authHeader))
                {
                    var authVal = authHeader.ToString().Trim();
                    if (authVal.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
                    {
                        var sanitizedToken = authVal.Substring("Bearer".Length).Trim();
                        // Sometimes users type 'Bearer ...' in the Swagger box, which results in 'Bearer Bearer ...'
                        if (sanitizedToken.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
                        {
                            sanitizedToken = sanitizedToken.Substring("Bearer".Length).Trim();
                        }
                        tokenValues = sanitizedToken;
                    }
                }
            }

            var token = tokenValues.ToString();
            if (string.IsNullOrEmpty(token))
            {
                return AuthenticateResult.NoResult();
            }

            var user = await SessionAuth.GetActiveUserByToken(_context, token);
            if (user == null)
            {
                return AuthenticateResult.Fail("Invalid or expired session token.");
            }

            var claims = new[]
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim(ClaimTypes.Email, user.Email),
                new Claim(ClaimTypes.Role, user.Role ?? "user"),
                new Claim("Token", token)
            };

            var identity = new ClaimsIdentity(claims, Scheme.Name);
            var principal = new ClaimsPrincipal(identity);
            var ticket = new AuthenticationTicket(principal, Scheme.Name);

            return AuthenticateResult.Success(ticket);
        }
    }
}
