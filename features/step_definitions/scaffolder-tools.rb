When /^I call "([^"]*)" with arguments "([^"]*)"$/ do |command,args|
  bin = File.join(File.dirname(__FILE__),'..','..','bin',command)
  When "I run `#{bin} #{args}`"
end
