using System;
using System.Collections.Generic;

namespace SWD305.Models;

public partial class GameError
{
    public int Id { get; set; }

    public int GameSessionId { get; set; }

    public int QuestionId { get; set; }

    public string? ErrorType { get; set; }

    public virtual ICollection<GameErrorGrammar> GameErrorGrammars { get; set; } = new List<GameErrorGrammar>();

    public virtual GameSession GameSession { get; set; } = null!;

    public virtual Question Question { get; set; } = null!;
}
