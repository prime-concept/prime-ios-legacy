@cabinet @club_rules
Feature: Cabinet : Club rules


    @reset
    Scenario: Test Club rules in Cabinet

        Given I enter to app
        Then I select "Me" tab
        Then I wait to see "Club rules"

        Then I wait see and press "Club rules"
        Then I see navigation bar titled "Club rules"
        Then I wait
        Then I compare screen image with golden
        Then I should see "ПРАВИЛА И УСЛОВИЯ КЛУБА" in WebView

        Then I scroll up to see "ЦЕЛИ КЛУБА" in WebView
        Then I scroll up to see "1. ПРАВИЛА PRIME CLUB («КЛУБ»)" in WebView
        Then I scroll up to see "2. ЧЛЕНСКИЕ ВЗНОСЫ, ПРЕКРАЩЕНИЕ И ВОЗОБНОВЛЕНИЕ ЧЛЕНСТВА" in WebView
        Then I scroll up to see "3. ПРЕИМУЩЕСТВА ЧЛЕНСТВА" in WebView
        Then I scroll up to see "4. ВОЗМОЖНОСТИ ЧЛЕНОВ КЛУБА ПО ПРИОБРЕТЕНИЮ УСЛУГ" in WebView
        Then I scroll up to see "5. ОТВЕТСТВЕННОСТЬ" in WebView
        Then I scroll up to see "6. СОТРУДНИКИ КЛУБА" in WebView
        Then I scroll up to see "7. АВТОРСКИЕ ПРАВА" in WebView

        Then I wait see and press "Back"
        Then I wait to see "My profile"
