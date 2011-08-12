Feature: The scaffolder-validate binary
  In order to test inserts are being correctly added to a scaffold
  A user can use the scaffolder binary with the argument validate
  to test that inserts are correctly inserted

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
    When I call "scaffolder" with arguments "validate scaffold.yml sequence.fna"
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
    When I call "scaffolder" with arguments "validate scaffold.yml sequence.fna"
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
    When I call "scaffolder" with arguments "validate scaffold.yml sequence.fna"
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
    When I call "scaffolder" with arguments "validate scaffold.yml sequence.fna"
    Then the exit status should be 0
    And the stdout should contain exactly:
    """
    ---
    - sequence-insert-overlap:
        source: seq
        inserts:
        - open: 2
          close: 4
          source: ins1
        - open: 3
          close: 5
          source: ins2

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
    When I call "scaffolder" with arguments "validate scaffold.yml sequence.fna"
    Then the exit status should be 0
    And the stdout should contain exactly:
    """
    ---
    - sequence-insert-overlap:
        source: seq
        inserts:
        - open: 2
          close: 4
          source: ins1
        - open: 3
          close: 5
          source: ins2
    - sequence-insert-overlap:
        source: seq
        inserts:
        - open: 6
          close: 8
          source: ins1
        - open: 7
          close: 9
          source: ins2

    """
