# GOV.UK Tagging Monitor

Collection of scripts that run regularly and check if everything is okay with
GOV.UK's new navigation pages (like https://www.gov.uk/education).

It [runs every hour on Jenkins][jenkins].

[jenkins]: https://deploy.publishing.service.gov.uk/job/govuk-tagging-monitor/

## Technical documentation

The project consists of a number of rake tasks. These will:

- Check the navigation pages. In certain cases it will report warnings to
  the `#scrutineers` Slack channel.
- Send basic stats to our `statsd` instance. These stats are used on a
  [grafana dashboard][dashboard].
- Analyse the links on navigation pages, and report these in [Google Drive][google-drive].

[dashboard]: https://grafana.publishing.service.gov.uk/dashboard/db/tagging-dashboard
[google-drive]: https://drive.google.com/drive/folders/0B6ekrNZ58HKUc3BqT3NoblRfOUE

### Developing with Google Drive

The Google Drive integration is handled by the [`google-drive-ruby`][google-drive-ruby] gem.
Authentication with Google Drive is handled by a service account attached to the
[`govuk-tagging-monitor`][google-cloud] Google Cloud project.

See the documentation on Authorization through the Gem [here][auth-docs].

Since the authentication is performed by a service account, you won't need to log in to Google
to interact with Google Drive. However, you will need a credentials JSON file that authorizes
the project to log in using this service account. You can find the JSON file
[on Jenkins][auth-json]. You will need to copy it into the root of your working directory, but
**do not commit this file**.

[google-drive-ruby]: https://github.com/gimite/google-drive-ruby
[google-cloud]: https://console.cloud.google.com/home/dashboard?project=govuk-tagging-monitor
[auth-docs]: https://github.com/gimite/google-drive-ruby/blob/master/doc/authorization.md
[auth-json]: https://deploy.publishing.service.gov.uk/job/govuk_navigation_link_analysis/ws/govuk-tagging-monitor-2f614b9b92c2.json

### Dependencies

No dependencies.

### Running the application

```
bundle exec rake run
```

### Running the test suite

```
bundle exec rspec
```

## Licence

[MIT License](LICENSE)
