# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

Please view this file on the master branch, on stable branches it's out of date.

## [Unreleased]
### Added
- Basic project structure (@mkasztelnik, @dharezlak)
- Use [gentelalla](https://github.com/puikinsh/gentelella) theme (@dharezlak, @mkasztelnik)
- Integration with PLGrid openId (@mkasztelnik)
- Accepting new users by supervisor (@dharezlak)
- Policy Decision Point (PDP) REST API (@mkasztelnik)
- JWT Devise login strategy (@mkasztelnik)
- JWT configuration (@tomek.bartynski)
- Resource and permission management (@dharezlak)
- Patient case POC (@Nuanda)
- Sentry integration (@mkasztelnik)
- Get user gravatar (@mkasztelnik)
- Store PLGrid proxy in DB while logging in using PLGrid openId (@mkasztelnik)
- JWT token expiry set to 1 hour (@tomek.bartynski)
- Help pages for REST API (@mkasztelnik)
- Custom error pages (@mkasztelnik)
- Group hierarchies performance tests (@tomek.bartynski)
- Push patient case files into PLGrid using PLGData (@Nuanda)
- Use Rimrock for PLGrid job submission (@mkasztelnik)
- Approve user account after PLGrid login (@mkasztelnik)
- Asynchronous email sending (@mkasztelnik)
- Notify supervisors after new user registered (@mkasztelnik)
- Find resources using regular expressions (@dharezlak)
- Introduce service (@mkasztelnik)
- WebDav file browser (@dharezlak)
- REST interface for local resource management (@dharezlak)
- User profile page (@mkasztelnik)
- Project description (@amber7b, @mkasztelnik, @dharezlak)
- Sent confirmation email after user account is approved (@mkasztelnik)
- Setup continuous delivery (@tomek.bartynski)
- Setup rubocop (@tomek.bartynski)
- Service ownership (@Nuanda)
- Delegate user credentials in service resource management REST API (@mkasztelnik)
- Service management UI (@Nuanda, @mkasztelnik)
- Group management UI (@mkasztelnik)
- Show service token on show view (@mkasztelnik)
- Deploy to production when tag is pushed into remote git repository (@tomek.bartynski)
- Group hierarchies management UI (@mkasztelnik)
- Add new registered user into default groups (@mkasztelnik)
- Resource management REST API documentation (@dharezlak)
- Service aliases (@jmeizner)
- Issue and merge request templates (@mkasztelnik)
- Rake task for generating sample data for development purposes (@tomek.bartynski)
- Users can set Access Methods for new and existing Services (@Nuanda)
- There are global Access Methods which work for all Services (@Nuanda)
- Bullet gem warns about database queries performance problems (@tomek.bartynski)
- Omnipotent admin (@Nuanda)
- Global resource access policies management UI (@mkasztelnik)

### Changed
- Upgrade to Rails 5 (@mkasztelnik, @Nuanda)
- Left menu refactoring - not it is server side rendered (@mkasztelnik)
- Simplify login form pages using `simple_form` wrapper (@mkasztelnik)
- Resource separation into `global` and `local` (@dharezlak)
- Unify UIs for all CRUD views (@mkasztelnik)
- WebDav browser JS files obtained from a dedicated CDN (@dharezlak)
- Delete service ownership when user or service is destroyed (@mkasztelnik)
- Service views refactoring - separation for global/local policies management (@mkasztelnik, @Nuanda)
- Rewrite migrations to avoid using ActiveRecord (@amber7b)
- Increase fade out time for flash messages into 10 seconds (@mkasztelnik)
- Got to new user session path after logout (@mkasztelnik)

### Deprecated

### Removed
- Remove webdav specific access methods from seeds (@mkasztelnik)

### Fixed
- Improve service URI validation (@Nuanda)
- Fix extra spaces in markdown code blocks (@mkasztelnik)
- Disable turbolinks on WebDav browser view to make GWT work (@mkasztelnik)
- Fix group validation - at last one group owner is needed (@mkasztelnik)
- Policies do not forbid access for access methods which they do not define (@Nuanda)
- Make icheck work with turbolinks (@mkasztelnik)
- Make zero clipboard work with turbolinks (@mkasztelnik)
- Don't allow to create group without group owner (@mkasztelnik)
- Show notice information to the user after new account created that account needs to
  be approved by supervisor (@mkasztelnik)
- Show `new` view instead of `edit` while creating new group and validation failed (@mkasztelnik)
- Remove n+1 query for service ownership in Services#index view (@Nuanda)
- Made it possible to navigate to Service#show with a click if a service had no name (@Nuanda)
- Content passed to the file store JS browser sanitized to prevent XSS attacks (@dharezlak)
- Turbolinks disabled directly on the Files link (@dharezlak)
- PDP returns 403 when `uri` or `access_method` query params are missing (@mkasztelnik)
- Fix missing translations on service list and service show views (@mkasztelnik, @Nuanda)

### Security
