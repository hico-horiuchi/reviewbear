require 'jira-ruby'

module Reviewbear::Helper
  module Jira
    PULL_REQUEST_PATTERN = /https:\/\/github.com\/(?<repository>[\w-]+\/[\w-]+)\/pull\/(?<number>\d+)/

    def get_jira_client(site:, email:, token:)
      JIRA::Client.new(
        site: site,
        username: email,
        password: token,
        context_path: '',
        auth_type: :basic
      )
    end

    def scan_pull_request(issue)
      issue.description.scan(PULL_REQUEST_PATTERN)
    end
  end
end
