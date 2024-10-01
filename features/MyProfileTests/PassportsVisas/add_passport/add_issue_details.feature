@my_profile @passports_visas @passport
Feature: My profile : Passports Visas : Add passport : Add issue details


    @reset
    Scenario: Test Add passport details in Cabinet

        Given I enter to app
        Then I select "Me" tab
        Then I wait to see "My profile"
        Then I wait see and press "My profile"
        Then I wait see and press "Passports/Visas"

        # Test Passport Number text field
        Then I wait see and press "add passport"
        Then I scroll down to find "Passport Number"
        Then I wait
        Then I press "Passport Number" text field
        Then I check keyboard is open
        Then I enter text "666666"
        Then I hide the keyboard

        # Test Issuing authority text field
        Then I press "Issuing authority" text field
        Then I check keyboard is open
        Then I enter text "issuing_authority"
        Then I hide the keyboard

        # Test Issue date picker field
        Then I press "Issue date" text field
        Then I change the date picker date to "2017-01-01"
        Then I wait see and press "Cancel"
        Then I wait to not see "2017-01-01"
        Then I press "Issue date" text field
        Then I expect fail "could not change date on picker" after executing 'I change the date picker date to "2025-02-02"'
        Then I wait see and press "Select"
        Then I press current date in text field
        Then I change the date picker date to "2016-02-02"
        Then I wait see and press "Select"

        # Test Expiration date picker field
        Then I press "If present" text field
        Then I change the date picker date to "2025-02-02"
        Then I wait see and press "Cancel"
        Then I wait to not see "2016-01-01"
        Then I press "If present" text field
        Then I expect fail "could not change date on picker" after executing 'I change the date picker date to "2016-02-02"'
        Then I wait see and press "Select"
        Then I press current date in text field
        Then I change the date picker date to "2025-02-02"
        Then I wait see and press "Select"

        # Test comments text field
        Then I scroll down to find "Comments"
        Then I scroll down
        Then I wait
        Then I press comments field in document
        Then I check keyboard is open
        Then I enter text "comments"

        Then I press Save
        Then I wait to see "666666"

    Scenario: Test Edit passport details in Cabinet

        Given I enter to app
        Then I select "Me" tab
        Then I wait to see "My profile"
        Then I wait see and press "My profile"
        Then I wait see and press "Passports/Visas"
        Then I wait see and press "666666"
        Then I see navigation bar titled "Passport"

        # Test Issuing authority text field
        Then I scroll down to find "Comments"
        Then I wait
        Then I press "issuing_authority" text field
        Then I enter text "_test"
        Then I hide the keyboard

        # Test Issue date picker field
        Then I press "2016-02-02" text field
        Then I change the date picker date to "2016-03-03"
        Then I wait see and press "Select"

        # Test Expiration date picker field
        Then I press "2025-02-02" text field
        Then I change the date picker date to "2025-03-03"
        Then I wait see and press "Select"

        # Test comments text field
        Then I press "comments" text field
        Then I enter text "_test"
        Then I hide the keyboard

        Then I press Save
        Then I check segment "Passports/Visas" is selected

        Then I wait see and press "666666"
        Then I scroll down to find "Comments"
        Then I wait
        Then I wait to see text "issuing_authority_test"
        Then I wait to see text "2016-03-03"
        Then I wait to see text "2025-03-03"
        Then I wait to see text "comments_test"

@reset_db_after_scenario
    Scenario: Test delete passport in Cabinet - reset db after this scenario

        Given I enter to app
        Then I select "Me" tab
        Then I wait to see "My profile"
        Then I wait see and press "My profile"
        Then I wait see and press "Passports/Visas"
        Then I wait see and press "666666"

        Then I scroll down to find "Delete passport"
        Then I wait
        Then I wait see and press "Delete passport"
        Then I check segment "Passports/Visas" is selected
        Then I wait to not see "666666"
