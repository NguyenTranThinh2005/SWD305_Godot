package vn.edu.fpt.vietgramadmin.repository;

import vn.edu.fpt.vietgramadmin.entity.Game;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface GameRepository extends JpaRepository<Game, Integer> {
    List<Game> findByIsActiveOrderByOrderIndexAsc(Boolean isActive);
}
