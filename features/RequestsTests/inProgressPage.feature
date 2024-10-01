@requests @in_progress
Feature: Requests : In Progress


    @reset
    Scenario: Test To Pay sub-tab from Requests tab

        Given I enter to app
        Then I validate tab bar buttons
        Then I check Requests tab bar badge number is 2

        Then I select "Requests" tab
        Then I wait see and press "In progress"
        Then I check Requests navigation buttons state:
            | In progress | selected   |
            | Completed   | unselected |

        Then I check In Progress badge number is 2

        Then I check request with price:
            | icon   | task_avia                       |
            | name   | In Progress with payment        |
            | detail | completed:false, reserved:false |
            | price  | 7575 ₽                          |

        Then I check request with price:
            | icon   | task_avia                      |
            | name   | Calendar without payment          |
            | detail | completed:false, reserved:true |
            | price  | 7575 ₽                         |

        Then I check request without price:
            | icon   | task_avia                       |
            | name   | In Progress without payment     |
            | detail | completed:false, reserved:false |

        Then I wait see and press "In Progress with payment"
        Then I wait
        Then I validate "In Progress with payment" request screen from To Pay tab
        Then I press the "wechat" button
        Then I wait
        Then I enter "A" into chat field
        Then I press back
        Then I wait see and press "share"
        Then I wait see and press "Cancel"
        Then I wait for pageLoader
        Then I compare screen image with golden
        Then I press back

        Then I check request with price:
            | icon   | task_avia                       |
            | name   | In Progress with payment        |
            | detail | completed:false, reserved:false |
            | price  | 7575 ₽                          |

        Then I check request without price:
            | icon   | task_avia                       |
            | name   | In Progress without payment     |
            | detail | completed:false, reserved:false |
