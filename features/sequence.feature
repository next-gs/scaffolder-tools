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
    And the stdout should contain exactly:
      """
      > 
      ATGGC

      """

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
    And the stdout should contain exactly:
      """
      >name
      ATGGC

      """

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
    And the stdout should contain exactly:
      """
      >name
      ATGGC

      """

  Scenario: Using the argument --with-sequence-digest
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
    When I call "scaffolder" with arguments "sequence --with-sequence-digest scaffold.yml sequence.fna"
    Then the exit status should be 0
    And the stdout should contain exactly:
      """
      > [sha1=32848c64b5bac47e23002c989a9d1bf3d21b8f92]
      ATGGC

      """

  Scenario: Using the arguments --with-sequence-digest and --definition
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
      When I call "scaffolder" with arguments "sequence scaffold.yml sequence.fna --with-sequence-digest --definition='name'"
    Then the exit status should be 0
    And the stdout should contain exactly:
      """
      >name [sha1=32848c64b5bac47e23002c989a9d1bf3d21b8f92]
      ATGGC

      """
