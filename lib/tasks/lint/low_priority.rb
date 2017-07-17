namespace :lint do
  desc <<-DESC
    Perform low-priority linting tasks on the taxonomy. The results are output to the console,
    and also posted to the #taxonomy Slack channel as the "Disappointed Parrot"
  DESC
  task :low_priority do
    include StatsHelpers

    linter = Linters::TaxonomyLinter.new('/education')

    gauge 'navigation_pages.count', linter.size

    warnings = linter.lint([
      Linters::Taxons::AccordionCountLinter.warn_if_greater_than(25),
      Linters::Taxons::LeafCountLinter.warn_if_greater_than(25),
      Linters::Taxons::DepthCountLinter.new do |d|
        d.depth = 1
        d.count_linter = Linters::Taxons::CountLinter.warn_if_greater_than(5)
      end,
      Linters::Taxons::BlueBoxCountLinter.warn_if_not_equal_to(5),
    ])

    summary = "#{linter.size} taxons checked, #{warnings.size} issues found"

    if warnings.any?
      message_payload = {
        username: 'Disappointed Parrot',
        icon_emoji: ':bored_parrot:',
        text: "#{summary}\n\n#{warnings.join("\n")}",
        mrkdwn: true,
        channel: '#taxonomy',
      }

      HTTP.post(ENV["BADGER_SLACK_WEBHOOK_URL"], body: JSON.dump(message_payload))

      puts message_payload[:text]

      puts summary.red
    else
      puts summary.green
    end
  end
end
