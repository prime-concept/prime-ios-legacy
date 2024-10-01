@my_profile @passports_visas @passport
Feature: My profile : Passports Visas : Add passport : Add passport details


    @reset
    Scenario: Test Add passport details in Cabinet

        Given I enter to app
        Then I select "Me" tab
        Then I wait to see "My profile"
        Then I wait see and press "My profile"
        Then I wait see and press "Passports/Visas"

        # Test back button
        Then I wait see and press "add passport"
        Then I scroll down to find "Passport Number"
        Then I wait
        Then I press "Passport Number" text field
        Then I check keyboard is open
        Then I enter text "111111"
        Then I press back
        Then I wait to not see "111111"

        # Test Date of Birth picker field
        Then I wait see and press "add passport"
        Then I press "Date of Birth" text field
        Then I change the date picker date to "2016-01-01"
        Then I press "Cancel"
        Then I wait to not see "2016-01-01"
        Then I press "Date of Birth" text field
        Then I expect fail "could not change date on picker" after executing 'I change the date picker date to "2025-02-02"'
        Then I press "Select"
        Then I press current date in text field
        Then I change the date picker date to "2016-02-02"
        Then I press "Select"

        # Test Place of Birth text field
        Then I press "Place of Birth" text field
        Then I check keyboard is open
        Then I enter text "place_of_birth"
        Then I hide the keyboard

        # Test Citizenship text field
        Then I press "Citizenship" text field
        Then I check keyboard is open
        Then I enter text "citizenship"
        Then I hide the keyboard

        # Test Country picker field
        Then I press "Russia" text field
        Then I wait see and press "Cancel"
        Then I wait to see text "Russia"
        Then I press "Russia" text field
        Then I wait see and press "Romania"
        Then I wait see and press "Select"
        Then I wait to see text "Romania"

        # Test Passport Number text field
        Then I press "Passport Number" text field
        Then I check keyboard is open
        Then I enter text "111111"

        Then I press Save
        Then I check segment "Passports/Visas" is selected
        Then I wait to see "111111"
        Then I wait to see "Romania"


    @reset
    Scenario: Test Edit passport details in Cabinet

        Given I enter to app
        Then I select "Me" tab
        Then I wait to see "My profile"
        Then I wait see and press "My profile"
        Then I wait see and press "Passports/Visas"
        Then I wait see and press "111111"
        Then I see navigation bar titled "Passport"

        # Test back button
        Then I scroll down to find "111111"
        Then I wait
        Then I press "111111" text field
        Then I enter text "_test"
        Then I press back
        Then I wait to not see "111111_test"

        # Test Place of Birth picker field
        Then I wait see and press "111111"
        Then I press "2016-02-02" text field
        Then I change the date picker date to "2016-03-03"
        Then I wait see and press "Select"

        # Test Place of Birth text field
        Then I press "place_of_birth" text field
        Then I enter text "_test"
        Then I hide the keyboard

        # Test Citizenship text field
        Then I press "citizenship" text field
        Then I enter text "_test"
        Then I hide the keyboard

        # Test Country picker field
        Then I wait see and press "Romania"
        Then I wait see and press "Qatar"
        Then I wait see and press "Select"

        # Test Passport Number text field
        Then I press "111111" text field
        Then I enter text "_test"

        Then I press Save
        Then I check segment "Passports/Visas" is selected
        Then I wait to see "Qatar"

        Then I wait see and press "111111_test"
        Then I scroll down to find "111111_test"
        Then I wait
        Then I wait to see text "111111_test"
        Then I wait to see text "2016-03-03"
        Then I wait to see text "place_of_birth_test"
        Then I wait to see text "citizenship_test"
        Then I wait to see text "Qatar"


    @reset_db_after_scenario
    Scenario: Test delete passport in Cabinet- reset db after this scenario

        Given I enter password in start screen
        Then I validate tab bar buttons
        Then I wait
        Then I select "Me" tab
        Then I wait to see "My profile"
        Then I wait see and press "My profile"
        Then I wait see and press "Passports/Visas"
        Then I wait see and press "111111_test"
        Then I scroll down to find "Delete passport"
        Then I wait
        Then I wait see and press "Delete passport"
        Then I check segment "Passports/Visas" is selected
        Then I wait to not see "111111_test"
