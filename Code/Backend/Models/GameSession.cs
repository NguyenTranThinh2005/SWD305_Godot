using System;
using System.Collections.Generic;

namespace SWD305.Models;

public partial class GameSession
{
    public int Id { get; set; }

    public int UserId { get; set; }

    public int GameId { get; set; }

    public int? Score { get; set; }

    public int? Stars { get; set; }

    public int? Coins { get; set; }

    public decimal? Accuracy { get; set; }

    public DateTime? CompletedAt { get; set; }

    public virtual Game Game { get; set; } = null!;

    public virtual ICollection<GameError> GameErrors { get; set; } = new List<GameError>();

    public virtual User User { get; set; } = null!;
}
