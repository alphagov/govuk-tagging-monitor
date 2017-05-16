namespace :lint do
  desc <<-DESC
    Perform high-priority linting tasks on the taxonomy. The results are output to the console,
    and also posted to the #navigation Slack channel as the "Sad Parrot"
  DESC
  task :high_priority do
    include StatsHelpers

    linter = Linters::TaxonomyLinter.new('/education')

    gauge 'navigation_pages.count', linter.size

    warnings = linter.lint([
      Linters::Taxons::AccordionCountLinter.warn_if_equal_to(0),
      Linters::Taxons::LeafCountLinter.warn_if_equal_to(0),
      Linters::Taxons::DepthCountLinter.new do |d|
        d.depth = 0
        d.count_linter = Linters::Taxons::CountLinter.warn_if_greater_than(0)
      end,
    ])

    summary = "#{linter.size} taxons checked, #{warnings.size} issues found"

    if warnings.any?
      message_payload = {
        username: 'Sad Parrot',
        icon_emoji: ':sadparrot:',
        text: "#{summary}\n\n#{warnings.join("\n")}",
        mrkdwn: true,
        channel: '#navigation',
      }

      HTTP.post(ENV["BADGER_SLACK_WEBHOOK_URL"], body: JSON.dump(message_payload))

      puts message_payload[:text]

      puts summary.red
    else
      puts summary.green
    end
  end
end
