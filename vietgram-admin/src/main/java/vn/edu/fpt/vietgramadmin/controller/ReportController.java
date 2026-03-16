package vn.edu.fpt.vietgramadmin.controller;

import vn.edu.fpt.vietgramadmin.entity.Report;
import vn.edu.fpt.vietgramadmin.repository.ReportRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.edu.fpt.vietgramadmin.repository.UserRepository;

import java.time.LocalDateTime;
import java.util.List;

@Controller
@RequestMapping("/reports")
public class ReportController {

    private final ReportRepository reportRepo;
    private final UserRepository userRepo;

    public ReportController(ReportRepository reportRepo, UserRepository userRepo) {
        this.reportRepo = reportRepo;
        this.userRepo = userRepo;
    }

    @GetMapping
    public String listReports(@RequestParam(required = false) String status, Model model) {
        List<Report> reports;
        if (status != null && !status.isBlank()) {
            reports = reportRepo.findByStatusOrderByCreatedAtDesc(status);
        } else {
            reports = reportRepo.findAllByOrderByCreatedAtDesc();
        }
        model.addAttribute("reports", reports);
        model.addAttribute("selectedStatus", status);
        return "reports/list";
    }

    @GetMapping("/{id}")
    public String viewReport(@PathVariable Integer id, Model model) {
        Report report = reportRepo.findById(id)
            .orElseThrow(() -> new RuntimeException("Report not found"));
        model.addAttribute("report", report);
        // load reporter info
        if (report.getUserId() != null) {
            userRepo.findById(report.getUserId()).ifPresent(u -> model.addAttribute("reporter", u));
        }
        return "reports/detail";
    }

    @PostMapping("/{id}/resolve")
    public String resolveReport(@PathVariable Integer id, RedirectAttributes ra) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String email = auth.getName();
        userRepo.findByEmail(email).ifPresent(staff -> {
            reportRepo.findById(id).ifPresent(r -> {
                r.setStatus("resolved");
                r.setResolvedBy(staff.getId());
                r.setResolvedAt(LocalDateTime.now());
                reportRepo.save(r);
            });
        });
        ra.addFlashAttribute("success", "Report resolved.");
        return "redirect:/reports";
    }

    @PostMapping("/{id}/investigate")
    public String investigateReport(@PathVariable Integer id, RedirectAttributes ra) {
        reportRepo.findById(id).ifPresent(r -> {
            r.setStatus("investigated");
            reportRepo.save(r);
        });
        ra.addFlashAttribute("success", "Report marked as under investigation.");
        return "redirect:/reports";
    }
}
