package vn.edu.fpt.vietgramadmin.repository;

import vn.edu.fpt.vietgramadmin.entity.GameSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

@Repository
public interface GameSessionRepository extends JpaRepository<GameSession, Integer> {
    @Query(value = "SELECT COUNT(*) FROM game_sessions WHERE CAST(completed_at AS date) = CAST(GETDATE() AS date)", nativeQuery = true)
    long countToday();

    @Query("SELECT AVG(gs.accuracy) FROM GameSession gs")
    Double avgAccuracy();
}
