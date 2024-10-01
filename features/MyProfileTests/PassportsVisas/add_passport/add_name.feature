@my_profile @passports_visas @passport
Feature: My profile : Passports Visas : Add passport : Add name


    @reset
    Scenario: Test Add passport details in Cabinet

        Given I enter to app
        Then I select "Me" tab
        Then I wait to see "My profile"
        Then I wait see and press "My profile"
        Then I wait see and press "Passports/Visas"

        # Test Last name text field
        Then I wait see and press "add passport"
        Then I press "Last name" text field
        Then I check keyboard is open
        Then I enter text "last_name"

        # Test First name text field
        Then I press "First name" text field
        Then I check keyboard is open
        Then I enter text "first_name"

        # Test Middle name text field
        Then I press "Middle name" text field
        Then I check keyboard is open
        Then I enter text "middle_name"
        Then I hide the keyboard

        # Test Passport Number text field
        Then I press "Passport Number" text field
        Then I check keyboard is open
        Then I enter text "555555"

        Then I press Save
        Then I check segment "Passports/Visas" is selected
        Then I wait to see "555555"
        Then I wait to see "Russia"


    Scenario: Test Edit passport details in Cabinet

        Given I enter to app
        Then I select "Me" tab
        Then I wait to see "My profile"
        Then I wait see and press "My profile"
        Then I wait see and press "Passports/Visas"
        Then I wait see and press "555555"
        Then I see navigation bar titled "Passport"

        # Test Last name text field
        Then I press "last_name" text field
        Then I enter text "_test"
        Then I hide the keyboard

        # Test First name text field
        Then I press "first_name" text field
        Then I enter text "_test"
        Then I hide the keyboard

        # Test Middle name text field
        Then I press "middle_name" text field
        Then I enter text "_test"

        Then I press Save
        Then I check segment "Passports/Visas" is selected
        Then I wait to see "Russia"

        Then I wait see and press "555555"
        Then I wait to see text "last_name_test"
        Then I wait to see text "first_name_test"
        Then I wait to see text "middle_name_test"

        # FIXME(PRIM-532): Default country is not shown in new created passport screen.
        # Update next line to 'wait to see Russia' after fix.
        Then I wait to not see "Russia"

@reset_db_after_scenario
    Scenario: Test delete passport in Cabinet - reset db after this scenario

        Given I enter password in start screen
        Then I validate tab bar buttons
        Then I wait
        Then I select "Me" tab
        Then I wait to see "My profile"
        Then I wait see and press "My profile"
        Then I wait see and press "Passports/Visas"
        Then I wait see and press "555555"
        Then I scroll down to find "Delete passport"
        Then I wait see and press "Delete passport"
        Then I check segment "Passports/Visas" is selected
        Then I wait to not see "555555"
