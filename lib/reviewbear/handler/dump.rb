require 'json'

module Reviewbear::Handler
  class Dump
    MAX_RESULTS = 50.freeze
    PULL_REQUEST_PATTERN = /https:\/\/github.com\/(?<repo>[\w-]+\/[\w-]+)\/pull\/(?<number>\d+)/

    def exec(**args)
      jira_client = args[:jira_client]
      octokit_client = args[:octokit_client]
      project = args[:project]

      data = {}

      issues = search_issues(jira_client, jql(project))
      scan_pull_requests(issues).each do |key, pull_requests|
        data[key] ||= {}
        data[key]['summary'] = issues.find { |i| i.key == key }.summary
        data[key]['pull_requests'] = get_additions_and_deletions(octokit_client, pull_requests)
      end

      File.write("#{project}.json", JSON.pretty_generate(data))
    end

    private

    def jql(project)
      "project = #{project} AND status = Done AND development[pullrequests].all > 0"
    end

    def search_issues(jira_client, query)
      start_at = 0
      issues = []

      loop do
        options = { start_at: start_at, max_results: MAX_RESULTS }
        results = jira_client.Issue.jql(query, options)
        issues += results

        break if results.size < MAX_RESULTS
        start_at += MAX_RESULTS
      end

      issues
    end

    def scan_pull_requests(issues)
      issues.each_with_object({}) do |issue, hash|
        next if issue.description.nil?
        pull_requests = issue.description.scan(PULL_REQUEST_PATTERN)
        next if pull_requests.empty?
        hash[issue.key] = pull_requests.uniq
      end
    end

    def get_additions_and_deletions(octokit_client, pull_requests)
      pull_requests.each_with_object({}) do |(repo, number), hash|
        begin
          pull_request = octokit_client.pull_request(repo, number.to_i)
          hash[repo] = {
            number: number.to_i,
            additions: pull_request.additions,
            deletions: pull_request.deletions
          }
        rescue Octokit::NotFound
          next
        end
      end
    end
  end
end
