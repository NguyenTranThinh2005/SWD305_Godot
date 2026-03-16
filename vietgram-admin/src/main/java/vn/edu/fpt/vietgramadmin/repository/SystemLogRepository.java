package vn.edu.fpt.vietgramadmin.repository;

import vn.edu.fpt.vietgramadmin.entity.SystemLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface SystemLogRepository extends JpaRepository<SystemLog, Integer> {
    List<SystemLog> findTop100ByOrderByCreatedAtDesc();
    List<SystemLog> findByUserIdOrderByCreatedAtDesc(Integer userId);
}
