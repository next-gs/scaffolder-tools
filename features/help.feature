Feature: Command line help for scaffolder
  In order to understand how the scaffolder tools work
  A user can use scaffolder help at the command line
  to review its documentation

  Scenario: Running scaffolder without any arguments
    When I call "scaffolder" with arguments ""
    Then the exit status should be 0
    And the stdout should contain exactly:
    """
    usage: scaffolder [--version] COMMAND scaffold-file sequence-file
    [options]

    Commands:
      help        Help information for scaffolder commands
      sequence    Generate the fasta output for the scaffold
      validate    Validate scaffold for overlapping inserts

    """

  Scenario: Running scaffolder with the version argument
    When I call "scaffolder" with arguments "--version"
    Then the exit status should be 0
    And the output should match:
    """
    scaffolder tool version \d.\d.\d

    """

  Scenario: Running scaffolder with an incorrect command
    When I call "scaffolder" with arguments "unknown-command"
    Then the exit status should be 1
    And the stderr should contain exactly:
    """
    Error. Unknown command 'unknown-command'.
    See 'scaffolder help'.

    """

  Scenario: Running scaffolder with just the help argument
    When I call "scaffolder" with arguments "help"
    Then the exit status should be 0
    And the stdout should contain exactly:
    """
    usage: scaffolder [--version] COMMAND scaffold-file sequence-file
    [options]

    Commands:
      help        Help information for scaffolder commands
      sequence    Generate the fasta output for the scaffold
      validate    Validate scaffold for overlapping inserts
      format      Show the options for writing the scaffold file

    """

  Scenario: Fetching the man page for sequence
    When I call "scaffolder" with arguments "help sequence"
    Then the exit status should be 0
    And the stdout should contain "SCAFFOLDER-SEQUENCE(1)"

  Scenario: Fetching the man page for validate
    When I call "scaffolder" with arguments "help validate"
    Then the exit status should be 0
    And the stdout should contain "SCAFFOLDER-VALIDATE(1)"

  Scenario: Fetching the man page for help
    When I call "scaffolder" with arguments "help help"
    Then the exit status should be 0
    And the stdout should contain "SCAFFOLDER-HELP(1)"

  Scenario: Fetching the man page for help
    When I call "scaffolder" with arguments "help format"
    Then the exit status should be 0
    And the stdout should contain "SCAFFOLDER-FORMAT(7)"

  Scenario: Fetching the man page for an incorrect command
    When I call "scaffolder" with arguments "help unknown-command"
    Then the exit status should be 1
    And the stderr should contain exactly:
    """
    Error. Unknown command 'unknown-command'.
    See 'scaffolder help'.

    """

