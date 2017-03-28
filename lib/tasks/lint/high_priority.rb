namespace :lint do
  desc <<-DESC
    Perform high-priority linting tasks on the taxonomy
  DESC
  task :high_priority do
    taxonomy = Linters::Taxonomy.new('/education')

    warnings = taxonomy.lint([
      Linters::Taxons::AccordionCountLinter.new { |count| count == 0 },
      Linters::Taxons::LeafCountLinter.new { |count| count == 0 },
      Linters::Taxons::DepthCountLinter.at_depth(0) { |count| count > 0 },
    ])

    if warnings.any?
      message_payload = {
        username: "Sad Parrot",
        icon_emoji: ":sadparrot:",
        text: "Oh no, there's a problem with some navigation pages:\n\n#{JSON.pretty_generate(warnings)}",
        mrkdwn: true,
        channel: '#finding-things',
      }

      # HTTP.post(ENV["BADGER_SLACK_WEBHOOK_URL"], body: JSON.dump(message_payload))

      puts message_payload[:text]
    end
  end
end