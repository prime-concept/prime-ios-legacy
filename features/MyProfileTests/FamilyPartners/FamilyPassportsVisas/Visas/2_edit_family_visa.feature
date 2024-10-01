@my_profile @family_partners @passport_visa
Feature: My profile : Family partners : Edit/Delete visa

    Description -
        This feature has dependency from "1_add_family_passport.feature" test.
        Following fields are tested in this test "last name", "first name", "middle name",
        "Date of Birth", "Place of Birth", "Citizenship", "Country", "Visa typt", "Visa Number",
        "Issuing authority", "Issue Date", "Expiration Date", "comments".


    Scenario: Edit visa family/Visas in My profile

        Given I enter to app
        Then I select "Me" tab
        Then I wait see and press "My profile"
        Then I wait see and press "Family/Partners"

        # Test edit family/passport
        Then I wait see and press "test_visa"
        Then I wait see and press "Passports/Visas"
        Then I wait see and press "until: 2025-02-02"
        Then I see navigation bar titled "Visa - multiple-entry"
        Then I scroll down to find "comments"
        Then I press "2025-02-02" text field
        Then I change the date picker date to "2025-08-08"
        Then I wait see and press "Select"
        Then I press back
        Then I wait to not see "until: 2025-08-08"

        Then I wait see and press "until: 2025-02-02"

        # Test last name text field
        Then I press "last_name" text field
        Then I enter text "_test"

        # Test first name text field
        Then I press "first_name" text field
        Then I enter text "_test"

        # Test middle name text field
        Then I press "middle_name" text field
        Then I enter text "_test"

        # Test date of birth picker field
        Then I press "2016-07-07" text field
        Then I change the date picker date to "2016-05-05"
        Then I press "Select"

        # Test place of birth text field
        Then I press "place_of_birth" text field
        Then I enter text "_test"

        # Test citizenship text field
        Then I press "citizenship" text field
        Then I enter text "_test"

        # Test country picker field
        Then I press "Romania" text field
        Then I wait see and press "Qatar"
        Then I wait see and press "Select"

        # Test Visa type picker field
        Then I press "multiple-entry" text field
        Then I wait see and press "single-entry"
        Then I wait see and press "Select"

        # Test passport number text field
        Then I press "222222" text field
        Then I enter text "_test"

        # Test issuing authority text field
        Then I press "issuing_authority" text field
        Then I enter text "_test"

        # Test issue date picker field
        Then I press "2016-02-02" text field
        Then I change the date picker date to "2016-07-07"
        Then I press "Select"

        # Test expiration date picker field
        Then I press "2025-02-02" text field
        Then I change the date picker date to "2025-09-09"
        Then I press "Select"

        # Test comments text field
        Then I press "comments" text field
        Then I enter text "_test"

        Then I press Save
        Then I press Save


    @reset_db_after_scenario
    Scenario: Delete passport family/Passports in My profile

        Given I enter to app
        Then I select "Me" tab
        Then I wait see and press "My profile"
        Then I wait see and press "Family/Partners"

        Then I wait see and press "test_visa"
        Then I wait see and press "Passports/Visas"
        Then I wait to see "Visa Qatar"
        Then I wait see and press "until: 2025-09-09"

        Then I wait to see text "last_name_test"
        Then I wait to see text "first_name_test"
        Then I wait to see text "middle_name_test"
        Then I wait to see text "2016-05-05"
        Then I wait to see text "place_of_birth_test"
        Then I scroll down to find "citizenship_test"
        Then I scroll down to find "Qatar"
        Then I scroll down to find "222222_test"
        Then I scroll down to find "issuing_authority_test"
        Then I scroll down to find "2016-07-07"
        Then I scroll down to find "comments_test"

        Then I scroll down to find "Delete visa"
        Then I wait see and press "Delete visa"
        Then I press Save
        Then I press back

        Then I wait to see "FirstName LastName"
        Then I wait see and press "My profile"
        Then I wait see and press "Family/Partners"
        Then I wait see and press "test_visa"
        Then I wait see and press "Passports/Visas"
        Then I wait to not see "222222_test"

        Then I wait see and press "Personal data"
        Then I scroll down to find "Delete contacts"
        Then I wait see and press "Delete contacts"
