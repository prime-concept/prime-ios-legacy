@calendar
Feature: Calendar


    @reset
    Scenario: Check Calendar in calendar tab

        Given I enter to app
        Then I validate tab bar buttons
        Then I select "Calendar" tab
        Then I check calendar is open and today has circle
        Then I check current month is opened

        Then I swipe calendar left
        Then I check next month is opened
        Then I check first day has circle

        Then I swipe calendar right
        Then I swipe calendar right
        Then I check previous month is opened
        Then I check first day has circle
        Then I press Today button on calendar
        Then I check current month is opened
        Then I check current day has circle

        Then I check the calendar is opened
        Then I close the calendar
        Then I check the calendar is closed
        Then I open the calendar
        Then I check the calendar is opened


    Scenario: Check requests in calendar

        Given I enter to app
        Then I select "Calendar" tab
        Then I close the calendar
        Then I check the calendar is closed

        Then I scroll down on screen
        Then I wait to see "June"

        Then I check request without price:
            | icon   | task_hotel                    |
            | name   | Completed and Reserved        |
            | detail | completed:true, reserved:true |

        Then I check request with price:
            | icon   | task_avia                      |
            | name   | Calendar without payment       |
            | detail | completed:false, reserved:true |
            | price  | 7575 ₽                         |

        Then I check request without price:
            | icon   | restaurant_and_clubs                                                                   |
            | name   | Special name test                                                                      |
            | detail | completed:false, reserved:true Москва, Новинский бул., д. 31, ТДЦ "Новинский", 2 этаж. |

        Then I open the calendar
        Then I check the calendar is opened
        Then I close the calendar
        Then I check the calendar is closed

        Then I scroll up on screen
        Then I check current month is opened

