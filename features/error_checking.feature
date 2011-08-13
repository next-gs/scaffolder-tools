Feature: Error checking command line arguments
  In order to recoginise incorrect input
  A user should be able to use the binaries with incorrect inputs
  and be given clear error messages


  Scenario: Using sequence where the sequence file specified does not exist
    Given a file named "scaffold.yml" with:
      """
      ---
        -
          sequence:
            source: "seq"
      """
    When I call "scaffolder" with arguments "sequence scaffold.yml missing_file"
    Then the exit status should be 1
    And the stderr should contain "Error. Sequence file not found:"

  Scenario: Using sequence where the sequence file doesn't contain any thing
    Given an empty file named "sequence.fna"
    Given a file named "scaffold.yml" with:
      """
      ---
        -
          sequence:
            source: "seq1"
      """
    When I call "scaffolder" with arguments "sequence scaffold.yml sequence.fna"
    Then the exit status should be 1
    And the stderr should contain "Error. Sequence file is empty"

  Scenario: Using sequence where the scaffold file specified does not exist
    Given a file named "sequence.fna" with:
      """
      >seq
      ATGGC
      """
    When I call "scaffolder" with arguments "sequence missing_file sequence.fna"
    Then the exit status should be 1
    And the stderr should contain "Error. Scaffold file not found:"

  Scenario: Using sequence where the scaffold file doesn't contain anything
    Given an empty file named "scaffold.yml"
    Given a file named "sequence.fna" with:
      """
      >seq
      ATGGC
      """
    When I call "scaffolder" with arguments "sequence scaffold.yml sequence.fna"
    Then the exit status should be 1
    And the stderr should contain "Error. Scaffold file is empty"

  Scenario: Using sequence where a scaffold sequence is missing
    Given a file named "sequence.fna" with:
      """
      >seq1
      ATGGC
      """
    Given a file named "scaffold.yml" with:
      """
      ---
        -
          sequence:
            source: "seq1"
        -
          sequence:
            source: "seq2"
      """
    When I call "scaffolder" with arguments "sequence scaffold.yml sequence.fna"
    Then the exit status should be 1
    And the stderr should contain "Error. Unknown sequence: seq2"

  Scenario: Using validate where the sequence file specified does not exist
    Given a file named "scaffold.yml" with:
      """
      ---
        -
          sequence:
            source: "seq"
      """
    When I call "scaffolder" with arguments "validate scaffold.yml missing_file"
    Then the exit status should be 1
    And the stderr should contain "Error. Sequence file not found:"

  Scenario: Using validate where the sequence file doesn't contain any thing
    Given an empty file named "sequence.fna"
    Given a file named "scaffold.yml" with:
      """
      ---
        -
          sequence:
            source: "seq1"
      """
    When I call "scaffolder" with arguments "validate scaffold.yml sequence.fna"
    Then the exit status should be 1
    And the stderr should contain "Error. Sequence file is empty"

  Scenario: Using validate where the scaffold file specified does not exist
    Given a file named "sequence.fna" with:
      """
      >seq
      ATGGC
      """
    When I call "scaffolder" with arguments "validate missing_file sequence.fna"
    Then the exit status should be 1
    And the stderr should contain "Error. Scaffold file not found:"

  Scenario: Using validate where the scaffold file doesn't contain anything
    Given an empty file named "scaffold.yml"
    Given a file named "sequence.fna" with:
      """
      >seq
      ATGGC
      """
    When I call "scaffolder" with arguments "validate scaffold.yml sequence.fna"
    Then the exit status should be 1
    And the stderr should contain "Error. Scaffold file is empty"

  Scenario: Using validate where a scaffold sequence is missing
    Given a file named "sequence.fna" with:
      """
      >seq1
      ATGGC
      """
    Given a file named "scaffold.yml" with:
      """
      ---
        -
          sequence:
            source: "seq1"
        -
          sequence:
            source: "seq2"
      """
    When I call "scaffolder" with arguments "validate scaffold.yml sequence.fna"
    Then the exit status should be 1
    And the stderr should contain "Error. Unknown sequence: seq2"
