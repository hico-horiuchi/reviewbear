require 'erb'
require 'json'
require 'rumale'

module Reviewbear::Handler
  class Analyze
    include Reviewbear::Helper::String

    SEED = 10.freeze
    COMMENT_THRESHOLD = 20.freeze
    COMMENT_LENGTH = 100.freeze
    TEMPLATE_PATH = '../../template/index.html.erb'.freeze

    def exec(**args)
      jira_site = args[:jira_site]
      project = args[:project]

      issues = JSON.parse(File.read("#{project}.json"), symbolize_names: true)

      pca = Rumale::Decomposition::PCA.new(n_components: 1)
      k_means = Rumale::Clustering::KMeans.new(n_clusters: issues.size / SEED)

      repositories = issues.map { |_, v| v[:pull_requests].keys }.flatten.uniq.sort
      samples = scan_issues(issues, repositories).map { |s| pca.fit_transform(s) }

      n_samples = Numo::DFloat.cast(samples)
      model = k_means.fit(n_samples)
      result = model.predict(n_samples)

      clusters = classify_issues(issues, result)
      comments = classify_comments(clusters)

      params = { jira_site: jira_site, project: project, repositories: repositories, clusters: clusters, comments: comments }
      template = File.read(File.expand_path(TEMPLATE_PATH, __FILE__))

      File.binwrite("#{project}.dat", Marshal.dump(model))
      File.write("#{project}.html", ERB.new(template).result(binding))
    end

    private

    def scan_issues(issues, repositories)
      issues.each_with_object([]) do |(_, issue), array|
        pull_requests = issue[:pull_requests]
        array << repositories.map do |repository|
          pull_request = pull_requests[repository]
          pull_request ? [pull_request[:additions], pull_request[:deletions]] : [0, 0]
        end
      end
    end

    def classify_issues(issues, result)
      clusters = result.to_a.uniq
      labels = issues.keys

      clusters.each_with_object([]) do |cluster, array|
        array[cluster] ||= {}
        result.eq(cluster).where.each do |i|
          key = labels[i]
          array[cluster][key] = issues[key]
        end
      end
    end

    def classify_comments(clusters)
      clusters.map do |cluster|
        cluster.values.each_with_object({}) do |value, hash|
          value[:pull_requests].each do |repository, pull_request|
            pull_request[:comments].each do |path, comments|
              hash[repository] ||= {}
              hash[repository][path] ||= {}

              comments.select do |c|
                c[:body].size > COMMENT_THRESHOLD
              end.each do |c|
                c[:body] = cut_off(c[:body], COMMENT_LENGTH)
              end.group_by do |c|
                c[:user]
              end.each do |user, comment|
                hash[repository][path][user] ||= []
                hash[repository][path][user] += comment
              end
            end
          end

          hash.each do |repository, pathes|
            pathes.select! { |_, users| users.present? }
          end
        end
      end
    end
  end
end
