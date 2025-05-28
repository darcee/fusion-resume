package com.fusionresume.backend.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fusionresume.backend.entity.SkillBlurb;
import com.fusionresume.backend.service.SkillBlurbService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(SkillBlurbController.class)
class SkillBlurbControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private SkillBlurbService skillBlurbService;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void shouldCreateSkillBlurb() throws Exception {
        SkillBlurb inputBlurb = new SkillBlurb();
        inputBlurb.setTitle("AWS");
        inputBlurb.setContent("3+ years designing scalable cloud architectures using AWS services including EC2, S3, Lambda, and RDS.");
        inputBlurb.setKeywords("aws,cloud,ec2,s3,lambda,rds");

        SkillBlurb savedBlurb = new SkillBlurb();
        savedBlurb.setId(1L);
        savedBlurb.setTitle("AWS");
        savedBlurb.setContent("3+ years designing scalable cloud architectures using AWS services including EC2, S3, Lambda, and RDS.");
        savedBlurb.setKeywords("aws,cloud,ec2,s3,lambda,rds");

        when(skillBlurbService.save(any(SkillBlurb.class))).thenReturn(savedBlurb);

        mockMvc.perform(post("/api/skill-blurbs")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(inputBlurb)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.title").value("AWS"))
                .andExpect(jsonPath("$.content").value("3+ years designing scalable cloud architectures using AWS services including EC2, S3, Lambda, and RDS."))
                .andExpect(jsonPath("$.keywords").value("aws,cloud,ec2,s3,lambda,rds"));
    }

    @Test
    void shouldGetAllSkillBlurbs() throws Exception {

        SkillBlurb blurb1 = new SkillBlurb(1L, "AWS", "AWS experience", "aws,cloud");
        SkillBlurb blurb2 = new SkillBlurb(2L, "Java", "Java experience", "java,spring");

        when(skillBlurbService.findAll()).thenReturn(Arrays.asList(blurb1, blurb2));
        mockMvc.perform(get("/api/skill-blurbs"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(2))
                .andExpect(jsonPath("$[0].title").value("AWS"))
                .andExpect(jsonPath("$[1].title").value("Java"));
    }

    @Test
    void shouldGetSkillBlurbById() throws Exception {

        SkillBlurb blurb = new SkillBlurb(1L, "React", "React development experience", "react,javascript,frontend");

        when(skillBlurbService.findById(1L)).thenReturn(Optional.of(blurb));
        mockMvc.perform(get("/api/skill-blurbs/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.title").value("React"));
    }

    @Test
    void shouldReturn404WhenSkillBlurbNotFound() throws Exception {

        when(skillBlurbService.findById(999L)).thenReturn(Optional.empty());
        mockMvc.perform(get("/api/skill-blurbs/999"))
                .andExpect(status().isNotFound());
    }

    @Test
    void shouldDeleteSkillBlurb() throws Exception {

        when(skillBlurbService.existsById(1L)).thenReturn(true);

        mockMvc.perform(delete("/api/skill-blurbs/1"))
                .andExpect(status().isNoContent());
    }
}