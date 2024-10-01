@cabinet @loyalty_cards
Feature: Cabinet : My cards : Loyalty cards


    @reset @reset_db_after_scenario
    Scenario: Test Loyalty Cards in Cabinet

        Given I enter to app
        Then I select "Me" tab
        Then I wait to see "My cards"

        Then I wait see and press "My cards"
        Then I see navigation bar titled "My cards"
        Then I check My cards buttons state
            | PAYMENT CARDS | selected   |
            | LOYALTY CARDS | unselected |
        Then I wait see and press "LOYALTY CARDS"
        Then I check My cards buttons state
            | PAYMENT CARDS | unselected |
            | LOYALTY CARDS | selected   |

        Then I wait see and press "Add"
        Then I wait to see "My cards"
        Then I see navigation bar titled "Cards"
        Then I scroll down to find "Starwood"
        Then I scroll up to find "Aeroflot bonus"
        Then I press back
        Then I wait see and press "My cards"
        Then I check My cards buttons state
            | PAYMENT CARDS | unselected |
            | LOYALTY CARDS | selected   |

        Then I wait see and press "Add"
        Then I see navigation bar titled "Cards"
        Then I wait see and press "DELTA"
        Then I see navigation bar titled "Bonus card"
        Then I compare screen image with golden
        Then I press back

        Then I see navigation bar titled "Cards"
        Then I wait see and press "GINZA"
        # Card number
        Then I press text field number 2
        Then I check keyboard is open
        Then I enter text "999"
        Then I should see "999"
        Then I check navigation bar button "Done" is active
        Then I wait see and press "Cancel"

        Then I see navigation bar titled "Cards"
        Then I wait see and press "GINZA"
        Then I see navigation bar titled "Bonus card"
        Then I check bonus card type is "GINZA"
        Then I click on bonus card type "GINZA"

        Then I pick a "Lufthansa" from list
        Then I pick a "DELTA" from list
        Then I wait see and press "Cancel"

        Then I check bonus card type is "GINZA"
        Then I click on bonus card type "GINZA"
        Then I pick a "Intercontinental" from list
        Then I wait see and press "Select"
        # Card number
        Then I press text field number 2
        Then I check keyboard is open
        Then I enter text "999"
        Then I should see "999"
        Then I check navigation bar button "Done" is active
        # Issue date
        Then I press text field number 3
        Then I change the date picker date to "2015-01-19"
        Then I wait see and press "Cancel"
        Then I should not see "2015-01-19"
        # Issue date
        Then I press text field number 3
        Then I change the date picker date to "2015-01-19"
        Then I wait see and press "Select"
        Then I should see "2015-01-19"
        # Expiration date
        Then I press text field number 4
        Then I change the date picker date to "2021-01-30"
        Then I wait see and press "Cancel"
        Then I should not see "2021-01-30"
        # Expiration date
        Then I press text field number 4
        Then I change the date picker date to "2021-01-30"
        Then I wait see and press "Select"
        Then I should see "2021-01-30"

        Then I press note field in bonus card
        Then I check keyboard is open
        Then I enter text "note"
        Then I should see "note"
        Then I check navigation bar button "Done" is active

        Then I press "Done"
        Then I wait
        Then I scroll down
        Then I press loyalty card "999" of "Intercontinental" type
        Then I click card info icon
        Then I see navigation bar titled "Bonus card"
        Then I compare screen image with golden
        Then I press back

        Then I click card info icon

        Then I click on bonus card type "Intercontinental"

        Then I pick a "DELTA" from list
        Then I pick a "Maison Dellos" from list
        Then I wait see and press "Cancel"

        Then I click on bonus card type "Intercontinental"

        Then I pick a "MERCURY" from list
        Then I press "Select"
        Then I check navigation bar button "Done" is active

        Then I press text field number 2
        Then I check keyboard is open
        Then I enter text "1"
        Then I should see "9991"
        Then I press "Cancel"

        Then I check My cards buttons state
            | PAYMENT CARDS | unselected |
            | LOYALTY CARDS | selected   |

        Then I wait see and press "card info"
        # Card number
        Then I press text field number 2
        Then I check keyboard is open
        Then I enter text "1"
        Then I should see "9991"

        # Issue date
        Then I press text field number 3
        Then I change the date picker date to "2015-01-30"
        Then I wait see and press "Select"
        Then I should see "2015-01-30"

        # Expiration date
        Then I press text field number 4
        Then I change the date picker date to "2021-01-26"
        Then I press "Select"
        Then I should see "2021-01-26"

        # Note
        Then I press note field in bonus card
        Then I check keyboard is open
        Then I enter text "_test"
        Then I should see "note_test"

        Then I press "Done"
        Then I scroll down
        Then I scroll down
        Then I press loyalty card "9991" of "Intercontinental" type
        Then I scroll down
        Then I click card info icon
        Then I wait see and press "Delete"
        Then I wait to not see "9991"
