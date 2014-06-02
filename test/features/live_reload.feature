Feature: Live reloading of the browser

  Background:
    Given I have a roots project
    And I am watching it

  Scenario: Reloading on file change
    When I replace "views/index.jade" with "<h1><span>wow such magic</span></h1>"
    Then I should see a "h1" tag with "wow such magic"
