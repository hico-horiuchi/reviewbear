require 'thor'

module Reviewbear
  class Command < Thor
    def initialize(*args)
      super

      @jira_client = Helper::Jira.new(
        site: Config.jira.site,
        email: Config.jira.email,
        token: Config.jira.token
      ).client

      @octokit_client = Helper::Octokit.new(
        token: Config.github.token
      ).client
    end

    desc 'dump PROJECT', 'Save all issues including pull requests'
    def dump(project)
      dump = Handler::Dump.new
      dump.exec(
        jira_client: @jira_client,
        octokit_client: @octokit_client,
        project: project
      )
    end

    desc 'version', 'Print version information'
    def version
      version = Handler::Version.new
      version.exec
    end
  end
end
