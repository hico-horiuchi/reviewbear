require 'rumale'

module Reviewbear::Handler
  class Review
    include Reviewbear::Helper::Jira
    include Reviewbear::Helper::Octokit

    def exec(**args)
      jira_client = args[:jira_client]
      octokit_client = args[:octokit_client]
      ticket_id = args[:ticket_id]
      project = ticket_id.split('-').first

      pca = Rumale::Decomposition::PCA.new(n_components: 1)
      model = Marshal.load(File.binread("#{project}.dat"))

      issues = JSON.parse(File.read("#{project}.json"), symbolize_names: true)
      issue = jira_client.Issue.find(ticket_id)

      repositories = issues.map { |_, v| v[:pull_requests].keys }.flatten.uniq.sort
      pull_requests = get_pull_request_informations(octokit_client, scan_pull_request(issue)).map{ |k,v| [k.to_sym, v] }.to_h
      sample = repositories.map { |r| pull_requests[r] ? [pull_requests[r][:additions], pull_requests[r][:deletions]] : [0, 0] }

      n_samples = Numo::DFloat.cast([pca.fit_transform(sample)])
      result = model.predict(n_samples)

      puts "Cluster #{result.to_a.first + 1}"
    end
  end
end
