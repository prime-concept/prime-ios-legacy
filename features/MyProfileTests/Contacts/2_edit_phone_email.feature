@my_profile @contacts
Feature: My profile : Contacts : Edit/Delete phone and email

    This test has data dependancy from the "add_phone_email" test


    @reset
    Scenario: Edit phone in My profile/contacts

        Given I enter to app
        Then I select "Me" tab
        Then I wait see and press "My profile"

        Then I wait see and press "+5 (555) 522-22"
        Then I press "+5 (555) 522-22" text field
        Then I enter text "888"
        Then I press back
        Then I wait to not see "+5 (555) 522-22-88-8"

        Then I wait see and press "+5 (555) 522-22"
        Then I press "+5 (555) 522-22" text field
        Then I enter text "888"
        Then I press "More Info"
        Then I pick a "Personal,Home" from list
        Then I wait see and press "Select"
        Then I press "comments" text field
        Then I enter text "_test"
        Then I press "Save"
        Then I wait to see "+5 (555) 522-22-88-8"


    Scenario: Edit email in My profile/contacts

        Given I enter to app
        Then I select "Me" tab
        Then I wait see and press "My profile"

        Then I wait see and press "test@mail.ru"
        Then I press "test@mail.ru" text field
        Then I enter text "_test"
        Then I press back
        Then I wait to not see "test@mail.ru_test"

        Then I wait see and press "test@mail.ru"
        Then I press "test@mail.ru" text field
        Then I enter text "_test"

        Then I press "More Info"
        Then I pick a "Personal,work" from list
        Then I wait see and press "Select"
        Then I press "comments" text field
        Then I enter text "_test"
        Then I press "Save"
        Then I wait to see "test@mail.ru_test"


    @reset_db_after_scenario
    Scenario: Delete phone and email in My profile/contacts

        Given I enter to app
        Then I select "Me" tab
        Then I wait see and press "My profile"
        Then I wait see and press "+5 (555) 522-22-88-8"
        Then I wait see and press "Delete phone"

        Then I wait see and press "test@mail.ru_test"
        Then I wait see and press "Delete e-mail"

        Then I press back
        Then I wait
        Then I wait
        Then I wait to see "FirstName LastName"
        Then I wait see and press "My profile"

        Then I wait to not see "+5 (555) 522-22-88-8"
        Then I wait to not see "test@mail.ru_test"
