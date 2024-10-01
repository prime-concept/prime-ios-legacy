@my_profile @family_partners @partner_personal_data
Feature: My profile : Family partners : Partner personal data : Add family phone

    Description -
        The "2_edit_delete_partner.feature" test has dependency from this feature.
        Following fields are tested in this test "last name", "first namke", "middle name", "date of birth", "type contact".


    @reset
    Scenario: Add partner/Personal data in My profile

        Given I enter to app
        Then I select "Me" tab
        Then I wait see and press "My profile"
        Then I wait see and press "Family/Partners"
        Then I see navigation bar titled "My profile"
        Then I check segment "Contacts" is not selected
        Then I check segment "Passports/Visas" is not selected
        Then I check segment "Family/Partners" is selected
        Then I compare screen image with golden

        # Test add partner/personal data
        Then I wait see and press "add partner"
        Then I see navigation bar titled "add contact"
        Then I check segment "Personal data" is selected
        Then I check segment "Passports/Visas" is not selected

        # FIXME(PRIM-539): Phone type list ordering is different with build in edit profile screen.
        # Then I compare screen image with golden
        Then I press "Last name" text field
        Then I enter text "last_name"
        Then I press back
        Then I wait to not see "last_name"

        # Test add partner/personal data
        Then I wait see and press "add partner"

        # Test "Last name" text field
        Then I press "Last name" text field
        Then I enter text "last_name"

        # Test "First name" text field
        Then I press "First name" text field
        Then I enter text "first_name"

        # Test "Middle name" text field
        Then I press "Middle name" text field
        Then I enter text "middle_name"

        # Test "Date of Birth" picker field
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

        # Test contact type picker field
        Then I press "More Info"
        Then I pick a "Personal" from list
        Then I press "Select"
        Then I wait to see "Personal"

        # Test save document
        Then I press Save
        Then I wait see and press "Family/Partners"
        Then I wait to see "Personal"
        Then I wait see and press "first_name last_name"
        Then I wait to see text "last_name"
        Then I wait to see text "first_name"
        Then I wait to see text "middle_name"
        Then I wait to see text "2016-02-02"
        Then I wait to see text "Personal"
