using System;
using System.Collections.Generic;

namespace SWD305.Models;

public partial class GrammarTopic
{
    public int Id { get; set; }

    public int? ParentId { get; set; }

    public string? Code { get; set; }

    public string Name { get; set; } = null!;

    public string? Description { get; set; }

    public string? Example { get; set; }

    public int? GradeMin { get; set; }

    public int? GradeMax { get; set; }

    public int? Difficulty { get; set; }

    public bool? IsActive { get; set; }

    public virtual ICollection<GameErrorGrammar> GameErrorGrammars { get; set; } = new List<GameErrorGrammar>();

    public virtual ICollection<GrammarTopic> InverseParent { get; set; } = new List<GrammarTopic>();

    public virtual GrammarTopic? Parent { get; set; }

    public virtual ICollection<QuestionGrammar> QuestionGrammars { get; set; } = new List<QuestionGrammar>();

    public virtual ICollection<UserGrammarProgress> UserGrammarProgresses { get; set; } = new List<UserGrammarProgress>();
}
