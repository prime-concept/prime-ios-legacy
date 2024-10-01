@login @registration
Feature: Login : Registration


    @reset
    Scenario: Check registration process

        Given I am on start screen
        Then I wait to see "I am PRIME"
        Then I wait see and press "I am PRIME"
        Then I wait
        Then I hide the keyboard
        Then I compare screen image with golden

        Then I validate registration screen:
            | countery name | Russia            |
            | countery code | +7                |
            | phone number  | Your phone number |

        # Validate phone number
        Then I enter phone number 9
        Then I validate registration screen:
            | countery name | Russia |
            | countery code | +7     |
            | phone number  | 9      |

        Then I press backspace 1 times
        Then I validate registration screen:
            | countery name | Russia            |
            | countery code | +7                |
            | phone number  | Your phone number |

        # Validate country code
        Then I press backspace 2 times
        Then I validate registration screen:
            | countery name | Invalid country code |
            | countery code | +                    |
            | phone number  | Your phone number    |

        # Check that '+' can't be deleted
        Then I press backspace 1 times
        Then I enter "7" into input field number 1
        Then I validate registration screen:
            | countery name | Russia            |
            | countery code | +7                |
            | phone number  | Your phone number |

        # Validate city list when country is not defined
        Then I press backspace 1 times
        Then I wait see and press "Invalid country code"
        Then I check screen title is "Countries"
        Then I check "Close" button is enabled
        Then I wait to see "A" of "TableViewHeaderFooterView" type
        Then I wait to see group "Afghanistan +93" of "Label" type
        Then I wait to see group "Albania +355" of "Label" type
        Then I wait to see group "Argentina +54" of "Label" type
        Then I wait see and press "Angola"
        Then I wait
        Then I validate registration screen:
            | countery name | Angola            |
            | countery code | +244              |
            | phone number  | Your phone number |

        # Validate country name autocompletion
        Then I touch text field number 1
        Then I press backspace 3 times
        Then I enter "7" into input field number 1
        Then I validate registration screen:
            | countery name | Russia            |
            | countery code | +7                |
            | phone number  | Your phone number |

        # Validate City list
        Then I wait see and press "Russia"
        Then I check screen title is "Countries"
        Then I check "Close" button is enabled
        Then I wait to see group "Q R S" of "TableViewHeaderFooterView" type
        Then I wait to see group "Qatar +974" of "Label" type
        Then I wait to see group "Russia +7" of "Label" type
        Then I wait to see group "Rwanda +250" of "Label" type
        Then I press the "Close" button
        Then I wait
        Then I validate registration screen:
            | countery name | Russia            |
            | countery code | +7                |
            | phone number  | Your phone number |

        # Validate correct values
        Then I wait see and press "Russia"
        Then I select "Armenia" in city list
        Then I enter phone number 77661200
        Then I wait see and press "Next"

        # Check code validation page opens when phone number is correct
        Then I wait to see "+37477661200"
        Then I wait to see "We sent you code with sms"
        Then I wait to see verification field
        Then I wait to see "Back" navigation button

        # Test invalid sms code validation
        Then I wait for keyboard
        Then I hide the keyboard
        Then I compare image in verification code screen

        Then I press "Code"
        Then I enter verification code 0123
        Then I wait to see "Confirmation code is wrong. An SMS with the registration code has been sent to you."
        Then I wait to see verification field
        Then I should not see "0123"
        Then I wait

        # Check after back from code val page, the first screen is correct
        Then I press back
        Then I validate registration screen:
            | countery name | Armenia  |
            | countery code | +374     |
            | phone number  | 77661200 |

        # Go to code val page again, enter invalid code, then valid
        Then I wait see and press "Next"
        Then I wait to see verification field
        Then I enter verification code 0123
        Then I wait to see "Confirmation code is wrong. An SMS with the registration code has been sent to you."

        # Enter valid code and go to Create Password page
        Then I wait to see verification field
        Then I enter verification code 7777
        Then I hide the keyboard
        Then I compare screen image with golden

        # Validate Create Password page
        Then I wait to see "Create a password"
        Then I wait to see "Write a password which you will use to enter application Art Of Life"
        Then I should see password field
        Then I should not see "Back"
        Then I should not see "Close"

        # Test passowrd typing, pass should be full to go to next screen
        Then I press password field
        Then I enter verification code 1
        Then I wait to see "Create a password"
        Then I press backspace 2 times

        # Enter full password first time
        Then I enter verification code 1234
        Then I wait
        Then I wait to see "Repeat password"
        Then I wait to see "Back" navigation button
        Then I should see password field
        Then I should not see "Create a password"
        Then I should not see "Write a password which you will use to enter application Art Of Life"

        # Test Back button from Repeat password page
        Then I press back
        Then I wait to see "Create a password"
        Then I wait to see "Write a password which you will use to enter application Art Of Life"
        Then I should see password field
        Then I should not see "Back"
        Then I should not see "Close"

        # Enter full password second time
        Then I enter password 0000
        Then I wait to see "Repeat password"
        Then I hide the keyboard
        Then I compare screen image with golden

        # Enter matching pass to login successfully
        Then I press password field
        Then I enter password 0000

        # Validate first opened screen after login
        Then I validate tab bar buttons
