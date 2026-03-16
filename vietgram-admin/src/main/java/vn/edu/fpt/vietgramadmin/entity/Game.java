package vn.edu.fpt.vietgramadmin.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "games")
@Data
public class Game {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "map_id")
    private Integer mapId;

    private String name;

    @Column(name = "game_type")
    private String gameType;

    @Column(name = "flow", columnDefinition = "NVARCHAR(MAX)")
    private String flow;

    @Column(name = "order_index")
    private Integer orderIndex;

    @Column(name = "is_premium")
    private Boolean isPremium;

    @Column(name = "is_active")
    private Boolean isActive;
}
