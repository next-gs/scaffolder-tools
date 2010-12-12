When /^running "([^"]*)"$/ do |command|
  cmd = File.join(File.dirname(__FILE__),'..','..','bin',command)
  cmd << " #{@scaffold_file} #{@sequence_file}"
  stdin, @stdout, @stderr = Open3.popen3(cmd)
end

When /^I call "([^"]*)" with arguments "([^"]*)"$/ do |command,args|
  bin = File.join(File.dirname(__FILE__),'..','..','bin',command)
  When "I run \"#{bin} #{args}\""
end

Given /^the sequence file is empty$/ do
  File.open(@sequence_file,'w'){|out| out.print ""}
end

Given /^the sequence file is missing$/ do
  FileUtils.rm(@sequence_file)
end

Given /^the sequence file does not contain "([^"]*)"$/ do |definition|
  sequences = Bio::FlatFile::auto(@sequence_file)
  sequences = sequences.reject do |sequence|
    sequence.definition == definition
  end

  File.open(@sequence_file,'w') do |out|
    sequences.each{ |sequence| out.puts(sequence.to_s) }
  end
end

Then /^it should( not)? produce an error$/ do |error_free|
  if error_free
    $?.exitstatus.should == 0
  else
    $?.exitstatus.should > 0
  end
end

Then /^it should generate the fasta sequence "([^"]*)"$/ do |sequence|
  Bio::FlatFile.open(Bio::FastaFormat, @stdout).first.seq.should == sequence
end

Then /^I should see the error message "([^"]*)"$/ do |message|
  @stderr.read.should include(message)
end
