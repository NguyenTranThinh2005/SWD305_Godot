using System;
using System.Collections.Generic;

namespace SWD305.Models;

public partial class QuestionGrammar
{
    public int Id { get; set; }

    public int QuestionId { get; set; }

    public int GrammarTopicId { get; set; }

    public int? Weight { get; set; }

    public virtual GrammarTopic GrammarTopic { get; set; } = null!;

    public virtual Question Question { get; set; } = null!;
}
