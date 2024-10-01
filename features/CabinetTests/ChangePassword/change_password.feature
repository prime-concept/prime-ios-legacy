@cabinet @change_password
Feature: Cabinet : Change password


    @reset
    Scenario: Test Change password in Cabinet

        Given I enter to app
        Then I select "Me" tab
        Then I scroll down to find "Change password"
        Then I wait see and press "Change password"
        Then I wait to see "Back"
        Then I wait to see "Current password"
        Then I wait to see "Please, enter current password."
        Then I enter password 0000

        Then I wait to see "Create a password"
        Then I wait to see "Write a password which you will use to enter application Art Of Life"
        Then I hide the keyboard
        Then I compare screen image with golden
        Then I press password field
        Then I enter password 1111
        Then I wait to see "Repeat password"
        Then I hide the keyboard

        Then I wait see and press "Back"
        Then I wait to see "Create a password"
        Then I press password field
        Then I enter password 1111

        Then I wait to see "Repeat password"
        Then I enter password 2222
        Then I should see text starting with "Passwords don"
        Then I should see text ending with "t match."
        # FIXME(open test): to avoid task PRIM-556
        Then I enter password 1111
        Then I wait to see "My profile"

