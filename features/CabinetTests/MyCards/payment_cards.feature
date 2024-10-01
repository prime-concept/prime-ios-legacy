@cabinet @payment_cards
Feature: Cabinet : My cards : Payment cards
         Denay camera access for this test.


    @reset
    Scenario: Test Payment cards in Cabinet

        Given I enter to app
        Then I select "Me" tab
        Then I wait to see "My cards"
        Then I wait see and press "My cards"
        Then I compare screen image with golden
        Then I see navigation bar titled "My cards"
        Then I check My cards buttons state
            | PAYMENT CARDS | selected   |
            | LOYALTY CARDS | unselected |
        Then I press back

        Then I wait to see "My profile"
        Then I wait see and press "My cards"
        Then I wait see and press "Add"
        Then I check keyboard is open
        Then I hide the keyboard
        Then I compare screen image with golden

        Then I click card number field
        Then I enter text "5555555555554443"
        Then I hide the keyboard
        Then I compare screen image with golden

        Then I check card number is "5555 5555 5555 4443"
        Then I click card date field
        Then I press backspace 1 times
        Then I enter text "41318"
        Then I wait to not see "Expiration date of the card is entered incorrectly."
        Then I hide the keyboard
        Then I compare screen image with golden

        Then I check card date is "13/18"
        Then I click card date field
        Then I press backspace 4 times
        Then I enter text "0515"
        Then I wait to not see "Expiration date of the card is entered incorrectly."
        Then I hide the keyboard
        Then I compare screen image with golden

        Then I wait see and press "Scan the card"
        Then I press "Enter Manually" on real device
        Then I see navigation bar titled "Card"
        Then I hide the keyboard
        Then I compare screen image with golden
        Then I press "Camera" on real device
        Then I wait see and press "Cancel"

        Then I wait see and press "Scan the card"
        Then I press "Enter Manually" on real device
        Then I wait see and press "Card Number"
        Then I enter text "5555555555554443"
        Then I wait see and press "MM / YY"
        Then I enter text "0521"
        Then I wait see and press "5555 5555 5555 4443"
        Then I press backspace 1 times
        Then I enter text "4"
        Then I wait see and press "5555 5555 5555 4444"
        Then I wait see and press "05 / 21"
        Then I press backspace 1 times
        Then I enter text "4"
        Then I wait see and press "05 / 24"
        Then I press backspace 7 times
        Then I enter text "1212"
        Then I hide the keyboard
        Then I compare screen image with golden

        Then I wait see and press "5555 5555 5555 4444"
        Then I press backspace 1 times
        Then I enter text "3"
        Then I hide the keyboard
        Then I compare screen image with golden

        Then I wait see and press "5555 5555 5555 4443"
        Then I check keyboard is open
        Then I press backspace 1 times
        Then I enter text "4"
        Then I wait see and press "12 / 12"
        Then I check keyboard is open
        Then I press backspace 7 times
        Then I enter text "0521"
        Then I hide the keyboard
        Then I check navigation bar button "Done" is active
        Then I wait see and press "Done"
        Then I wait see and press "Cancel"

        Then I check My cards buttons state
            | PAYMENT CARDS | selected   |
            | LOYALTY CARDS | unselected |
        Then I wait see and press "Add"
        Then I enter text "55555555555544440521"
        Then I hide the keyboard
        Then I wait
        Then I check navigation bar button "Done" is active
        Then I wait see and press "Done"

        Then I wait
        Then I check My cards buttons state
            | PAYMENT CARDS | selected   |
            | LOYALTY CARDS | unselected |
        Then I wait see and press "Add"
        Then I enter text "55555555555577770521"
        Then I hide the keyboard
        Then I check navigation bar button "Done" is active
        Then I wait see and press "Done"

        Then I compare screen image with golden
        Then I wait see and press ".... 4444"
        Then I compare screen image with golden
        Then I check card number is "5555 **** **** 4444"
        Then I click card number field
        Then I enter text "55555555555544440521"
        Then I hide the keyboard
        Then I wait see and press "Done"
        Then I wait to not see "The payment card is already registered."

        Then I compare screen image with golden
        Then I wait see and press "Delete"
        Then I check My cards buttons state
            | PAYMENT CARDS | selected   |
            | LOYALTY CARDS | unselected |
        Then I wait to not see ".... 4444"

        Then I wait to see ".... 7777" then swipe left to find delete
        Then I wait see and press "Delete"
        Then I wait to not see ".... 7777"
