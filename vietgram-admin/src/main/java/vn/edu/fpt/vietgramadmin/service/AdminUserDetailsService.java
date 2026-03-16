package vn.edu.fpt.vietgramadmin.service;

import vn.edu.fpt.vietgramadmin.entity.User;
import vn.edu.fpt.vietgramadmin.repository.UserRepository;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.*;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AdminUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;

    public AdminUserDetailsService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        User user = userRepository.findByEmail(email)
            .orElseThrow(() -> new UsernameNotFoundException("User not found: " + email));

        if (!List.of("staff", "admin").contains(user.getRole())) {
            throw new UsernameNotFoundException("Access denied: insufficient role");
        }

        String springRole = "ROLE_" + user.getRole().toUpperCase();
        return org.springframework.security.core.userdetails.User
            .withUsername(user.getEmail())
            .password(user.getPasswordHash())
            .authorities(new SimpleGrantedAuthority(springRole))
            .accountLocked(!Boolean.TRUE.equals(user.getIsActive()))
            .build();
    }
}
