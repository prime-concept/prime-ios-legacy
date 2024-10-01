@cabinet
Feature: Cabinet


    @reset
    Scenario: Test Cabinet content

        Given I enter to app
        Then I select "Me" tab
        Then I wait to see "FirstName LastName"
        Then I wait to see "111111"
        Then I wait to see "VALID THRU"
        Then I wait to see "11/15"
        Then I wait to see "My profile"
        Then I wait to see "My cards"
        Then I wait to see "Finances"
        Then I scroll down
        Then I wait to see "Club rules"
        Then I wait to see "Change password"


    # Scenario: Test "Personal assistant" in Cabinet

        #   Given I enter password in start screen
        #   Then I validate tab bar buttons
        #   Then I wait
        #   Then I select "Me" tab
        #   Then I scroll up
        #   Then I should not see a "Edit" button
        #   Then I press "Personal assistant"
        #   Then I wait
        #   Then I wait to see "Mariya Kosheleva"
        #   Then I wait to see "Mariya.Kosheleva@primeconcept.co.uk"
        #   Then I press "Hide"
        #   Then I wait to see "Personal assistant"
        #   Then I should not see "call assistant"
        #   Then I should not see "Mariya.Kosheleva@primeconcept.co.uk"
        #   Then I should not see "Hide"

    # Scenario: Test user data details

        #   Given I enter password in start screen
        #   Then I validate tab bar buttons
        #   Then I wait
        #   Then I select "Me" tab
        #   Then I wait
        #   Then I expand profile details

        #   # Check tab bar not visible
        #   Then I should not see "Calendar"
        #   Then I should not see "Requests"
        #   Then I should not see "PRIME"
        #   Then I should not see "City Guide"
        #   Then I should not see "Me"
        #   Then I should see a "Edit" button
        #   Then I wait to see "+7 (090) 000-00-1"
        #   Then I wait
        #   Then I wait to see "мобильный, домашний"
        #   Then I wait to see "+7 (098) 765-43-21"
        #   Then I wait to see "Home"
        #   Then I wait to see "aaa@bbb.xxx"
        #   Then I wait to see "Рабочий"
        #   Then I wait to see "aaa@bbb.ccc"

    # Scenario: Test user data editing

        #   Given I enter password in start screen
        #   Then I validate tab bar buttons
        #   Then I select "Me" tab
        #   Then I wait
        #   Then I expand profile details

        #   # Edit
        #   Then I press "Edit"
        #   Then I wait for the "Cancel" button to appear
        #   Then I wait for the "Save" button to appear
        #   Then I should not see a "Edit" button
        #   Then I wait to see "FirstName LastName"
        #   Then I wait to see "111111"
        #   Then I wait to see "test.mail@mail.ru"
        #   Then I wait to see "+7 (909) 273-26-41"
        #   Then I wait to see "VALID THRU"
        #   Then I wait to see "11/15"
        #   Then I wait to see "+7 (090) 000-00-1"
        #   Then I wait to see "мобильный, домашний"
        #   Then I wait to see "+7 (098) 765-43-21"
        #   Then I wait to see "add phone"
        #   Then I wait to see "Home"
        #   Then I wait to see "aaa@bbb.xxx"
        #   Then I wait to see "Рабочий"
        #   Then I wait to see "aaa@bbb.ccc"
        #   Then I press "+7 (090) 000-00-1"
        #   Then I enter text "5"

        #   # Cancel
        #   Then I press "Cancel"
        #   Then I wait to see "+7 (090) 000-00-1"
        #   Then I wait for the "Edit" button to appear

        #   # Save
        #   Then I press "Edit"
        #   Then I press "+7 (090) 000-00-1"
        #   Then I enter text "5"
        #   Then I press Save
        #   Then I wait to see "+7 (090) 000-00-15"
        #   Then I collapse profile details
