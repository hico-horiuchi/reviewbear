require 'thor'

module Reviewbear
  class Command < Thor
    def initialize(*args)
      super

      @octokit = Helper::Octokit.new(ENV['GITHUB_ACCESS_TOKEN'])
    end

    desc 'dump REPO', 'Save all pull requests as JSON file'
    def dump(repo)
      dump = Handler::Dump.new
      dump.save(@octokit.client, repo)
    end

    desc 'version', 'Print version information'
    def version
      version = Handler::Version.new
      version.print
    end
  end
end
