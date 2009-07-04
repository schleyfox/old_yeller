require 'rake/testtask'
require File.join(File.dirname(__FILE__),'..', 'lib', 'old_yeller', 'report')
class OldYellerTestTask < Rake::TestTask; def initialize; nil; end; end

desc "Detect dead code"
task :old_yeller do
  rake_loader = OldYellerTestTask.new.rake_loader
  system "rcov -x \"Library\" -I\"lib:test\" #{rake_loader} \"dead_code.rb\""
  OldYeller::Report.new.write
end
