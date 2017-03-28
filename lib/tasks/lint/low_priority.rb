namespace :lint do
  desc <<-DESC
    Perform low-priority linting tasks on the taxonomy. The results are output to the console,
    and also posted to the #finding-things Slack channel as the "Disappointed Parrot"
  DESC
  task :low_priority do
    include StatsHelpers

    taxonomy = Linters::Taxonomy.new('/education')

    gauge 'navigation_pages.count', taxonomy.size

    warnings = taxonomy.lint([
      Linters::Taxons::AccordionCountLinter.warn_if_greater_than(25),
      Linters::Taxons::LeafCountLinter.warn_if_greater_than(25),
      Linters::Taxons::DepthCountLinter.new do |d|
        d.depth = 1
        d.count_linter = Linters::Taxons::CountLinter.warn_if_greater_than(5)
      end,
    ])

    slack_friendly_warnings = warnings.each_with_object([]) do |warning, slack_warnings|
      warning[:warnings_by_linter].each do |linter_warnings|
        linter_warnings[:warnings].each do |linter_warning|
          slack_warnings << "#{warning[:taxon][:base_path]}: #{linter_warning}"
        end
      end
    end

    puts "#{taxonomy.size} taxons checked, #{slack_friendly_warnings.size} issues found"

    if slack_friendly_warnings.any?
      message_payload = {
        username: 'Sad Parrot',
        icon_emoji: ':sadparrot:',
        text: "Oh no, there's a problem with some navigation pages:\n\n#{slack_friendly_warnings.join("\n")}",
        mrkdwn: true,
        channel: '#finding-things',
      }

      HTTP.post(ENV["BADGER_SLACK_WEBHOOK_URL"], body: JSON.dump(message_payload))

      puts JSON.pretty_generate(warnings)
    end
  end
end