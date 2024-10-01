@login @welcome_tour
Feature: Login : Welcome tour


    @reset
    Scenario: Check splash screen appears at very first starts

        Given I am on start screen
        Then I wait until I don't see "Art Of Life Would Like to Send You Notifications"
        Then I wait to see "I am PRIME"
        Then I should not see "Art Of Life Would Like to Send You Notifications"


    Scenario: Check the splash screen is shown after restart,
            where the splash screen wasn't closed at first start

        Given I am on start screen
        Then I wait to see "I am PRIME"


    Scenario: Check welcome tour pages

        Given I am on start screen
        Then I wait to see "I am PRIME"
        Then I compare screen image with golden
        Then I swipe screen to right

        Then I wait to see "PRIME Traveller Magazine"
        Then I compare screen image with golden
        Then I swipe screen to left

        Then I wait to see "I am PRIME"
        Then I swipe screen to left

        Then I wait to see "Arkady"
        Then I wait to see "Novikov"
        Then I compare screen image with golden
        Then I swipe screen to left

        Then I wait to see "PRIME Travel benefits"
        Then I compare screen image with golden
        Then I swipe screen to left

        Then I wait to see "PRIME Lifestyle Benefits"
        Then I compare screen image with golden
        Then I swipe screen to left

        Then I wait to see "Ksenia"
        Then I wait to see "Sobchak"
        Then I compare screen image with golden
        Then I swipe screen to left

        Then I wait to see "Multiple payment and loyalty cards, passport and visa"
        Then I compare screen image with golden
        Then I swipe screen to left

        Then I wait to see "Polina"
        Then I wait to see "Kitsenko"
        Then I compare screen image with golden
        Then I swipe screen to left

        Then I wait to see "PRIME CityGuide"
        Then I compare screen image with golden
        Then I swipe screen to left

        Then I wait to see "PRIME CityGuide"
        Then I compare screen image with golden
        Then I swipe screen to left

        Then I wait to see "PRIME Traveller Magazine"
        Then I swipe screen to left

        Then I wait to see "I am PRIME"
