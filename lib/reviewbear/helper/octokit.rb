require 'octokit'

module Reviewbear::Helper
  class Octokit
    attr_reader :client

    def initialize(token:)
      @client = ::Octokit::Client.new(access_token: token)
    end
  end
end
