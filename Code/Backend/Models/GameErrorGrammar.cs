using System;
using System.Collections.Generic;

namespace SWD305.Models;

public partial class GameErrorGrammar
{
    public int Id { get; set; }

    public int GameErrorId { get; set; }

    public int GrammarTopicId { get; set; }

    public virtual GameError GameError { get; set; } = null!;

    public virtual GrammarTopic GrammarTopic { get; set; } = null!;
}
