using System;
using System.Collections.Generic;

namespace SWD305.Models;

public partial class TaskProgress
{
    public int Id { get; set; }

    public int TaskId { get; set; }

    public int UserId { get; set; }

    public int? CurrentProgress { get; set; }

    public int? TargetValue { get; set; }

    public string? Status { get; set; }

    public DateTime? CompletedAt { get; set; }

    public virtual Task Task { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
