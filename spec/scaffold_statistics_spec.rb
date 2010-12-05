require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ScaffoldStatistics do

  before(:each){ @scaffold = [] }

  def stats
    ScaffoldStatistics.new(@scaffold)
  end

  def sequence(options = {})
    methods = {:entry_type => :sequence}
    stub(methods.merge options)
  end

  def sequence_length_10_with_gap_length(n,options={})
    sequence(options.merge({:sequence => ("A" * (10 - n) + 'N' * n)}))
  end

  describe "determining the total number of inserts" do

    def sequence_with_inserts(n)
      sequence = stub(:entry_type => :sequence, :inserts => stub(:length => n))
    end

    it "should return correctly when there are no sequences" do
      stats.insert_count.should == 0
    end

    it "should return correctly when there is a sequence with no inserts" do
      @scaffold << sequence_with_inserts(0)
      stats.insert_count.should == 0
    end

    it "should return correctly when there is a sequence with a single insert" do
      @scaffold << sequence_with_inserts(1)
      stats.insert_count.should == 1
    end

    it "should return correctly when there is a sequence with multiple inserts" do
      @scaffold << sequence_with_inserts(5)
      stats.insert_count.should == 5
    end

    it "should return correctly when there are multiple sequences with inserts" do
      @scaffold << sequence_with_inserts(1) << sequence_with_inserts(1)
      stats.insert_count.should == 2
    end

  end

  describe "determining the total base pair of gaps in a scaffold" do

    it "should return 0 when there are no sequences" do
      stats.gap_base_pair.should == 0
    end

    it "should return 0 when there is a sequence with no gaps" do
      @scaffold << sequence_length_10_with_gap_length(0)
      stats.gap_base_pair.should == 0
    end

    it "should return correctly when there is a sequence with a single gap" do
      @scaffold << sequence_length_10_with_gap_length(1)
      stats.gap_base_pair.should == 1
    end

    it "should return correctly when there is a sequence with a multiple gaps" do
      @scaffold << sequence_length_10_with_gap_length(3)
      stats.gap_base_pair.should == 3
    end

    it "should return correctly when there are multiples sequences with gaps" do
      @scaffold << sequence_length_10_with_gap_length(3)
      @scaffold << sequence_length_10_with_gap_length(2)
      stats.gap_base_pair.should == 5
    end

  end

  describe "determining the percentage base pair of gaps in a scaffold" do

    it "should return nil when there are no sequences" do
      stats.gap_percent.should == nil
    end

    it "should return 0 when there is a sequence with no gaps" do
      @scaffold << sequence_length_10_with_gap_length(0)
      stats.gap_percent.should == 0
    end

    it "should return correctly when there is a sequence with 1 gap" do
      @scaffold << sequence_length_10_with_gap_length(1)
      stats.gap_percent.should == 10.0
    end

    it "should return correctly when there are multiple sequence with gaps" do
      @scaffold << sequence_length_10_with_gap_length(1)
      @scaffold << sequence_length_10_with_gap_length(2)
      stats.gap_percent.should == 15.0
    end

  end

  describe "determining the number of gaps in the scaffold" do

    it "should return nil when there are no sequences" do
      stats.gap_count.should == 0
    end

    it "should return 0 when there is a sequence with no gaps" do
      @scaffold << sequence_length_10_with_gap_length(0)
      stats.gap_count.should == 0
    end

    it "should return 1 when there is a sequence with a gap" do
      @scaffold << sequence_length_10_with_gap_length(1)
      stats.gap_count.should == 1
    end

    it "should return 2 when there are two sequences with gaps" do
      @scaffold << sequence_length_10_with_gap_length(1)
      @scaffold << sequence_length_10_with_gap_length(2)
      stats.gap_count.should == 2
    end

    it "should return when there are multiple sequences with and without gaps" do
      @scaffold << sequence_length_10_with_gap_length(0)
      @scaffold << sequence_length_10_with_gap_length(1)
      @scaffold << sequence_length_10_with_gap_length(2)
      stats.gap_count.should == 2
    end
  end

  describe "determining the number of times each sequence is used" do

    it "should return an empty hash when there are no sequences" do
      stats.sequence_count.should == {}
    end

    it "should return one when there is one sequence" do
      @scaffold << sequence(:name => 'seq1')
      stats.sequence_count.should == {'seq1' => 1}
    end

    it "should return two when there are two sequences" do
      @scaffold << sequence(:name => 'seq1')
      @scaffold << sequence(:name => 'seq1')
      stats.sequence_count.should == {'seq1' => 2}
    end

    it "should return two when there are two sequences" do
      @scaffold << sequence(:name => 'seq1')
      @scaffold << sequence(:name => 'seq2')
      stats.sequence_count.should == {'seq1' => 1, 'seq2' => 1}
    end

  end

  describe "determining the range of sequence sizes" do

    it "should return nil when there are no sequences" do
      stats.sequence_sizes[:smallest].should == nil
      stats.sequence_sizes[:largest].should == nil
    end

    it "should return be both the smallest and largest when these is one" do
      @scaffold << sequence(:sequence => 'A' * 5)
      stats.sequence_sizes[:smallest].should == 5
      stats.sequence_sizes[:largest].should == 5
    end

    it "should return sizes for smallest and largest" do
      @scaffold << sequence(:sequence => 'A' * 5)
      @scaffold << sequence(:sequence => 'A' * 10)
      stats.sequence_sizes[:smallest].should == 5
      stats.sequence_sizes[:largest].should == 10
    end

  end

  describe "determining the GC content of the sequence" do

    it "should return a float" do
      @scaffold << sequence(:sequence => 'GGGGA')
      stats.gc_content.class.should == Float
    end

    it "should return 0 when there is no sequence" do
      stats.gc_content.should == 0
    end

    it "should return GC content when there is one sequence" do
      @scaffold << sequence(:sequence => 'GGGGA')
      stats.gc_content.should == 0.8
    end

    it "should return GC content when there are two sequences" do
      @scaffold << sequence(:sequence => 'GGGGA')
      @scaffold << sequence(:sequence => 'GGGAA')
      stats.gc_content.should == 0.7
    end
  end

  describe "determining the length of the scaffold sequence" do

    it "should return 0 when there is no sequence" do
      stats.sequence_length.should == 0
    end

    it "should return correctly when there is one sequence" do
      @scaffold << sequence(:sequence => 'A' * 5)
      stats.sequence_length.should == 5
    end

    it "should return correctly when there are multiple sequences" do
      @scaffold << sequence(:sequence => 'A' * 5)
      @scaffold << sequence(:sequence => 'A' * 10)
      stats.sequence_length.should == 15
    end

  end
end
