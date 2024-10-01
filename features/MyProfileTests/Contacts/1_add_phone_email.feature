@my_profile @contacts
Feature: My profile : Contacts : Add phone and email


    @reset
    Scenario: Add phone in My profile/contacts

        Given I enter to app
        Then I select "Me" tab
        Then I press "My profile"
        Then I check segment "Contacts" is selected
        Then I check segment "Passports/Visas" is not selected
        Then I check segment "Family/Partners" is not selected
        Then I wait to see "FirstName LastName"
        Then I compare screen image with golden

        Then I wait see and press "add phone"
        Then I see navigation bar titled "Phone number"

        # FIXME(PRIM-539): Phone type list ordering is different with build in edit profile screen.
        # Then I compare screen image with golden
        Then I press "Phone number" text field
        Then I enter text "555552222"
        Then I press back
        Then I wait to not see "+5 (555) 522-22"

        Then I wait see and press "add phone"
        Then I press "Phone number" text field
        Then I enter text "555552222"

        Then I press "More Info"
        Then I wait see and press "Cancel"
        Then I press "More Info"
        Then I pick a "Mobile" from list
        Then I wait see and press "Select"
        Then I press "Comments" text field
        Then I enter text "comments"
        Then I press Save
        Then I wait to see "+5 (555) 522-22"


    Scenario: Add email in My profile/contacts

        Given I enter to app
        Then I select "Me" tab
        Then I wait to see "My profile"
        Then I wait see and press "My profile"

        Then I wait see and press "add email"
        Then I see navigation bar titled "E-mail"

        # FIXME(PRIM-539): Phone type list ordering is different with build in edit profile screen.
        # Then I compare screen image with golden
        Then I press "E-mail" text field
        Then I enter text "test@mail.ru"
        Then I press back
        Then I wait to not see "test@mail.ru"

        Then I wait see and press "add email"
        Then I press "E-mail" text field
        Then I enter text "test@mail.ru"

        Then I press "More Info"
        Then I wait see and press "Cancel"
        Then I press "More Info"
        Then I pick a "Work" from list
        Then I wait see and press "Select"
        Then I press "Comments" text field
        Then I enter text "comments"
        Then I press Save
        Then I wait to see "test@mail.ru"
