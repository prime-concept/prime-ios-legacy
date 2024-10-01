@my_profile @family_partners @family_personal_data
Feature: My profile : Family partners : Family personal data : Edit/Delete family phone

    Description -
        This feature has dependency from "1_add_family_phone.feature" test.
        Following fields are tested in this test "phone number", "phone type", "comments".


    Scenario: Edit phone in My profile/Family

        Given I enter to app
        Then I select "Me" tab
        Then I wait see and press "My profile"
        Then I wait see and press "Family/Partners"
        Then I wait see and press "test_add_phone"

        # Test edit phone number in My profile/family
        Then I wait see and press "+1 (111) 111"
        Then I press "+1 (111) 111" text field
        Then I enter text "4444"
        Then I press back
        Then I wait to not see "+1 (111) 111-4444"

        # Test edit phone number text field
        Then I wait see and press "+1 (111) 111"
        Then I press "+1 (111) 111" text field
        Then I enter text "4444"

        # Test edit phone type picker field
        Then I wait see and press "Mobile"
        Then I pick a "Personal,Work" from list
        Then I wait see and press "Cancel"
        Then I wait to not see "Personal,Work"
        Then I wait see and press "Mobile"
        Then I pick a "Personal,Work" from list
        Then I wait see and press "Select"
        Then I wait to see "Personal,Work"

        # Test edit "comments" text field
        Then I press "comments" text field
        Then I enter text "_test"
        Then I press Save
        Then I press Save
        Then I press back

        Then I wait to see "FirstName LastName"
        Then I wait see and press "My profile"
        Then I wait see and press "Family/Partners"
        Then I wait see and press "test_add_phone"
        Then I wait see and press "+1 (111) 111-4444"
        Then I wait to see text "+1 (111) 111-4444"
        Then I wait to see text "Personal,Work"
        Then I wait to see text "comments_test"


    @reset_db_after_scenario
    Scenario: Delete phone in My profile/Family

        Given I enter to app
        Then I select "Me" tab
        Then I wait see and press "My profile"
        Then I wait see and press "Family/Partners"
        Then I wait see and press "test_add_phone"
        Then I wait see and press "+1 (111) 111-4444"

        # Test delete phone number document
        Then I wait see and press "Delete phone"
        Then I press Save
        Then I wait see and press "Family/Partners"
        Then I wait see and press "test_add_phone"
        Then I wait to not see "+1 (111) 111-4444"
        Then I scroll down to find "Delete contacts"
        Then I wait see and press "Delete contacts"
