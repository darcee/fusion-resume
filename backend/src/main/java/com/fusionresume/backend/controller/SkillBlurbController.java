package com.fusionresume.backend.controller;

import com.fusionresume.backend.entity.SkillBlurb;
import com.fusionresume.backend.service.SkillBlurbService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/skill-blurbs")
@CrossOrigin(origins = "*")
public class SkillBlurbController {

    private final SkillBlurbService skillBlurbService;

    @Autowired
    public SkillBlurbController(SkillBlurbService skillBlurbService) {
        this.skillBlurbService = skillBlurbService;
    }

    @PostMapping
    public ResponseEntity<SkillBlurb> createSkillBlurb(@Valid @RequestBody SkillBlurb skillBlurb) {
        SkillBlurb savedBlurb = skillBlurbService.save(skillBlurb);
        return new ResponseEntity<>(savedBlurb, HttpStatus.CREATED);
    }

    @GetMapping
    public ResponseEntity<List<SkillBlurb>> getAllSkillBlurbs() {
        List<SkillBlurb> blurbs = skillBlurbService.findAll();
        return ResponseEntity.ok(blurbs);
    }

    @GetMapping("/{id}")
    public ResponseEntity<SkillBlurb> getSkillBlurbById(@PathVariable Long id) {
        Optional<SkillBlurb> blurb = skillBlurbService.findById(id);
        return blurb.map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<SkillBlurb>> getSkillBlurbsByUserId(@PathVariable Long userId) {
        List<SkillBlurb> blurbs = skillBlurbService.findByUserId(userId);
        return ResponseEntity.ok(blurbs);
    }

    @GetMapping("/search")
    public ResponseEntity<List<SkillBlurb>> searchSkillBlurbs(
            @RequestParam Long userId,
            @RequestParam(required = false) String title,
            @RequestParam(required = false) String keyword) {

        List<SkillBlurb> blurbs;
        if (title != null) {
            blurbs = skillBlurbService.findByUserIdAndTitle(userId, title);
        } else if (keyword != null) {
            blurbs = skillBlurbService.findByUserIdAndKeyword(userId, keyword);
        } else {
            blurbs = skillBlurbService.findByUserId(userId);
        }
        return ResponseEntity.ok(blurbs);
    }

    @PutMapping("/{id}")
    public ResponseEntity<SkillBlurb> updateSkillBlurb(@PathVariable Long id, @Valid @RequestBody SkillBlurb skillBlurb) {
        if (!skillBlurbService.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        skillBlurb.setId(id);
        SkillBlurb updatedBlurb = skillBlurbService.save(skillBlurb);
        return ResponseEntity.ok(updatedBlurb);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteSkillBlurb(@PathVariable Long id) {
        if (!skillBlurbService.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        skillBlurbService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}