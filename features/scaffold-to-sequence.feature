Feature: The scaffolder-to-sequence binary
  In order to generate a fasta sequence of a genome scaffold
  A user can use the scaffolder binary
  to generate a fasta sequence of a scaffold

  Scenario: A simple scaffold file with one sequence
    Given the scaffold is composed of the sequences:
      | name | nucleotides |
      | seq  | ATGCC       |
    When running "scaffold2sequence"
    Then it should not produce an error
    And it should generate the fasta sequence "ATGCC"
