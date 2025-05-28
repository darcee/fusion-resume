package com.fusionresume.backend.steps;

import com.fusionresume.backend.entity.SkillBlurb;
import com.fusionresume.backend.service.SkillBlurbService;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.When;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.And;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@ActiveProfiles("test")
public class SkillBlurbStepDefinitions {

    @Autowired
    private SkillBlurbService skillBlurbService;

    private SkillBlurb createdBlurb;
    private Long currentUserId = 1L; // Mock authenticated user

    @Given("I am authenticated")
    public void i_am_authenticated() {
        // In a real app, this would verify JWT token or session
        // For now, we'll assume user ID 1 is authenticated
        assertNotNull(currentUserId);
    }

    @When("I create a skill blurb with title {string} and content {string}")
    public void i_create_a_skill_blurb_with_title_and_content(String title, String content) {
        SkillBlurb blurb = new SkillBlurb();
        blurb.setTitle(title);
        blurb.setContent(content);
        blurb.setUserId(currentUserId);

        // Auto-generate keywords from title and content
        String keywords = generateKeywords(title, content);
        blurb.setKeywords(keywords);

        createdBlurb = skillBlurbService.save(blurb);
    }

    @Then("the blurb should be saved")
    public void the_blurb_should_be_saved() {
        assertNotNull(createdBlurb);
        assertNotNull(createdBlurb.getId());
        assertTrue(createdBlurb.getId() > 0);
    }

    @And("I should be able to retrieve it by ID")
    public void i_should_be_able_to_retrieve_it_by_id() {
        Long blurbId = createdBlurb.getId();
        SkillBlurb retrievedBlurb = skillBlurbService.findById(blurbId)
                .orElseThrow(() -> new AssertionError("Blurb not found with ID: " + blurbId));

        assertEquals(createdBlurb.getTitle(), retrievedBlurb.getTitle());
        assertEquals(createdBlurb.getContent(), retrievedBlurb.getContent());
        assertEquals(createdBlurb.getUserId(), retrievedBlurb.getUserId());
    }

    private String generateKeywords(String title, String content) {
        // Simple keyword extraction - in real app, this might use NLP
        String combined = (title + " " + content).toLowerCase();
        return combined.replaceAll("[^a-zA-Z0-9\\s]", "")
                .replaceAll("\\s+", ",");
    }
}