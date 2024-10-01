@chat
Feature: Chat typing


    @reset
    Scenario: Test chat typing tab content

        Given I enter to app
        Then I select "PRIME" tab

        Then I wait to see "Mariya"
        Then I wait to see "My assistant"
        Then I wait see and press "My assistant"
        Then I wait to see "Mariya.Kosheleva@primeconcept.co.uk"
        Then I wait see and press "My assistant"
        Then I wait to not see "Mariya.Kosheleva@primeconcept.co.uk"
        Then I check "send message" button is hidden

        # Test Send button
        Then I enter "A" into chat field
        Then I check "send message" button is shown
        Then I clear text in chat field
        Then I wait
        Then I check "send message" button is hidden

        # Type a text
        Then I enter "New Message" into chat field
        Then I send chat message
        Then I check "send message" button is hidden
        Then I wait
        Then I check last message in chat
