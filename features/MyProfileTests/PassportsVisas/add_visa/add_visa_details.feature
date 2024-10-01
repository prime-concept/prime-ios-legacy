@my_profile @passports_visas @passport
Feature: My profile : Passports Visas : Add visa : Add visa details


    @reset
    Scenario: Test Add visa details in Cabinet

        Given I enter to app
        Then I select "Me" tab
        Then I wait to see "My profile"
        Then I wait see and press "My profile"
        Then I wait see and press "Passports/Visas"
        Then I wait see and press "add visa"

        # Test back button
        Then I scroll down to find "Expiration date"
        Then I wait see and press "If present"
        Then I change the date picker date to "2030-02-02"
        Then I wait see and press "Select"
        Then I press back
        Then I wait to not see "until: 2030-02-02"

        # Test Date of Birth picker field
        Then I wait see and press "add visa"
        Then I press "Date of Birth" text field
        Then I change the date picker date to "2016-01-01"
        Then I wait see and press "Cancel"
        Then I wait to not see "2016-01-01"
        Then I press "Date of Birth" text field
        Then I expect fail "could not change date on picker" after executing 'I change the date picker date to "2025-02-02"'
        Then I wait see and press "Select"
        Then I press current date in text field
        Then I change the date picker date to "2016-02-02"
        Then I wait see and press "Select"

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
        Then I wait see and press "Rwanda"
        Then I wait see and press "Select"
        Then I wait to see text "Rwanda"

        # Test Visa type picker field
        Then I press "Visa type" text field
        Then I wait see and press "Cancel"
        Then I press "Visa type" text field
        Then I wait see and press "multiple-entry"
        Then I wait see and press "Select"

        # Test Visa Number text field
        Then I press "Visa Number" text field
        Then I check keyboard is open
        Then I enter text "888888"

        # Test Expiration date picker field
        Then I scroll down to find "Expiration date"
        Then I scroll down
        Then I wait
        Then I press "If present" text field
        Then I change the date picker date to "2030-02-02"
        Then I wait see and press "Select"

        Then I press Save
        Then I check segment "Passports/Visas" is selected
        Then I wait to see "until: 2030-02-02"
        Then I wait to see "Visa Rwanda"

    Scenario: Test Edit visa details in Cabinet

        Given I enter to app
        Then I select "Me" tab
        Then I wait to see "My profile"
        Then I wait see and press "My profile"
        Then I wait see and press "Passports/Visas"
        Then I wait see and press "until: 2030-02-02"
        Then I see navigation bar titled "Visa - multiple-entry"

        # Test back button
        Then I scroll down to find "2030-02-02"
        Then I wait
        Then I press "2030-02-02" text field
        Then I change the date picker date to "2032-02-02"
        Then I wait see and press "Select"
        Then I press back
        Then I wait to not see "2032-02-02"

        # Test Date of Birth picker field
        Then I wait see and press "until: 2030-02-02"
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
        Then I wait see and press "Rwanda"
        Then I wait see and press "San Marino"
        Then I wait see and press "Select"

        # Test Visa type picker field
        Then I press "multiple-entry" text field
        Then I wait see and press "single-entry"
        Then I wait see and press "Select"

        # Test Visa Number text field
        Then I press "888888" text field
        Then I check keyboard is open
        Then I enter text "_test"

        Then I press Save
        Then I check segment "Passports/Visas" is selected
        Then I wait to see "Visa San Marino"

        Then I wait see and press "until: 2030-02-02"
        Then I scroll down to find "888888_test"
        Then I wait
        Then I wait to see text "2016-03-03"
        Then I wait to see text "place_of_birth_test"
        Then I wait to see text "citizenship_test"
        Then I wait to see text "San Marino"

    @reset_db_after_scenario
    Scenario: Test delete visa in Cabinet - reset db after this scenario

        Given I enter to app
        Then I select "Me" tab
        Then I wait to see "My profile"
        Then I wait see and press "My profile"
        Then I wait see and press "Passports/Visas"
        Then I wait see and press "until: 2030-02-02"
        Then I see navigation bar titled "Visa - single-entry"
        Then I scroll down to find "Delete visa"
        Then I wait
        Then I wait see and press "Delete visa"
        Then I check segment "Passports/Visas" is selected
        Then I wait to not see "until: 2030-02-02"
