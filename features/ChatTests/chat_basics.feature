@chat
Feature: Chat


    @reset
    Scenario: Test chat tab content

        Given I enter to app
        Then I select "PRIME" tab
        Then I wait to see "Mariya"
        Then I wait to see "My assistant"
        Then I check "send message" button is hidden
        Then I check tab bar PRIME has no badge
