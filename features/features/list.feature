@list
Feature: list interaction
    As a tester
    In order to do my job
    I want to be able to interact with list boxes

    Scenario: get list box items from single select list
    Given I start the test app
    And I select the list tab
    Then the single select list box contains the expected items

    @wip
    Scenario: get list box items from multi select list
    Given I start the test app
    And I select the list tab
    Then the multi select list box contains the expected items

    Scenario: select item from single select list
    Scenario: select item from single select list then select another
    Scenario: select item from multi select list
    Scenario: select two items from multi select list
    Scenario: deselect item from multi select list
    