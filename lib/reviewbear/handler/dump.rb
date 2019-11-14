require 'json'

module Reviewbear::Handler
  class Dump
    PULL_REQUEST_STATE = 'closed'.freeze

    def save(octokit_client, repo)
      pull_requests = octokit_client.pull_requests(repo, state: PULL_REQUEST_STATE)
      filename = "#{repo.split('/').last}.json"

      data = pull_requests.each_with_object([]) do |pull_request, arr|
        files = octokit_client.pull_request_files(repo, pull_request[:number])

        next if files.empty?

        arr << {
          html_url: pull_request[:html_url],
          files: convert_files(files)
        }
      end

      File.write(filename, JSON.pretty_generate(data))
    end

    private

    def convert_files(files)
      files.map { |f| "#{f[:filename]}+#{f[:additions]}-#{f[:deletions]}" }.join(':')
    end
  end
end
