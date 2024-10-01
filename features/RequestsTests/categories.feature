@requests @categories
Feature: Requests : Categories


    @reset
    Scenario: Check Menu of categories in Requests tab

        Given I enter to app
        Then I select "Requests" tab
        Then I press the "menu" button
        Then I compare screen image with golden

        Then I check screen title is "Request Types"
        Then I wait to see "Back" navigation button

        Then I check Category item:
            | icon  | restaurant_and_clubs |
            | name  | Restaurants          |
            | count | 14                   |

        Then I check Category item:
            | icon  | vip-lounge            |
            | name  | Vip lounge&fast track |
            | count | 12                    |

        Then I check Category item:
            | icon  | task_avia |
            | name  | Avia      |
            | count | 7         |

        Then I check Category item:
            | icon  | car      |
            | name  | Transfer |
            | count | 6        |

        Then I check Category item:
            | icon  | tickets |
            | name  | Tickets |
            | count | 5       |

        Then I press "Restaurants"
        Then I check screen title is "Restaurants"
        Then I check all requests type is Restaurant
        Then I check a request of type Restaurant:
            | name   | Special name test                                                                      |
            | detail | completed:false, reserved:true Москва, Новинский бул., д. 31, ТДЦ "Новинский", 2 этаж. |
        Then I press back

        Then I wait see and press "Avia"
        Then I check screen title is "Avia"
        Then I check all requests type is Avia
        Then I check a request of type Avia:
            | name   | In Progress with payment        |
            | detail | completed:false, reserved:false |
        Then I press back

        Then I wait see and press "Transfer"
        Then I check screen title is "Transfer"
        Then I check all requests type is Transfer
        Then I check a request of type Transfer:
            | name   | Long description                                                                                                               |
            | detail | completed:true, reserved:false Из аэропорта, 01.09.2015 11:11, Домодево, Новослободская, 21.06.2015 22:22, 21.06.2015 23:23, 2 |
        Then I press back


    Scenario: Check All categories...

        # FIXME(PRIM-676): The categories list order varies in Requests / Categories screen.
        # Then I compare screen image with golden
        Given I enter to app
        Then I validate tab bar buttons
        Then I select "Requests" tab
        Then I press the "menu" button
        Then I wait
        Then I should not see "Car rental"
        Then I should not see "Hotel"
        Then I should not see "Flowers"
        Then I should not see "Helicopter"
        Then I press "All categories..."

        Then I check Category item:
            | icon  | car        |
            | name  | Car rental |
            | count | 3          |

        Then I check Category item:
            | icon  | task_hotel |
            | name  | Hotel      |
            | count | 3          |

        Then I check Category item:
            | icon  | task_avia  |
            | name  | Helicopter |
            | count | 2          |

        Then I check Category item:
            | icon  | flowers_icon |
            | name  | Flowers      |
            | count | 2            |

        Then I scroll down to find "Avia"
        Then I wait see and press "Avia"
        Then I wait
        Then I compare screen image with golden
        Then I press back
        Then I wait

        Then I wait see and press "Hotel"
        Then I compare screen image with golden
        Then I wait see and press "Completed and Reserved"
        Then I wait
        Then I touch chat button in "Completed and Reserved" screen
        Then I hide the keyboard
        Then I compare image in "Completed and Reserved" chat screen

        Then I check "send message" button is hidden
        Then I touch "Type message" to open keyboard
        Then I wait for keyboard

        Then I enter "Some text" into chat field
        Then I check "send message" button is shown
        Then I clear text in textField of "Completed and Reserved" chat screen
        Then I wait
        Then I check "send message" button is hidden

        Then I enter "Some text" into chat field
        Then I send chat message
        Then I check "send message" button is hidden
        Then I check last message in chat
        Then I enter "Новое сообщение" into chat field
        Then I check "send message" button is shown
        Then I send chat message
        Then I check "send message" button is hidden
        Then I check last message in chat
