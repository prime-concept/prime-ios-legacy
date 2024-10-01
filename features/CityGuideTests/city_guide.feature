@city_guide
Feature: City guide


    @reset
    Scenario: Check City Guide tab

        Given I enter to app
        Then I select "City Guide" tab
        Then I wait and wait and wait...
        Then I wait until page load
        Then I touch "PRIME города" in WebView
        Then I scroll up to see "© 2018,  Компания PRIME - lifestyle management" in WebView
        Then I scroll down to see "МОСКВА" in WebView

        Then I touch "МОСКВА" in WebView

        Then I press menu in WebView
        Then I validate menu in City Guide

        Then I should see "Города" in WebView
        Then I should see "Мой список" in WebView
        Then I should see "Привилегии" in WebView
        Then I should see "Сервисы" in WebView
        Then I should see "Рекомендации членов Клуба" in WebView

        Then I touch "Города" in WebView
        Then I should see "МОСКВА" in WebView
        Then I should see "САНКТ-ПЕТЕРБУРГ" in WebView
        Then I should see "ЛОНДОН" in WebView
        Then I should see "ПАРИЖ" in WebView
        Then I should see "РИМ" in WebView
        Then I should see "НЬЮ-ЙОРК" in WebView

        Then I touch "Мой список" in WebView
        Then I close City Guide menu if opened
        Then I validate city page in WebView
        Then I press menu in WebView

        Then I touch "Привилегии" in WebView
        Then I should see "Travel" in WebView
        Then I should see "Рестораны / Бары" in WebView
        Then I should see "Рестораны / Бары" in WebView
        Then I should see "Покупки" in WebView
        Then I should see "Красота / Здоровье" in WebView
        Then I should see "Спорт" in WebView

        Then I touch "Сервисы" in WebView
        Then I close City Guide menu if opened
        Then I validate city page in WebView
        Then I press menu in WebView

        Then I touch "Рекомендации членов Клуба" in WebView
        Then I validate city page in WebView
        Then I press back in WebView