@my_profile @family_partners @family_personal_data
Feature: My profile : Family partners : Family personal data : Add family email

    Description -
        The "2_edit_delete_family_email.feature" test has dependency from this feature.
        Following fields are tested in this test "email number", "email type", "comments".


    @reset
    Scenario: Add email in My profile/Family

        Given I enter to app
        Then I select "Me" tab
        Then I wait see and press "My profile"
        Then I wait see and press "Family/Partners"
        Then I wait see and press "add family"
        Then I press "Last name" text field
        Then I enter text "test_add_email"
        Then I hide the keyboard

        # Test "add email" in My profile/family
        Then I wait see and press "add email"
        Then I see navigation bar titled "E-mail"

        # FIXME(PRIM-539): Phone type list ordering is different with build in edit profile screen.
        # Then I compare screen image with golden
        Then I press "E-mail" text field
        Then I enter text "test@mail.ru"
        Then I press back
        Then I wait to not see "test@mail.ru"

        Then I wait see and press "add email"

        # Test "email" text field
        Then I press "E-mail" text field
        Then I enter text "test@mail.ru"

        #Test email type picker field
        Then I press "More Info"
        Then I pick a "Work" from list
        Then I wait see and press "Select"

        # Test "comments" text field
        Then I press "Comments" text field
        Then I enter text "comments"

        #Test save document
        Then I press Save
        Then I press Save
        Then I wait see and press "Family/Partners"
        Then I wait see and press "test_add_email"

        Then I wait see and press "test@mail.ru"
        Then I wait to see text "test@mail.ru"
        Then I wait to see text "Work"
        Then I wait to see text "comments"
