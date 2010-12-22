Feature: Command line documentation for scaffolder
  In order to understand how a tools works
  A user can use scaffolder at the command line
  to review its documentation

  Scenario: Running scaffolder without any arguments
    When I call "scaffolder" with arguments ""
    Then the exit status should be 0
    And the stdout should contain exactly:
    """
    usage: scaffolder [--version] [--help] COMMAND scaffold-file sequence-file
    [options]

    Commands:
       sequence   Generate the fasta output for the scaffold
       validate   Validate scaffold for overlapping inserts
    """

  Scenario: Running scaffolder the help argument
    When I call "scaffolder" with arguments "--help"
    Then the exit status should be 0
    And the stdout should contain exactly:
    """
    usage: scaffolder [--version] [--help] COMMAND scaffold-file sequence-file
    [options]

    Commands:
       sequence   Generate the fasta output for the scaffold
       validate   Validate scaffold for overlapping inserts
    """

  Scenario: Running scaffolder with the version argument
    When I call "scaffolder" with arguments "--version"
    Then the exit status should be 0
    And the stdout should contain exactly:
    """
    scaffolder version 0.1.0
    """

  Scenario: Running scaffolder with an incorrect command
    When I call "scaffolder" with arguments "non-existant-command"
    Then the exit status should be 1
    And the stdout should contain exactly:
    """
    Error: 'non-existant-command' is not a scaffolder command.
    See 'scaffolder --help'.

    """
