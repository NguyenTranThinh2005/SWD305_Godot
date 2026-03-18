using System;
using System.Collections.Generic;

namespace SWD305.Models;

public partial class UserGrammarProgress
{
    public int Id { get; set; }

    public int UserId { get; set; }

    public int GrammarTopicId { get; set; }

    public decimal? MasteryLevel { get; set; }

    public int? CorrectCount { get; set; }

    public int? WrongCount { get; set; }

    public DateTime? LastPracticedAt { get; set; }

    public virtual GrammarTopic GrammarTopic { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
