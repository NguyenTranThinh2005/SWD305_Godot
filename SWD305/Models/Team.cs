using System;
using System.Collections.Generic;

namespace SWD305.Models;

public partial class Team
{
    public int Id { get; set; }

    public int OwnerId { get; set; }

    public string? Name { get; set; }

    public string? Description { get; set; }

    public string? InviteCode { get; set; }

    public DateTime? CreatedAt { get; set; }

    public virtual User Owner { get; set; } = null!;

    public virtual ICollection<Task> Tasks { get; set; } = new List<Task>();

    public virtual ICollection<TeamMember> TeamMembers { get; set; } = new List<TeamMember>();
}
