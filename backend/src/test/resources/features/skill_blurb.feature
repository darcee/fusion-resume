Feature: Skill Blurb Management
  As a job seeker
  I want to manage my skill blurbs
  So that I can build tailored resumes

  Scenario: Create a new skill blurb
    Given I am authenticated
    When I create a skill blurb with title "AWS" and content "3+ years cloud architecture"
    Then the blurb should be saved
    And I should be able to retrieve it by ID