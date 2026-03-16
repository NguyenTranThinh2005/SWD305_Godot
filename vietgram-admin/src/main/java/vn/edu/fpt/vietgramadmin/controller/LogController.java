package vn.edu.fpt.vietgramadmin.controller;

import vn.edu.fpt.vietgramadmin.repository.SystemLogRepository;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/logs")
public class LogController {

    private final SystemLogRepository logRepo;

    public LogController(SystemLogRepository logRepo) {
        this.logRepo = logRepo;
    }

    @GetMapping
    public String listLogs(Model model) {
        model.addAttribute("logs", logRepo.findTop100ByOrderByCreatedAtDesc());
        return "logs/list";
    }
}
