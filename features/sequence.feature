Feature: The scaffolder-sequence binary
  In order to generate a fasta sequence of a genome scaffold
  A user can use the scaffolder binary with argument sequence
  to generate a fasta sequence from a scaffold and sequence file

  Scenario: Generating fasta sequence for a simple scaffold
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
    When I call "scaffolder" with arguments "sequence scaffold.yml sequence.fna"
    Then the exit status should be 0
    And the stdout should contain "ATGGC"

  Scenario: Using the definition argument before the file arguments
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
    When I call "scaffolder" with arguments "sequence --definition='name' scaffold.yml sequence.fna"
    Then the exit status should be 0
    And the stdout should contain "ATGGC"
    And the stdout should contain ">name"

  Scenario: Using the definition argument after the file arguments
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
    When I call "scaffolder" with arguments "sequence scaffold.yml sequence.fna --definition='name'"
    Then the exit status should be 0
    And the stdout should contain "ATGGC"
    And the stdout should contain ">name"

  Scenario: Using the argument --no-sequence-hash
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
    When I call "scaffolder" with arguments "sequence --no-sequence-hash scaffold.yml sequence.fna"
    Then the exit status should be 0
    And the stdout should contain ">\nATGGC"

  Scenario: Using the arguments --no-sequence-hash and --definition
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
      When I call "scaffolder" with arguments "sequence scaffold.yml sequence.fna --no-sequence-hash --definition='name'"
    Then the exit status should be 0
    And the stdout should contain ">name \nATGGC"
