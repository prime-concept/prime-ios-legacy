@chat, @recording
Feature: Chat Voice Recording

    @reset
    Scenario: Test chat typing tab content

        Given I enter to app
        Then I select "PRIME" tab

        Then I check voice recorder button exists
        Then I enter "A" into chat field
        Then I check voice recorder button does not exist
        Then I clear text in chat field
        Then I hide the keyboard
        Then I check voice recorder button exists

        Then I long press voice recorder button
        Then I check a new recording is added

