@my_profile @passports_visas @visa
Feature: My profile : Passports Visas : Add visa : Add name


    @reset
    Scenario: Test Add visa details in Cabinet

        Given I enter to app
        Then I select "Me" tab
        Then I wait to see "My profile"
        Then I wait see and press "My profile"
        Then I wait see and press "Passports/Visas"

        # Test Last name text field
        Then I wait see and press "add visa"
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

        # Test Expiration date picker field
        Then I scroll down to find "Expiration date"
        Then I wait see and press "If present"
        Then I change the date picker date to "2025-02-02"
        Then I wait see and press "Select"

        Then I press Save
        Then I check segment "Passports/Visas" is selected
        Then I wait to see "until: 2025-02-02"
        Then I wait to see "Russia"


    Scenario: Test Edit visa details in Cabinet

        Given I enter to app
        Then I select "Me" tab
        Then I wait to see "My profile"
        Then I wait see and press "My profile"
        Then I wait see and press "Passports/Visas"
        Then I wait see and press "until: 2025-02-02"
        Then I see navigation bar titled "Visa"

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

        Then I wait see and press "until: 2025-02-02"
        Then I wait to see text "last_name_test"
        Then I wait to see text "first_name_test"
        Then I wait to see text "middle_name_test"

        # FIXME(PRIM-532): Default country is not shown in new created passport screen.
        # Update next line to 'wait to see Russia' after fix.
        Then I wait to not see "Russia"


    @reset_db_after_scenario
    Scenario: Test delete visa in Cabinet - reset db after this scenario

        Given I enter to app
        Then I select "Me" tab
        Then I wait to see "My profile"
        Then I wait see and press "My profile"
        Then I wait see and press "Passports/Visas"
        Then I wait see and press "until: 2025-02-02"
        Then I scroll down to find "Delete visa"
        Then I wait see and press "Delete visa"
        Then I check segment "Passports/Visas" is selected
        Then I wait to not see "until: 2025-02-02"
