using System;
using System.Collections.Generic;

namespace SWD305.Models;

public partial class Map
{
    public int Id { get; set; }

    public int? GradeId { get; set; }

    public string Name { get; set; } = null!;

    public int? OrderIndex { get; set; }

    public bool? IsActive { get; set; }

    public virtual ICollection<Game> Games { get; set; } = new List<Game>();

    public virtual Grade? Grade { get; set; }
}
