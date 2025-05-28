package com.fusionresume.backend.service;

import com.fusionresume.backend.entity.SkillBlurb;
import com.fusionresume.backend.repository.SkillBlurbRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class SkillBlurbService {

    private final SkillBlurbRepository skillBlurbRepository;

    @Autowired
    public SkillBlurbService(SkillBlurbRepository skillBlurbRepository) {
        this.skillBlurbRepository = skillBlurbRepository;
    }

    public SkillBlurb save(SkillBlurb skillBlurb) {
        return skillBlurbRepository.save(skillBlurb);
    }

    public List<SkillBlurb> findAll() {
        return skillBlurbRepository.findAll();
    }

    public Optional<SkillBlurb> findById(Long id) {
        return skillBlurbRepository.findById(id);
    }

    public List<SkillBlurb> findByUserId(Long userId) {
        return skillBlurbRepository.findByUserId(userId);
    }

    public List<SkillBlurb> findByUserIdAndTitle(Long userId, String title) {
        return skillBlurbRepository.findByUserIdAndTitleContainingIgnoreCase(userId, title);
    }

    public List<SkillBlurb> findByUserIdAndKeyword(Long userId, String keyword) {
        return skillBlurbRepository.findByUserIdAndKeywordsContainingIgnoreCase(userId, keyword);
    }

    public void deleteById(Long id) {
        skillBlurbRepository.deleteById(id);
    }

    public boolean existsById(Long id) {
        return skillBlurbRepository.existsById(id);
    }
}