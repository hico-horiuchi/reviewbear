require 'octokit'

module Reviewbear::Helper
  module Octokit
    def get_octokit_client(token:)
      ::Octokit::Client.new(access_token: token)
    end

    def get_pull_request_informations(octokit_client, pull_requests)
      pull_requests.each_with_object({}) do |(repository, number), hash|
        begin
          hash[repository] = get_pull_request_information(octokit_client, repository, number.to_i)
        rescue ::Octokit::NotFound
          next
        end
      end
    end

    def get_pull_request_information(octokit_client, repository, number)
      pull_request = octokit_client.pull_request(repository, number)
      user = pull_request.user.login

      {
          number: number,
          additions: pull_request.additions,
          deletions: pull_request.deletions,
          comments: get_pull_request_comments(octokit_client, repository, number, user)
      }
    end

    def get_pull_request_comments(octokit_client, repository, number, user)
      comments = octokit_client.pull_request_comments(repository, number)

      comments.each_with_object({}) do |comment, hash|
        next if comment.user.login == user

        hash[comment.path] ||= []
        hash[comment.path] << {
          body: comment.body,
          user: comment.user.login,
          url: comment.html_url
        }
      end
    end
  end
end
