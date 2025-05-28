package com.fusionresume.backend.repository;

import com.fusionresume.backend.entity.SkillBlurb;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SkillBlurbRepository extends JpaRepository<SkillBlurb, Long> {

    List<SkillBlurb> findByUserId(Long userId);

    List<SkillBlurb> findByUserIdAndTitleContainingIgnoreCase(Long userId, String title);

    List<SkillBlurb> findByUserIdAndKeywordsContainingIgnoreCase(Long userId, String keyword);
}