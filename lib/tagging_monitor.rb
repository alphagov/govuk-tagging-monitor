class TaggingMonitor
  include StatsHelpers
  
  def initialize(base_path)
    @base_path = base_path
  end

  def retrieve_linter_warnings(base_path)
    linter = Linters::TaxonomyLinter.new(base_path)

    warnings = linter.lint([
      Linters::Taxons::AccordionCountLinter.warn_if_equal_to(0),
      Linters::Taxons::LeafCountLinter.warn_if_equal_to(0),
      Linters::Taxons::DepthCountLinter.new do |d|
        d.depth = 0
        d.count_linter = Linters::Taxons::CountLinter.warn_if_greater_than(0)
      end,
      Linters::Taxons::BlueBoxCountLinter.warn_if_equal_to(0),
    ])

    return linter.size, warnings
  end

  def publish_linter_warnings
    linter_size, warnings = retrieve_linter_warnings(@base_path)
    gauge 'navigation_pages.count', linter_size

    summary = "#{linter_size} taxons checked, #{warnings.size} issues found"

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
