# Vapor - EurValve portal

## Project description

Vapor is a portal framework for the EurValve project. The goal of EurValve is to facilitate clinical modeling of heart
valvular defects, and to simulate treatment strategies for various types of valve-related cardiac conditions. In order
to facilitate this goal the project aims to prepare a set of so-called Reduced Order Models (ROM) whereby detailed
simulations of representative cases will be performed in advance (given that they require substantial HPC involvement
and may run for a long time), following which each patient can be matched to one of the representative cases on the
basis of a reduced set of input data. This, in turn, enables the system to produce accurate and timely treatment
predictions for real-life patient cases - a task handled by the Decision Support System, another component of the
EurValve software stack.

The aim of Vapor is to provide a one-stop environment for the so-called research (computational) branch of EurValve,
i.e. permit computational scientists to manage representative patient models, schedule HPC simulations, download
results and manage experimental pipelines.

Vapor provides:

  * A consistent, Web-based GUI
  * HPC access automation, including staging of input data and retrieval of results from HPC storage
  * A WebDAV like data federation to manage all file-based data relevant to EurValve
  * A uniform security model, permitting authentication and authorization when accessing any of the above


Vapor is intended for members of the EurValve consortium and their clinical collaborators.

## Dependencies

  * MRI 2.3.x
  * PostgreSQL

## Installation

```
bin/setup
```

## Running

To start only web application run:
```
bin/rails server
```

We are also using [sidekiq](https://github.com/mperham/sidekiq) to execute
delayed jobs and [clockwork](https://github.com/tomykaira/clockworki) for
triggering delayed jobs in defined interval. To run full application stack
perform following steps:
```
gem install foreman
foreman start
```

To load sample data for development purposes run:
```
bundle exec rake dev:prime RAILS_ENV=development
```
This task depends on _db:setup_ task so be aware that data present in database is erased.

## Testing

To execute all tests run:

```
bundle exec rspec
```

To execute File Storage integration tests:
1. Get an expired and a valid PLGrid/Prometheus user proxy
2. Put paths to these in proper ENV values (see secrets.yml)
3. Run rspec with proxy tag on:

```
bundle exec rspec --tag proxy
```

Use guard to execute tests connected with modified file:

```
guard
```

## Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new pull request
6. When feature is ready add "ready for review" label

## Review process

To improve the reviewing process three labels should be used to monitor it:

  * `ready for review` - should be set by the merge request owner when a merge
request is ready for being reviewed by an assignee,
  * `in review` - set by the reviewer when the reviewing process starts,
  * `reviewed` - set by the reviewer when all the remarks are written down and
the review process is finished.

When the merge request owner is notified that the review is finished (`reviewed`
flag set) he should fix/respond to all the remarks and decide whether the merge
request should be merged or reviewed again (by setting the `ready for review` 
label again).