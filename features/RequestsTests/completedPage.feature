@requests @completed
Feature: Requests : Completed


    @reset
    Scenario: Test Completed sub-tab in Requests page

        Given I enter to app
        Then I validate tab bar buttons
        Then I select "Requests" tab
        Then I wait see and press "Completed"
        Then I check Requests navigation buttons state:
            | In progress | unselected |
            | Completed   | selected   |

        Then I check request without price:
            | icon   | flowers_icon                   |
            | name   | Completed with payment         |
            | detail | completed:true, reserved:false |

        Then I check request without price:
            | icon   | task_avia                      |
            | name   | Completed without payment      |
            | detail | completed:true, reserved:false |

        Then I check request without price:
            | icon   | task_hotel                    |
            | name   | Completed and Reserved        |
            | detail | completed:true, reserved:true |

        Then I wait see and press "Completed without payment"
        Then I wait
        Then I validate "Completed without payment" request screen from To Pay tab
        Then I press the "wechat" button
        Then I wait
        Then I enter "A" into chat field
        Then I press back
        Then I wait see and press "share"
        Then I wait
        Then I wait see and press "Cancel"
        Then I wait for pageLoader
        Then I compare screen image with golden
        Then I press back

        Then I check request without price:
            | icon   | flowers_icon                   |
            | name   | Completed with payment         |
            | detail | completed:true, reserved:false |

        Then I check request without price:
            | icon   | task_avia                      |
            | name   | Completed without payment      |
            | detail | completed:true, reserved:false |

        Then I check request without price:
            | icon   | task_hotel                    |
            | name   | Completed and Reserved        |
            | detail | completed:true, reserved:true |
