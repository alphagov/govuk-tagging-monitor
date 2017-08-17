namespace :lint do
  desc <<-DESC
    Perform high-priority linting tasks on the taxonomy. The results are output to the console,
    and also posted to the #taxonomy Slack channel as the "Sad Parrot"
  DESC
  task :high_priority do

    ['/education', '/childcare-parenting'].each do |base_path|
      tagging_monitor = TaggingMonitor.new(base_path)
      tagging_monitor.publish_linter_warnings
    end
  end
end
