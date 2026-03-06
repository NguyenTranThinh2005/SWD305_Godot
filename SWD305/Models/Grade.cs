using System;
using System.Collections.Generic;

namespace SWD305.Models;

public partial class Grade
{
    public int Id { get; set; }

    public string? Name { get; set; }

    public virtual ICollection<Map> Maps { get; set; } = new List<Map>();
}
