require 'fuzzy_match'
require 'json'

module Reviewbear::Handler
  class Match
    def find(octokit_client, repo, number)
      files = octokit_client.pull_request_files(repo, number)
      pull_requests = load_json(repo)
      fz = ::FuzzyMatch.new(pull_requests, read: :files)

      puts fz.find(convert_files(files)).html_url
    end

    private

    def convert_files(files)
      files.map { |f| "#{f[:filename]}+#{f[:additions]}-#{f[:deletions]}" }.join(':')
    end

    def load_json(repo)
      filename = "#{repo.split('/').last}.json"
      JSON.parse(File.read(filename), object_class: OpenStruct)
    end
  end
end
