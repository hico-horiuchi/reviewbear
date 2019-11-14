require 'octokit'

module Reviewbear::Helper
  class Octokit
    attr_reader :client

    def initialize(access_token)
      @client = ::Octokit::Client.new(access_token: access_token)
    end
  end
end
