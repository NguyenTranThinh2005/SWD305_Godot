package vn.edu.fpt.vietgramadmin.controller;

import vn.edu.fpt.vietgramadmin.repository.*;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class DashboardController {

    private final UserRepository userRepo;
    private final ReportRepository reportRepo;
    private final GameSessionRepository sessionRepo;
    private final GameRepository gameRepo;
    private final SystemLogRepository logRepo;

    public DashboardController(UserRepository userRepo, ReportRepository reportRepo,
                               GameSessionRepository sessionRepo, GameRepository gameRepo,
                               SystemLogRepository logRepo) {
        this.userRepo = userRepo;
        this.reportRepo = reportRepo;
        this.sessionRepo = sessionRepo;
        this.gameRepo = gameRepo;
        this.logRepo = logRepo;
    }

    @GetMapping("/")
    public String root() { return "redirect:/dashboard"; }

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        model.addAttribute("totalUsers", userRepo.count());
        model.addAttribute("activeUsers", userRepo.countActive());
        model.addAttribute("suspendedUsers", userRepo.countSuspended());
        model.addAttribute("pendingReports", reportRepo.countPending());
        model.addAttribute("totalGames", gameRepo.count());
        model.addAttribute("todaySessions", sessionRepo.countToday());

        Double avg = sessionRepo.avgAccuracy();
        model.addAttribute("avgAccuracy", avg != null ? String.format("%.1f", avg) : "N/A");

        model.addAttribute("recentLogs", logRepo.findTop100ByOrderByCreatedAtDesc().stream().limit(5).toList());
        model.addAttribute("pendingReportsList", reportRepo.findByStatusOrderByCreatedAtDesc("pending").stream().limit(5).toList());
        return "dashboard";
    }

    @GetMapping("/login")
    public String login() { return "login"; }
}
