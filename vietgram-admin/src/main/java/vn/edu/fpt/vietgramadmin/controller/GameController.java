package vn.edu.fpt.vietgramadmin.controller;

import vn.edu.fpt.vietgramadmin.entity.Game;
import vn.edu.fpt.vietgramadmin.repository.GameRepository;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/admin/games")
public class GameController {

    private final GameRepository gameRepo;

    public GameController(GameRepository gameRepo) {
        this.gameRepo = gameRepo;
    }

    @GetMapping
    public String listGames(Model model) {
        model.addAttribute("games", gameRepo.findAll());
        return "games/list";
    }

    @GetMapping("/new")
    public String newGameForm(Model model) {
        model.addAttribute("game", new Game());
        return "games/form";
    }

    @GetMapping("/{id}/edit")
    public String editGameForm(@PathVariable Integer id, Model model) {
        Game game = gameRepo.findById(id)
            .orElseThrow(() -> new RuntimeException("Game not found"));
        model.addAttribute("game", game);
        return "games/form";
    }

    @PostMapping("/save")
    public String saveGame(@ModelAttribute Game game, RedirectAttributes ra) {
        if (game.getIsActive() == null) game.setIsActive(true);
        if (game.getIsPremium() == null) game.setIsPremium(false);
        gameRepo.save(game);
        ra.addFlashAttribute("success", "Game saved successfully.");
        return "redirect:/admin/games";
    }

    @PostMapping("/{id}/toggle")
    public String toggleActive(@PathVariable Integer id, RedirectAttributes ra) {
        gameRepo.findById(id).ifPresent(g -> {
            g.setIsActive(!Boolean.TRUE.equals(g.getIsActive()));
            gameRepo.save(g);
        });
        ra.addFlashAttribute("success", "Game status toggled.");
        return "redirect:/admin/games";
    }

    @PostMapping("/{id}/delete")
    public String deleteGame(@PathVariable Integer id, RedirectAttributes ra) {
        gameRepo.deleteById(id);
        ra.addFlashAttribute("success", "Game deleted.");
        return "redirect:/admin/games";
    }
}
