@my_profile @family_partners @family_personal_data
Feature: My profile : Family partners : Family personal data : Add family phone

    Description -
        The "2_edit_delete_family_phone.feature" test has dependency from this feature.
        Following fields are tested in this test "phone number", "phone type", "comments".


    @reset
    Scenario: Add phone in My profile/Family

        Given I enter to app
        Then I select "Me" tab
        Then I wait see and press "My profile"
        Then I wait see and press "Family/Partners"
        Then I wait see and press "add family"
        Then I press "Last name" text field
        Then I enter text "test_add_phone"
        Then I hide the keyboard

        # Test add phone in My profile/family
        Then I wait see and press "add phone"
        Then I see navigation bar titled "Phone number"

        # FIXME(PRIM-539): Phone type list ordering is different with build in edit profile screen.
        #Then I compare screen image with golden
        Then I press "Phone number" text field
        Then I enter text "1111111"
        Then I press back
        Then I wait to not see "+1 (111) 111"

        Then I wait see and press "add phone"

        # Test "phone number" text field
        Then I press "Phone number" text field
        Then I enter text "1111111"

        # Test phone type picker field
        Then I press "More Info"
        Then I pick a "Mobile" from list
        Then I wait see and press "Select"

        # Test "comments" text field
        Then I press "Comments" text field
        Then I enter text "comments"

        # Test save document
        Then I press Save
        Then I press Save
        Then I wait see and press "test_add_phone"
        Then I wait see and press "+1 (111) 111"
        Then I wait to see text "+1 (111) 111"
        Then I wait to see text "Mobile"
        Then I wait to see text "comments"
