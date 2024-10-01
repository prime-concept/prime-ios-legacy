@cabinet @finances @expenses
Feature: Cabinet : Finances : Expenses


    @reset
    Scenario: Test Expenses in Cabinet

        Given I enter to app
        Then I select "Me" tab
        Then I wait to see "Finances"

        Then I wait see and press "Finances"
        Then I check Transaction history buttons state
            | History  | selected   |
            | Expenses | unselected |
        Then I wait see and press "Expenses"
        Then I check Transaction history buttons state
            | History  | unselected |
            | Expenses | selected   |
        Then I check current date
        Then I compare image in history screen
        Then I press back

        Then I wait see and press "Finances"
        Then I wait see and press "Expenses"
        Then I wait see and press "calendar_arrow_left"
        Then I check last date

        Then I wait see and press "calendar_arrow_right"
        Then I check current date

        Then I wait see and press "calendar_arrow_right"
        Then I check current date

        Then I wait see and press "settings"
        Then I wait
        Then I compare screen image with golden
        Then I wait see and press "EUR"
        Then I check "EUR" is selected in settings screen
        Then I press back

        Then I check Transaction history buttons state
            | History  | unselected |
            | Expenses | selected   |
        Then I wait see and press "settings"
        Then I wait see and press "USD"
        Then I check "USD" is selected in settings screen
        Then I press back

        Then I check Transaction history buttons state
            | History  | unselected |
            | Expenses | selected   |
        Then I wait see and press "settings"
        Then I wait see and press "RUB"
        Then I check "RUB" is selected in settings screen
        Then I press back

        Then I check Transaction history buttons state
            | History  | unselected |
            | Expenses | selected   |
        Then I wait see and press "settings"
        Then I wait see and press "MULTY CURRENCY"
        Then I check "MULTY CURRENCY" is selected in settings screen
        Then I press back
        Then I check Transaction history buttons state
            | History  | unselected |
            | Expenses | selected   |
