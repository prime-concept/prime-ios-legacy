@login @splash
Feature: Login : Splash : Very first start


    @reset
    Scenario: Check splash screen appears at very first starts

        Given I am on start screen
        Then I compare screen image with golden
        Then I wait to see "I am PRIME"


    Scenario: Restart app when splash screen is shown
        check the splash screen shown again after second run

        Given I am on start screen
        Then I wait to see "I am PRIME"
        Then I should not see "Russia"
