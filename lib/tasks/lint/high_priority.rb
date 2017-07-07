namespace :lint do
  desc <<-DESC
    Perform high-priority linting tasks on the taxonomy. The results are output to the console,
    and also posted to the #scrutineers Slack channel as the "Sad Parrot"
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
      notification_text = "#{summary}\n\n#{warnings.join("\n")}"

      Notifiers::Slack.notify(
        text: notification_text,
        username: 'Sad Parrot',
        emoji: ':sadparrot:',
      )

      puts notification_text
      puts summary.red
    else
      puts summary.green
    end
  end
end
