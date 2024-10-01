@login @splash
Feature: Login : Splash : Click on I am PRIME


    @reset
    Scenario: Check that clicking on 'I am PRIME' button opens app first screen

        Given I am on start screen
        Then I wait to see "I am PRIME"
        Then I compare screen image with golden
        Then I wait see and press "I am PRIME"
        Then I hide the keyboard
        Then I compare screen image with golden
        Then I validate registration screen:
            | countery name | Russia            |
            | countery code | +7                |
            | phone number  | Your phone number |


    Scenario: Check that second start opens splash screen
        when the splash screen was closed by pressing I am PRIME

        Given I am on start screen
        Then I wait to see "I am PRIME"
        Then I compare screen image with golden
        Then I should not see "Russia"

