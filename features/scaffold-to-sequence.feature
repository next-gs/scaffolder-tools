Feature: The scaffolder-to-sequence binary
  In order to generate a fasta sequence of a genome scaffold
  A user can use the scaffolder binary
  to generate a fasta sequence of a scaffold

  Scenario: A simple scaffold file with one sequence
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
    When I call "scaffold2sequence" with arguments "scaffold.yml sequence.fna"
    Then the exit status should be 0
    And the stdout should contain "ATGGC"

  Scenario: A scaffold file with a missing sequence file
    Given a file named "scaffold.yml" with:
      """
      ---
        -
          sequence:
            source: "seq"
      """
    When I call "scaffold2sequence" with arguments "scaffold.yml missing_file"
    Then the exit status should be 1
    And the stderr should contain "Error. Sequence file not found:"

  Scenario: A sequence file with missing sequence
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
    When I call "scaffold2sequence" with arguments "scaffold.yml sequence.fna"
    Then the exit status should be 1
    And the stderr should contain "Error. Unknown sequence: seq2"

  Scenario: A scaffold file with missing sequence
    Given an empty file named "sequence.fna"
    Given a file named "scaffold.yml" with:
      """
      ---
        -
          sequence:
            source: "seq1"
      """
    When I call "scaffold2sequence" with arguments "scaffold.yml sequence.fna"
    Then the exit status should be 1
    And the stderr should contain "Error. Sequence file is empty"
