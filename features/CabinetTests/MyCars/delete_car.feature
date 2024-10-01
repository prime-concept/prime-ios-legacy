@cabinet @my_cars @delete_car
Feature: Cabinet : Delete car


    @reset @reset_db_after_scenario
    Scenario: Delete car in Me/My cars

        Given I enter to app
        Then I select "Me" tab
        Then I wait see and press "My cars"
        Then I wait see and press "Mercedes E320"
        Then I press Delete car
        Then I wait see and press "My cars"
        Then I should not see "Mercedes E320"
