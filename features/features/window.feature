@window
Feature: Window interaction
    As a tester
    In order to do my job
    I want to be able to interact with windows

    Scenario: get a reference to a window
    Given I ensure that there are no instances of the test app running
    And I start the test app from scratch
    When I try to get a reference to the main window
    Then I have a reference to a window

    Scenario: get window by string
    Given I ensure that there are no instances of the test app running
    And I start the test app from scratch
    When I look for the window by string
    Then I have a reference to a window

    Scenario: get window by regex
    Given I ensure that there are no instances of the test app running
    And I start the test app from scratch
    When I look for the window by regex
    Then I have a reference to a window

    Scenario: number of open windows
    Given I ensure that there are no instances of the test app running
    And I start the test app from scratch
    When I try to get a reference to the main window
    Then the number of windows belonging to the app is 1

    Scenario: non existent windows
    Given I start the test app
    Then I cannot get a reference to a nonexistent window