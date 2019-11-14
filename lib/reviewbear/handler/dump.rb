require 'json'

module Reviewbear::Handler
  class Dump
    PULL_REQUEST_STATE = 'closed'.freeze

    def save(octokit_client, repo)
      pull_requests = octokit_client.pull_requests(repo, state: PULL_REQUEST_STATE)
      filename = "#{repo.split('/').last}.json"

      data = pull_requests.each_with_object({}) do |pr, pr_hash|
        files = octokit_client.pull_request_files(repo, pr[:number])

        next if files.empty?

        pr_hash[pr[:number]] = files.each_with_object({}) do |f, f_hash|
          f_hash[f[:filename]] = {
            additions: f[:additions],
            deletions: f[:deletions]
          }
        end
      end

      File.write(filename, JSON.pretty_generate(data))
    end
  end
end
