@my_profile @family_partners @partner_personal_data
Feature: My profile : Family partners : Partner personal data : Edit/Delete family phone

    Description -
        This feature has dependency from "1_add_partner.feature" test.
        Following fields are tested in this test "last name", "first namke", "middle name", "date of birth", "type contact".


    Scenario: Edit partner/Personal data in My profile

        Given I enter to app
        Then I select "Me" tab
        Then I wait see and press "My profile"
        Then I wait see and press "Family/Partners"

        # Test edit partner/personal data
        Then I wait see and press "first_name last_name"
        Then I press "last_name" text field
        Then I enter text "_test"
        Then I press back
        Then I wait to not see "last_name_test"

        # Test edit partner/personal data
        Then I wait see and press "first_name last_name"

        # Test "Last name" text field
        Then I press "last_name" text field
        Then I enter text "_test"

        # Test "First name" text field
        Then I press "first_name" text field
        Then I enter text "_test"

        # Test "Middle name" text field
        Then I press "middle_name" text field
        Then I enter text "_test"

        # Test "Date of Birth" picker field
        Then I press "2016-02-02" text field
        Then I change the date picker date to "2016-04-04"
        Then I press "Select"

        # Test contact type picker field
        Then I wait see and press "Personal"
        Then I pick a "Work" from list
        Then I wait see and press "Cancel"
        Then I wait to not see "Work"
        Then I wait see and press "Personal"
        Then I pick a "Work" from list
        Then I wait see and press "Select"
        Then I wait to see "Work"

        # Test save document
        Then I press Save
        Then I wait see and press "Family/Partners"
        Then I wait to see "Work"
        Then I wait see and press "first_name_test last_name_test"
        Then I wait to see text "last_name_test"
        Then I wait to see text "first_name_test"
        Then I wait to see text "middle_name_test"
        Then I wait to see text "2016-04-04"
        Then I wait to see text "Work"


    @reset_db_after_scenario
    Scenario: Delet partner/Personal data in My profile

        Given I enter to app
        Then I select "Me" tab
        Then I wait see and press "My profile"
        Then I wait see and press "Family/Partners"

        Then I wait see and press "first_name_test last_name_test"

        # Test delete document contact
        Then I scroll down to find "Delete contacts"
        Then I wait see and press "Delete contacts"

        Then I wait see and press "Family/Partners"
        Then I wait to not see "first_name_test last_name_test"
