#!/usr/bin/env ruby
require_relative 'lib/github_client'
require_relative 'lib/issue_executor'

POLL_INTERVAL = (ENV['CALVIN_POLL_INTERVAL'] || 300).to_i

puts "Calvin — repo: #{ENV['CALVIN_REPO']}, interval: #{POLL_INTERVAL}s"

loop do
  begin
    issues = GithubClient.fetch_agent_issues
    puts "[#{Time.now.strftime('%H:%M:%S')}] #{issues.count} issue(s)"
    issues.each { |issue| IssueExecutor.new(issue).run }
  rescue StandardError => e
    puts "ERROR: #{e.message}\n#{e.backtrace.first(3).join("\n")}"
  end
  sleep POLL_INTERVAL
end
