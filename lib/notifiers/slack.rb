module Notifiers
  class Slack
    def self.notify(text:, username: 'Informative Parrot', emoji: ':gentleman_parrot:', channel: '#navigation')
      message_payload = {
        username: username,
        icon_emoji: emoji,
        text: text,
        mrkdwn: true,
        channel: channel,
      }

      HTTP.post(ENV["BADGER_SLACK_WEBHOOK_URL"], body: JSON.dump(message_payload))
    end
  end
end
