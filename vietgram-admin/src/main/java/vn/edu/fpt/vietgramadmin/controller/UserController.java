package vn.edu.fpt.vietgramadmin.controller;

import vn.edu.fpt.vietgramadmin.entity.User;
import vn.edu.fpt.vietgramadmin.repository.UserRepository;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

@Controller
@RequestMapping("/users")
public class UserController {

    private final UserRepository userRepo;

    public UserController(UserRepository userRepo) {
        this.userRepo = userRepo;
    }

    @GetMapping
    public String listUsers(@RequestParam(required = false) String role,
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "1") int page,
            Model model) {
        int pageSize = 10;
        Pageable pageable = PageRequest.of(page - 1, pageSize);
        Page<User> userPage;

        if (role != null && !role.isBlank()) {
            userPage = userRepo.findByRole(role, pageable);
        } else if ("suspended".equals(status)) {
            userPage = userRepo.findByIsActive(false, pageable);
        } else {
            userPage = userRepo.findAll(pageable);
        }

        model.addAttribute("users", userPage.getContent());
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", userPage.getTotalPages());
        model.addAttribute("totalItems", userPage.getTotalElements());
        model.addAttribute("selectedRole", role);
        model.addAttribute("selectedStatus", status);
        return "users/list";
    }

    @GetMapping("/{id}")
    public String viewUser(@PathVariable Integer id, Model model) {
        User user = userRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));
        model.addAttribute("user", user);
        return "users/detail";
    }

    @PostMapping("/{id}/suspend")
    public String suspendUser(@PathVariable Integer id, RedirectAttributes ra) {
        userRepo.findById(id).ifPresent(u -> {
            u.setIsActive(false);
            userRepo.save(u);
        });
        ra.addFlashAttribute("success", "User suspended successfully.");
        return "redirect:/users";
    }

    @PostMapping("/{id}/activate")
    public String activateUser(@PathVariable Integer id, RedirectAttributes ra) {
        userRepo.findById(id).ifPresent(u -> {
            u.setIsActive(true);
            userRepo.save(u);
        });
        ra.addFlashAttribute("success", "User reactivated successfully.");
        return "redirect:/users";
    }
}
