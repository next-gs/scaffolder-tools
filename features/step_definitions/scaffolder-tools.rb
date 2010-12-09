When /^running "([^"]*)"$/ do |command|
    cmd = File.join(File.dirname(__FILE__),'..','..','bin',command)
    cmd << " #{@scaffold_file} #{@sequence_file}"
    @output = StringIO.new(`#{cmd}`)
end

Then /^it should not produce an error$/ do
    $?.should == 0
end

Then /^it should generate the fasta sequence "([^"]*)"$/ do |sequence|
  puts @output
  Bio::FlatFile.open(Bio::FastaFormat, @output).first.seq.should == sequence
end
