# GOV.UK Tagging Monitor

Collection of scripts that run regularly and check if everything is okay with
GOV.UK's new navigation pages (like https://www.gov.uk/education).

It [runs every hour on Jenkins][jenkins].

[jenkins]: https://deploy.publishing.service.gov.uk/job/govuk-tagging-monitor/

## Technical documentation

The project consists of a single rake task. This will:

- Check the navigation pages. In certain cases it will report warnings to
  the `#navigation` Slack channel.
- Send basic stats to our `statsd` instance. These stats are used on a
  [grafana dashboard][dashboard].

[dashboard]: https://grafana.publishing.service.gov.uk/dashboard/db/tagging-dashboard

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
