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

  Scenario: Validating a scaffold with no inserts
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

  Scenario: Validating a scaffold with two non-overlapping inserts
    Given a file named "sequence.fna" with:
      """
      >seq
      ATGGCG
      >ins1
      ATGGCG
      >ins2
      ATGGCG
      """
    Given a file named "scaffold.yml" with:
      """
      ---
        -
          sequence:
            source: "seq"
            inserts:
            -
              open: 2
              close: 3
              source: ins1
            -
              open: 4
              close: 5
              source: ins2

      """
    When I call "scaffold-validate" with arguments "scaffold.yml sequence.fna"
    Then the exit status should be 0
    And the stdout should contain exactly:
    """
    """

  Scenario: Validating a scaffold with two overlapping inserts
    Given a file named "sequence.fna" with:
      """
      >seq
      ATGGCG
      >ins1
      ATGGCG
      >ins2
      ATGGCG
      """
    Given a file named "scaffold.yml" with:
      """
      ---
        -
          sequence:
            source: "seq"
            inserts:
            -
              open: 2
              close: 4
              source: ins1
            -
              open: 3
              close: 5
              source: ins2

      """
    When I call "scaffold-validate" with arguments "scaffold.yml sequence.fna"
    Then the exit status should be 0
    And the stdout should contain exactly:
    """
    --- 
    - sequence-insert-overlap: 
        inserts: 
        - open: 2
          close: 4
          source: ins1
        - open: 3
          close: 5
          source: ins2
        source: seq

    """

  Scenario: Validating a scaffold with two sets of overlapping inserts
    Given a file named "sequence.fna" with:
      """
      >seq
      ATGGCGGCTGA
      >ins1
      ATGGCG
      >ins2
      ATGGCG
      """
    Given a file named "scaffold.yml" with:
      """
      ---
        -
          sequence:
            source: seq
            inserts:
            -
              open: 2
              close: 4
              source: ins1
            -
              open: 3
              close: 5
              source: ins2
            -
              open: 6
              close: 8
              source: ins1
            -
              open: 7
              close: 9
              source: ins2
      """
    When I call "scaffold-validate" with arguments "scaffold.yml sequence.fna"
    Then the exit status should be 0
    And the stdout should contain exactly:
    """
    --- 
    - sequence-insert-overlap: 
        inserts: 
        - open: 2
          close: 4
          source: ins1
        - open: 3
          close: 5
          source: ins2
        source: seq
    - sequence-insert-overlap: 
        inserts: 
        - open: 6
          close: 8
          source: ins1
        - open: 7
          close: 9
          source: ins2
        source: seq

    """
