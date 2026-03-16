package vn.edu.fpt.vietgramadmin.repository;

import vn.edu.fpt.vietgramadmin.entity.Report;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ReportRepository extends JpaRepository<Report, Integer> {
    List<Report> findByStatusOrderByCreatedAtDesc(String status);
    List<Report> findAllByOrderByCreatedAtDesc();

    @Query("SELECT COUNT(r) FROM Report r WHERE r.status = 'pending'")
    long countPending();
}
