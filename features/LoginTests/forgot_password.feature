@login @forgot_password
Feature: Login : Forgor password


    @reset
    Scenario: Prepare App for Forgot Password

        # Login to app to logout for Forgot Password testing
        Given I enter to app


    Scenario: Testing Forgor Password

        # Check Forget password exists in code screen
        Given I am on start screen
        Then I wait to see "Enter password"
        Then I wait to see "Enter password to login"
        Then I wait to see "«Forgot password»"

        # Check Forgot password functionality
        Then I wait see and press "«Forgot password»"
        Then I wait
        Then I validate registration screen:
            | countery name | Armenia  |
            | countery code | +374     |
            | phone number  | 77661200 |
        Then I wait to see "To use the application Art Of Life please enter your phone number"
        Then I check "Cancel" button is enabled

        # Check Cancel button
        Then I wait see and press "Cancel"
        Then I wait to see "Enter password"
        Then I wait to see "Enter password to login"
        Then I wait to see "«Forgot password»"
        Then I wait see and press "«Forgot password»"

        # Check Next button
        Then I wait see and press "Next"
        Then I wait
        Then I wait to see "+37477661200" of "Label" type
        Then I wait to see "We sent you code with sms" of "Label" type
        Then I wait to see "Code" of "TextFieldLabel" type
        Then I wait to see "Back" navigation button

        # Check back button
        Then I press back
        Then I wait to see "Your phone number"
        Then I wait to see "Armenia"
        Then I wait to see "77661200" of "FieldEditor" type
        Then I check "Next" button is enabled
        Then I check "Cancel" button is enabled
        Then I wait see and press "Next"

        # Check code verification button
        Then I enter verification code 7777
        Then I wait to see "Create a password"
        Then I wait to see "Write a password which you will use to enter application Art Of Life"
        Then I enter password 0000
        Then I wait
        Then I wait to see "Repeat password"
        Then I should not see "Write a password which you will use to enter application Art Of Life"
        Then I enter password 0000

        # Validate Tab bar
        Then I validate tab bar buttons
