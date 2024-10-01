@my_profile @family_partners @passport_visa
Feature: My profile : Family partners : Add visa

    Description -
        The "2_edit_delete_family_visa.feature" test has dependency from this feature.
        Following fields are tested in this test "last name", "first name", "middle name",
        "Date of Birth", "Place of Birth", "Citizenship", "Country", "Visa typt","Visa Number",
        "Issuing authority", "Issue Date", "Expiration Date", "comments".


    @reset
    Scenario: Add visa in family/Visas in My profile

        Given I enter to app
        Then I select "Me" tab
        Then I wait see and press "My profile"
        Then I wait see and press "Family/Partners"

        Then I wait see and press "add family"

        # Test last name text field
        Then I press "Last name" text field
        Then I enter text "test_visa"

        Then I wait see and press "Passports/Visas"
        Then I wait see and press "add visa"

        Then I scroll down to find "Comments"
        Then I press "If present" text field
        Then I change the date picker date to "2025-02-02"
        Then I wait see and press "Select"
        Then I press back
        Then I wait to not see "2025-02-02"

        Then I wait see and press "add visa"

        # Test last name text field
        Then I press "Last name" text field
        Then I enter text "last_name"

        # Test first name text field
        Then I press "First name" text field
        Then I enter text "first_name"

        # Test middle name text field
        Then I press "Middle name" text field
        Then I enter text "middle_name"

        # Test date of birth picker field
        Then I press "Date of Birth" text field
        Then I change the date picker date to "2016-01-01"
        Then I press "Cancel"
        Then I wait to not see "2016-01-01"
        Then I press "Date of Birth" text field
        Then I expect fail "could not change date on picker" after executing 'I change the date picker date to "2025-02-02"'
        Then I press "Select"
        Then I press current date in text field
        Then I change the date picker date to "2016-07-07"
        Then I press "Select"

        # Test place of birth text field
        Then I press "Place of Birth" text field
        Then I enter text "place_of_birth"

        # Test citizenship text field
        Then I press "Citizenship" text field
        Then I enter text "citizenship"

        # Test country picker field
        Then I press "Russia" text field
        Then I wait see and press "Cancel"
        Then I wait see and press "Russia"
        Then I wait see and press "Romania"
        Then I wait see and press "Select"
        Then I wait to see text "Romania"

        # Test Visa type picker field
        Then I press "Visa type" text field
        Then I wait see and press "Cancel"
        Then I press "Visa type" text field
        Then I wait see and press "multiple-entry"
        Then I wait see and press "Select"

        # Test visa number text field
        Then I press "Visa Number" text field
        Then I enter text "222222"

        # Test issuing authority text field
        Then I press "Issuing authority" text field
        Then I enter text "issuing_authority"

        # Test issue date picker field
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

        # Test expiration date picker field
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
        Then I press comments field in document
        Then I enter text "comments"

        Then I press Save
        Then I press Save
        Then I wait see and press "Family/Partners"
        Then I wait see and press "test_visa"
        Then I wait see and press "Passports/Visas"
        Then I wait to see "Visa Romania"
        Then I wait see and press "until: 2025-02-02"

        Then I wait to see text "last_name"
        Then I wait to see text "first_name"
        Then I wait to see text "middle_name"
        Then I wait to see text "2016-07-07"
        Then I wait to see text "place_of_birth"
        Then I scroll down to find "citizenship"
        Then I scroll down to find "Romania"
        Then I scroll down to find "multiple-entry"
        Then I scroll down to find "222222"
        Then I scroll down to find "issuing_authority"
        Then I scroll down to find "2016-06-06"
        Then I scroll down to find "comments_test"
