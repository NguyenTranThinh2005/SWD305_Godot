package vn.edu.fpt.vietgramadmin.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Table(name = "game_sessions")
@Data
public class GameSession {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "user_id")
    private Integer userId;

    @Column(name = "game_id")
    private Integer gameId;

    private Integer score;
    private Integer stars;
    private Integer coins;

    @Column(name = "accuracy")
    private Double accuracy;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;
}
