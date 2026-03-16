package vn.edu.fpt.vietgramadmin.repository;

import vn.edu.fpt.vietgramadmin.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

@Repository
public interface UserRepository extends JpaRepository<User, Integer> {
    Optional<User> findByEmail(String email);

    Page<User> findByRole(String role, Pageable pageable);

    Page<User> findByIsActive(Boolean isActive, Pageable pageable);

    @Query("SELECT COUNT(u) FROM User u WHERE u.isActive = true")
    long countActive();

    @Query("SELECT COUNT(u) FROM User u WHERE u.isActive = false")
    long countSuspended();

    @Query("SELECT COUNT(u) FROM User u WHERE u.role = ?1")
    long countByRole(String role);
}
