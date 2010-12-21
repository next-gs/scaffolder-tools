require File.join(File.dirname(__FILE__),'spec_helper')

describe Scaffold2sequence do

  it "should inherit from Scaffolder::Tool" do
    described_class.superclass.should == Scaffolder::Tool
  end

  describe "execution when correctly instantiated" do

    before(:each) do
      entries = [{:name => 'seq1', :nucleotides => 'ATGC'}]

      @scaffold_file = File.new("scaffold",'w').path
      @sequence_file = File.new("sequence",'w').path

      write_scaffold_file(entries,@scaffold_file)
      write_sequence_file(entries,@sequence_file)
      settings = mock_command_line_settings(@scaffold_file,@sequence_file,{
        :definition => nil,:no => nil})

      tool = Scaffold2sequence.new(settings)
      @output = StringIO.new(tool.execute)
    end

    after(:each) do
      File.delete @scaffold_file, @sequence_file
    end

    it "should return the expected sequence" do
      Bio::FlatFile.auto(@output).first.seq.should == 'ATGC'
    end

  end

end
