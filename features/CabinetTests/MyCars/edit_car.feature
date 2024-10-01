@cabinet @my_cars @edit_car
Feature: Cabinet : Edit car


    @reset
    Scenario: Edit car in Me/My cars

        Given I enter to app
        Then I select "Me" tab
        Then I wait see and press "My cars"
        Then I wait see and press "Porsche Panamera"
        Then I press "Porsche" text field
        Then I enter text "_test"
        Then I press back

        Then I wait to not see "Porsche_test"
        Then I wait see and press "Porsche Panamera"

        # Test Brand text field
        Then I press "Porsche" text field
        Then I enter text "_test"

        # Test Model text field
        Then I press "Panamera" text field
        Then I enter text "_test"

        # Test Registration Plate text field
        Then I press "reg_444444" text field
        Then I enter text "_test"

        # Test Color text field
        Then I press "Black" text field
        Then I enter text "_test"

        # Test VIN text field
        Then I press "vin_333333" text field
        Then I enter text "_test"

        # Test Release Year text field
        Then I press "2018" text field
        Then I enter text "_test"
        Then I press Save
        Then I wait to see "My cars"
        Then I wait see and press "Porsche_test Panamera_test, reg_444444_test"
        Then I see navigation bar titled "Porsche_test Panamera_test"
        Then I check my car fields
            | brand              |  Porsche_test      |
            | model              |  Panamera_test     |
            | registration_plate |  reg_444444_test   |
            | color              |  Black_test        |
            | vin                |  vin_333333_test   |
            | year               |  2018_test         |
