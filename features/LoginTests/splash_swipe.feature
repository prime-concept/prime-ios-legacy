@login @splash
Feature: Login : Splash : Swipe on screen


    @reset
    Scenario: Check swipe on splash screen works

        Given I am on start screen
        Then I wait to see "I am PRIME"
        Then I swipe left splash screen to find "PRIME Traveller Magazine"
        Then I compare screen image with golden
        Then I swipe left splash screen to find "I am PRIME"
        Then I swipe screen to left
        Then I swipe screen to right
        Then I wait to see "I am PRIME"
