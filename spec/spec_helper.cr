require "spec"
require "timecop"
require "webmock"
require "./fixtures"

# Allow to print the Crystal class methods
# Usage:  `puts Spec::CLI.methods.sort`
class Object
  macro methods
    {{ @type.methods.map &.name.stringify }}
  end
end

class Spec::CLI
  def tags
    @tags
  end
end

Spec.around_each do |example|
  # Strategy to skip tests by tags
  # tags = Spec.cli.tags
  # if tags.nil? || tags.empty?
  #   # By default, skip tests with tags and run only Unit tests
  #   next if !example.example.all_tags.empty?
  # end

  # Timecop.return
  WebMock.reset
  # Integration tests should allow to send requests
  integration = example.example.all_tags.includes?("integration") || \
     example.example.file.includes?("spec/integration")
  WebMock.allow_net_connect = integration

  example.run
end

Spec.after_each do
  Timecop.return
end

require "../src/awscr-s3"
