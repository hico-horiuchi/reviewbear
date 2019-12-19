require 'thor'

module Reviewbear
  class Command < Thor
    include Helper::Jira
    include Helper::Octokit

    def initialize(*args)
      super

      @jira_client = get_jira_client(
        site: Config.jira.site,
        email: Config.jira.email,
        token: Config.jira.token
      )

      @octokit_client = get_octokit_client(
        token: Config.github.token
      )
    end

    desc 'analyze PROJECT', 'Classify issues using k-nearest neighbor algorithm'
    def analyze(project)
      analyze = Handler::Analyze.new
      analyze.exec(
        jira_site: Config.jira.site,
        project: project
      )
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
