using System;
using System.Collections.Generic;

namespace SWD305.Models;

public partial class Task
{
    public int Id { get; set; }

    public int? TeamId { get; set; }

    public string? Type { get; set; }

    public string? Criteria { get; set; }

    public string? Reward { get; set; }

    public int CreatedBy { get; set; }

    public DateTime? DueDate { get; set; }

    public bool? IsActive { get; set; }

    public DateTime? CreatedAt { get; set; }

    public DateTime? UpdatedAt { get; set; }

    public virtual User CreatedByNavigation { get; set; } = null!;

    public virtual ICollection<TaskProgress> TaskProgresses { get; set; } = new List<TaskProgress>();

    public virtual Team? Team { get; set; }
}
