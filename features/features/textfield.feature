@textfield
Feature: text field interaction
    As a tester
    In order to do my job
    I want to be able to interact with text fields

    Scenario: get and set value of text field
    Given I start the test app
    And I select the textfields tab
    When I enter some text into the text field
    Then the text field contains the text I entered

    Scenario: overwrite value of text field
    Given I start the test app
    And I select the textfields tab
    When I enter some text into the text field
    Then the text field contains the text I entered
    When I enter some different text into the text field
    Then the text field contains the different text

    Scenario: attempt setting value of disabled text field
    Given I start the test app
    And I select the textfields tab
    Then bewildr complains if I try to enter text into the disabled text field

    Scenario: get value of label
    Given I start the test app
    And I select the textfields tab
    Then the label text is as expected