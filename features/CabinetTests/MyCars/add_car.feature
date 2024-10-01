@cabinet @my_cars @add_car
Feature: Cabinet : Add car


    @reset
    Scenario: Add car in Me / My cars

        Given I enter to app
        Then I select "Me" tab
        Then I wait see and press "My cars"
        Then I wait to see "Back"
        Then I see navigation bar titled "My cars"
        Then I compare screen image with golden

        Then I wait see and press "add car"
        Then I compare screen image with golden
        Then I wait to not see "Save"
        Then I press "Brand" text field
        Then I enter text "Mercedes"
        Then I press back

        Then I wait to not see "Mercedes"
        Then I wait see and press "add car"

        # Test Brand text field
        Then I press "Brand" text field
        Then I enter text "Mercedes"

        # Test Model text field
        Then I press "Model" text field
        Then I enter text "E320"

        # Test Registration Plate text field
        Then I press "Registration Plate" text field
        Then I enter text "reg_111111"

        # Test Color text field
        Then I press "Color" text field
        Then I enter text "Black"

        # Test VIN text field
        Then I press "VIN" text field
        Then I enter text "vin_222222"

        # Test Release Year text field
        Then I press "Release Year" text field
        Then I enter text "2017"
        Then I press Save


    @reset
    Scenario: Check Add car in Me/My cars

        Given I enter to app
        Then I select "Me" tab
        Then I wait see and press "My cars"
        Then I wait to see "reg_111111"
        Then I wait see and press "Mercedes E320"
        Then I see navigation bar titled "Mercedes E320"
        Then I check my car fields
            | brand              |  Mercedes     |
            | model              |  E320         |
            | registration_plate |  reg_111111   |
            | color              |  Black        |
            | vin                |  vin_222222   |
            | year               |  2017         |
