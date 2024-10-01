@my_profile @passports_visas @documents
Feature: My profile : Passports Visas : Documents


    @reset
    Scenario: Test My Documents in Cabinet

        Given I enter to app
        Then I select "Me" tab
        Then I wait to see "My profile"
        Then I wait see and press "My profile"
        Then I press back
        Then I wait to see "My cards"

        Then I wait see and press "My profile"
        Then I see navigation bar titled "My profile"
        Then I check segment "Contacts" is selected
        Then I wait see and press "Passports/Visas"
        Then I check segment "Passports/Visas" is selected
        Then I compare screen image with golden
        Then I wait see and press "add passport"
        Then I compare screen image with golden
        Then I press back

        Then I check segment "Passports/Visas" is selected
        Then I wait see and press "add passport"
        Then I scroll down to find "Passport Number"
        Then I press "Passport Number" text field
        Then I check keyboard is open
        Then I enter text "AH 555555"
        Then I press Save
        Then I wait to see "AH 555555"

        Then I wait see and press "add visa"
        Then I compare screen image with golden
        Then I press back
        Then I wait see and press "add visa"
        Then I scroll down to find "Comments"
        Then I press "If present" text field
        Then I change the date picker date to "2025-01-01"
        Then I wait see and press "Select"
        Then I press Save
        Then I wait to see text "until: 2025-01-01"
        Then I press back
        Then I wait to see text "My cards"
