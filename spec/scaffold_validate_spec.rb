require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

context ScaffoldValidate do

  context "comparing inserts for overlaps using inserts_overlap?" do

    before(:all) do
      @insert = stub(:position => 5..10)
    end

    it "should be false when inserts don't overlap" do
      no_overlap = stub(:position => 11..12)
      ScaffoldValidate.inserts_overlap?(@insert,no_overlap).should be_false
      ScaffoldValidate.inserts_overlap?(no_overlap,@insert).should be_false
    end

    it "should be true when inserts do overlap" do
      overlap = stub(:position => 10..11)
      ScaffoldValidate.inserts_overlap?(@insert,overlap).should be_true
      ScaffoldValidate.inserts_overlap?(overlap,@insert).should be_true
    end

  end

  context "testing a sequence for insert overlaps using sequence_errors" do

    before(:all) do
      # User integers for mocks because they can be sorted
      @a = 1; @b = 2
      @sequence = stub(:inserts => [@a,@b])
    end

    it "should return an empty array when sequence has no errors" do
      ScaffoldValidate.stubs(:inserts_overlap?).with(@a,@b).returns(false)
      ScaffoldValidate.stubs(:inserts_overlap?).with(@b,@a).returns(false)
      ScaffoldValidate.sequence_errors(@sequence).empty?.should be_true
    end

    it "should return inserts when sequence inserts overlap" do
      ScaffoldValidate.stubs(:inserts_overlap?).with(@a,@b).returns(true)
      ScaffoldValidate.stubs(:inserts_overlap?).with(@b,@a).returns(true)
      ScaffoldValidate.sequence_errors(@sequence).should == [[@a,@b]].sort
    end

  end

  context "validating entries in a scaffold using the errors method" do

    before(:each) do
      @valid        = stub(:entry_type => :sequence)
      @invalid      = @valid.clone
      ScaffoldValidate.stubs(:sequence_errors).with(@valid).returns([])
      ScaffoldValidate.stubs(:sequence_errors).with(@invalid).returns([nil])
    end

    it "should return an empty array when scaffold is valid" do
      ScaffoldValidate.new([@valid,@valid]).errors.empty?.should be_true
    end

    it "should return invalid entries when scaffold is invalid" do
      ScaffoldValidate.new([@invalid,@valid]).errors.should == [@invalid]
    end

    it "should return invalid entries when scaffold is invalid" do
      ScaffoldValidate.new([@invalid,@valid]).errors.should == [@invalid]
    end

    it "should ignore entries which are not sequences" do
      @not_sequence = stub(:entry_type => :other)
      ScaffoldValidate.new([@valid,@not_sequence]).errors.empty?.should be_true
      ScaffoldValidate.new([@invalid,@not_sequence]).errors.should == [@invalid]
    end

  end

  context "printing errors using the errors method" do

    before(:each) do
      @scaffold = ScaffoldValidate.new(nil)
    end

    it "should return an empty string when scaffold is valid" do
      @scaffold.stubs(:errors).returns([])
      @scaffold.print_errors.should == ""
    end

    it "should return a yaml list of errors when scaffold is invalid" do
      sequence = stub(:name => :seq1)
      @scaffold.stubs(:errors).returns([sequence])
      ScaffoldValidate.stubs(:sequence_errors).with(sequence).returns(
        [[stub(:start => 1,:stop => 2)]])
      YAML.load(@scaffold.print_errors).should == {:seq1 => [{
        :start => 1, :stop => 2}]}
    end

  end

end

feature "scaffolder-validate" do

  scenario "testing a scaffold with a sequence with no overlapping inserts" do
    sequence = Sequence.new("sequence","ATTACCCTAC")
    insert   = Sequence.new("insert","GGGG")

    seq_file  = write_sequence_file(sequence,insert)
    scaffold = generate_scaffold(sequence)
    scaffold.first['sequence']['inserts'] = [
      {'source' => insert.definition, 'start' => 4, 'stop' => 5},
      {'source' => insert.definition, 'start' => 6, 'stop' => 7}
    ]
    scaf_file = write_scaffold_file(scaffold)

    scaffold_validate(scaf_file,seq_file).should == ""
  end

  scenario "testing a scaffold with a sequence with overlapping inserts" do
    sequence = Sequence.new("sequence","ATTACCCTAC")
    insert   = Sequence.new("insert","GGGG")

    seq_file  = write_sequence_file(sequence,insert)
    scaffold = generate_scaffold(sequence)
    scaffold.first['sequence']['inserts'] = [
      {'source' => insert.definition, 'start' => 4, 'stop' => 5},
      {'source' => insert.definition, 'start' => 5, 'stop' => 6}
    ]
    scaf_file = write_scaffold_file(scaffold)

    output = YAML.load(scaffold_validate(scaf_file,seq_file))
    output.keys.first.should == sequence.definition
    output[sequence.definition].should include({:start => 4, :stop => 5})
    output[sequence.definition].should include({:start => 5, :stop => 6})

  end

end
