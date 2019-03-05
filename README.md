# Vapor - EurValve portal [![build status](https://gitlab.com/eurvalve/vapor/badges/master/build.svg)](https://gitlab.com/eurvalve/vapor/commits/master)

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
  * PostgreSQL citext extension (`sudo apt-get install postgresql-contrib`)
  * Redis (`sudo apt-get install redis-server`)
  * PostgreSQL libpq-dev (`sudo apt-get install libpq-dev`)
  * NodeJS (`sudo apt-get install nodejs`)

## DBMS Settings

You need to create user/role for your account in PostgreSQL. You can do it
using the 'createuser' command line tool. Then, make sure to alter this user
for rights to create databases.

At the moment Superuser privileges are required due to citext. See below
for the instruction.

### Manual activation of the citext extension

1. Create the databases (at least for the development and test environments).
   You may run `bin/setup` (and allow it to fail due to insufficient privileges,
   but only after the DBs are created) or create them manually with an
   unprivileged user as the owner.
2. As the PostgreSQL superuser, run the `CREATE EXTENSION IF NOT EXISTS citext
   WITH SCHEMA public;` on all databases (dev, test, ...) to activate the
   extension. So login to the `vapor_development` database as the superuser (it is
   usually called 'postgres') and issue the CREATE EXTENSION command above. Then
   switch to `vapor_test` and do the same.

When done, issue the `bin/setup` command again, as a regular system user. This
time it should have no problem completing.


## Installation

```
bin/setup
```

## Configuration

You need to:
* copy config/puma.rb.example into config/puma.rb
  and edit as required (env, location, socket/tcp),
* create required directories defined in the config in tmp (such as pids)

## Running

To start only web application run:
```
bin/rails server
```

We are also using [sidekiq](https://github.com/mperham/sidekiq) to execute
delayed jobs and [clockwork](https://github.com/tomykaira/clockwork) for
triggering delayed jobs in defined interval. To run full application stack
perform following steps:
```
gem install foreman
foreman start
```

If you want to start development environment with https support first make sure
that `crt` and `key` are generated for localhost domain:

```
openssl req -x509 -sha256 -nodes -newkey rsa:2048 -days 365 -keyout tmp/localhost.key -out tmp/localhost.crt
```

Next you can use development foreman configuration:

```
foreman start -f Procfile.dev
```

or shortcut:
```
./bin/dev-server
```
to start https development environment (located at https://localhost:3000).


To load sample data for development purposes run:
```
bundle exec rake dev:prime RAILS_ENV=development
```
This task depends on _db:setup_ task so be aware that data present in database is erased.

Vapor uses a file store backend - the EurValve's internal WebDAV File Store.

## ENV variables

We are using ENV variables to keep secrets safe. To customize the application
you can set the following ENV variables:

  * `GRANT_ID` (optional) - grant id used to start slurm jobs on Prometheus
    supercomputer
  * `PIPELINE_SSH_KEY` - path to ssh key which allows to clone computations
    gitlab repositories (such as Heart model or Blood flow)
  * `SEGMENTATION_URL` - segmentation own cloud service url
  * `SEGMENTATION_UI_URL` - segmentation own cloud UI url
  * `SEGMENTATION_USER` - segmentation own cloud service username
  * `SEGMENTATION_PASSWORD` - segmentation own cloud service password
  * `JWT_KEY_PATH` (optional) - path to key used to generate user JWT tokens
  * `REDIS_URL` (optional) - redis database url
  * `WEB_DAV_BASE_URL` (optional) - FileStore web dav root URL
  * `ATMOSPHERE_BASE_URL` (optional) - Atmosphere root URL
  * `DATA_SETS_PAGE_URL` (optional) - ArQ URL
  * `GITLAB_HOST` - Gitlab host (without https, e.g. gitlab.com)
  * `GITLAB_API_PRIVATE_TOKEN` - Gitlab access token used to fetch Rimrock
  * `CLOCK_UPDATE` - Computations update period (in seconds)
  * `ANSYSLI_SERVERS` - location of custom ansys license servers
  * `ANSYSLMD_LICENSE_FILE`- location of custom ansys license file
  * `FILESTORE_SECRET` - FileStore secret used during file synchronization
    callback authentication. If this value is set than active data
    synchronization is turned off.

## Testing

Some tests require Chrome headless installed. Please take a look at:
https://developers.google.com/web/updates/2017/04/headless-chrome for manual. To
install chrome on your debian based machine use following snippet:

```
curl -sS -L https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list

apt-get update -q
apt-get install -y google-chrome-stable
```

To execute all tests run:

```
bundle exec rspec
```

To execute File Storage integration tests:
1. Obtain EurValve dev file store key in the form of a pem file
2. Set path to this certificate in application.yml jwt.key value
3. Set test user names and email ENV values (see secrets.yml) - this user needs to be in the 'webdav' group
4. Run rspec with files tag on:

```
bundle exec rspec --tag files
```

Use guard to execute tests connected with modified file:

```
guard
```

To execute Gitlab integration tests:
1. Obtain a valid Gitlab user token with access to the eurvalve/blood-flow project
2. Assign token payload to the GITLAB_API_PRIVATE_TOKEN environmental variable (e.g. by editing `.env`)
3. Run rspec with gitlab tag on:

```
bundle exec rspec --tag gitlab
```

## Using bullet to increase application performance
[Bullet](https://github.com/flyerhzm/bullet) gem is enabled in _development_ and _test_ environments.
While running application in development or running tests _bullet_ logs warnings to _log/bullet.log_ file.

## Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new pull request
6. When feature is ready add reviewers and wait for feedback (at least one
   approve should be given and all review comments should be resolved)
