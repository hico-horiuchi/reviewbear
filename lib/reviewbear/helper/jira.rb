require 'jira-ruby'

module Reviewbear::Helper
  class Jira
    attr_reader :client

    def initialize(site:, email:, token:)
      @client = ::JIRA::Client.new(
        site: site,
        username: email,
        password: token,
        context_path: '',
        auth_type: :basic
      )
    end
  end
end
