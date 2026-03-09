using System;
using System.Collections.Generic;

namespace SWD305.Models;

public partial class Report
{
    public int Id { get; set; }

    public int? UserId { get; set; }

    public string? Type { get; set; }

    public string? Description { get; set; }

    public string? Status { get; set; }

    public int? ResolvedBy { get; set; }

    public DateTime? ResolvedAt { get; set; }

    public virtual User? ResolvedByNavigation { get; set; }

    public virtual User? User { get; set; }
}
