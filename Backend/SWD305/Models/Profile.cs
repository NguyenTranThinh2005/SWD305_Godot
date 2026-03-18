using System;
using System.Collections.Generic;

namespace SWD305.Models;

public partial class Profile
{
    public int Id { get; set; }

    public int UserId { get; set; }

    public string? GrammarTree { get; set; }

    public string? TopErrors { get; set; }

    public string? Badges { get; set; }

    public string? WeeklyGraph { get; set; }
    public int? TotalCoins { get; set; }
    public int? TotalStars { get; set; }
    public int? Level { get; set; }
    public int? Exp { get; set; }

    public virtual User User { get; set; } = null!;
}
