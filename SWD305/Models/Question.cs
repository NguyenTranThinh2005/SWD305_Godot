using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace SWD305.Models;

public partial class Question
{
    public int Id { get; set; }

    public int GameId { get; set; }

    public string QuestionType { get; set; } = null!;

    public int? Difficulty { get; set; }

    public string Data { get; set; } = null!;

    public string Answer { get; set; } = null!;
    [Column("image_url")]
    public string? ImageUrl { get; set; }
    [Column("audio_url")]
    public string? AudioUrl { get; set; }

    public string? Explanation { get; set; }

    public bool? IsActive { get; set; }

    public virtual Game Game { get; set; } = null!;

    public virtual ICollection<GameError> GameErrors { get; set; } = new List<GameError>();

    public virtual ICollection<QuestionGrammar> QuestionGrammars { get; set; } = new List<QuestionGrammar>();
}
