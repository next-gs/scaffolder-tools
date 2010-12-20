Feature: The scaffold-validate binary
  In order to test inserts are being correctly added to a scaffold
  A user can use the scaffolder binary
  to test that inserts are correctly inserted

  Scenario: The sequence file specified does not exist
    Given a file named "scaffold.yml" with:
      """
      ---
        -
          sequence:
            source: "seq"
      """
    When I call "scaffold-validate" with arguments "scaffold.yml missing_file"
    Then the exit status should be 1
    And the stderr should contain "Error. Sequence file not found:"

  Scenario: The sequence file doesn't contain any thing
    Given an empty file named "sequence.fna"
    Given a file named "scaffold.yml" with:
      """
      ---
        -
          sequence:
            source: "seq1"
      """
    When I call "scaffold-validate" with arguments "scaffold.yml sequence.fna"
    Then the exit status should be 1
    And the stderr should contain "Error. Sequence file is empty"

  Scenario: The scaffold file specified does not exist
    Given a file named "sequence.fna" with:
      """
      >seq
      ATGGC
      """
    When I call "scaffold-validate" with arguments "missing_file sequence.fna"
    Then the exit status should be 1
    And the stderr should contain "Error. Scaffold file not found:"

  Scenario: The scaffold file doesn't contain anything
    Given an empty file named "scaffold.yml"
    Given a file named "sequence.fna" with:
      """
      >seq
      ATGGC
      """
    When I call "scaffold-validate" with arguments "scaffold.yml sequence.fna"
    Then the exit status should be 1
    And the stderr should contain "Error. Scaffold file is empty"

  Scenario: One of the sequences specified in the scaffold is missing
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
    When I call "scaffold-validate" with arguments "scaffold.yml sequence.fna"
    Then the exit status should be 1
    And the stderr should contain "Error. Unknown sequence: seq2"

  Scenario: Validating a scaffold with no overlapping inserts
    Given a file named "sequence.fna" with:
      """
      >seq
      ATGGC
      """
    Given a file named "scaffold.yml" with:
      """
      ---
        -
          sequence:
            source: "seq"
      """
    When I call "scaffold-validate" with arguments "scaffold.yml sequence.fna"
    Then the exit status should be 0
    And the stdout should contain exactly:
    """
    """
