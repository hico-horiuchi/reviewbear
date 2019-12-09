require 'erb'
require 'json'
require 'rumale'

module Reviewbear::Handler
  class Analyze
    TEMPLATE_PATH = '../../template/index.html.erb'.freeze
    SEED = 10.freeze

    def exec(**args)
      jira_site = args[:jira_site]
      project = args[:project]

      issues = JSON.parse(File.read("#{project}.json"), symbolize_names: true)

      pca = Rumale::Decomposition::PCA.new(n_components: 1)
      k_means = Rumale::Clustering::KMeans.new(n_clusters: issues.size / SEED)

      repositories = issues.map { |_, v| v[:pull_requests].keys }.flatten.uniq.sort
      samples = scan_issues(issues, repositories).map { |s| pca.fit_transform(s) }

      n_samples = Numo::DFloat.cast(samples)
      result = k_means.fit_predict(n_samples)

      params = { jira_site: jira_site, project: project, repositories: repositories, clusters: cluster_issues(issues, result) }
      template = File.read(File.expand_path(TEMPLATE_PATH, __FILE__))

      File.write("#{project}.html", ERB.new(template).result(binding))
    end

    private

    def scan_issues(issues, repositories)
      samples = []

      issues.each do |_, issue|
        pull_requests = issue[:pull_requests]
        samples << repositories.map do |repository|
          pull_request = pull_requests[repository]
          pull_request ? [pull_request[:additions], pull_request[:deletions]] : [0, 0]
        end
      end

      samples
    end

    def cluster_issues(issues, result)
      clusters = result.to_a.uniq
      labels = issues.keys

      data = clusters.each_with_object([]) do |cluster, array|
        array[cluster] ||= {}
        result.eq(cluster).where.each do |i|
          key = labels[i]
          array[cluster][key] = issues[key]
        end
      end

      data.sort { |a, b| a.keys.size <=> b.keys.size }
    end
  end
end
