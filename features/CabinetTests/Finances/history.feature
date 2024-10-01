@cabinet @finances @history
Feature: Cabinet : Finances : History


    @reset
    Scenario: Test History in Cabinet

        Given I enter to app
        Then I select "Me" tab
        Then I wait to see "Finances"

        Then I wait see and press "Finances"
        Then I check Transaction history buttons state
            | History  | selected   |
            | Expenses | unselected |
        Then I check current date
        Then I compare image in history screen
        Then I press back

        Then I wait see and press "Finances"
        Then I wait see and press "calendar_arrow_left"
        Then I check last date

        Then I wait see and press "calendar_arrow_right"
        Then I check current date

        Then I wait see and press "calendar_arrow_right"
        Then I check current date

        Then I wait see and press "settings"
        Then I wait
        Then I compare screen image with golden
        Then I wait see and press "PRIME"
        Then I check "PRIME" is selected in settings screen
        Then I press back

        Then I check Transaction history buttons state
            | History  | selected   |
            | Expenses | unselected |
        Then I wait see and press "settings"
        Then I wait see and press "Partners"
        Then I check "Partners" is selected in settings screen
        Then I press back

        Then I check Transaction history buttons state
            | History  | selected   |
            | Expenses | unselected |
        Then I wait see and press "settings"
        Then I wait see and press "All"
        Then I check "All" is selected in settings screen
        Then I press back
        Then I check Transaction history buttons state
            | History  | selected   |
            | Expenses | unselected |