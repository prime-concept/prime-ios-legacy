@my_profile @family_partners @family_personal_data
Feature: My profile : Family partners : Family personal data : Edit/Delete family email

    Description -
        This feature has dependency from "1_add_family_email.feature" test.
        Following fields are tested in this test "email", "email type", "comments".


    Scenario: Edit email in My profile/Family

        Given I enter to app
        Then I select "Me" tab
        Then I wait see and press "My profile"
        Then I wait see and press "Family/Partners"
        Then I wait see and press "test_add_email"

        # Test edit "eamil" in My profile/family
        Then I wait see and press "test@mail.ru"
        Then I press "test@mail.ru" text field
        Then I enter text "_test"
        Then I press back
        Then I wait to not see "test@mail.ru_test"

        # Test edit "email" text field
        Then I wait see and press "test@mail.ru"
        Then I press "test@mail.ru" text field
        Then I enter text "_test"

        # Test edit email type picker field
        Then I wait see and press "Work"
        Then I pick a "Personal,work" from list
        Then I wait see and press "Cancel"
        Then I wait to not see "Personal,work"
        Then I wait see and press "Work"
        Then I pick a "Personal,work" from list
        Then I wait see and press "Select"
        Then I wait to see "Personal,work"

        # Test edit "comments" text field
        Then I press "comments" text field
        Then I enter text "_test"
        Then I press Save
        Then I press Save


    @reset_db_after_scenario
    Scenario: Delete email in My profile/Family

        Given I enter to app
        Then I select "Me" tab
        Then I wait see and press "My profile"
        Then I wait see and press "Family/Partners"
        Then I wait see and press "test_add_email"

        Then I wait see and press "test@mail.ru_test"
        Then I wait to see text "test@mail.ru_test"
        Then I wait to see text "Personal,work"
        Then I wait to see text "comments_test"

        # Test delete email document
        Then I wait see and press "Delete e-mail"
        Then I press Save
        Then I wait see and press "Family/Partners"
        Then I wait see and press "test_add_email"
        Then I wait to not see "test@mail.ru_test"
        Then I scroll down to find "Delete contacts"
        Then I wait see and press "Delete contacts"
