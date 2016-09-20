# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

Please view this file on the master branch, on stable branches it's out of date.

## [Unreleased]
### Added
- Service aliases (@jmeizner)
- Resource management REST API documentation (@dharezlak)
- Add new registered user into default groups (@mkasztelnik)
- Group hierarchies management UI (@mkasztelnik)
- Deploy to production when tag is pushed into remote git repository (@tomek.bartynski)
- Show service token on show view (@mkasztelnik)
- Group management UI (@mkasztelnik)
- Service management UI (@Nuanda, @mkasztelnik)
- Delegate user credentials in service resource management REST API (@mkasztelnik)
- Service ownership (@Nuanda)
- Setup rubocop (@tomek.bartynski)
- Setup continuous delivery (@tomek.bartynski)
- Sent confirmation email after user account is approved (@mkasztelnik)
- Project description (@amber7b, @mkasztelnik, @dharezlak)
- User profile page (@mkasztelnik)
- REST interface for local resource management (@dharezlak)
- WebDav file browser (@dharezlak)
- Introduce service (@mkasztelnik)
- Find resources using regular expressions (@dharezlak)
- Notify supervisors after new user registered (@mkasztelnik)
- Asynchronous email sending (@mkasztelnik)
- Approve user account after PLGrid login (@mkasztelnik)
- Use Rimrock for PLGrid job submission (@mkasztelnik)
- Push patient case files into PLGrid using PLGData (@Nuanda)
- Group hierarchies performance tests (@tomek.bartynski)
- Custom error pages (@mkasztelnik)
- Help pages for REST API (@mkasztelnik)
- JWT token expiry set to 1 hour (@tomek.bartynski)
- Store PLGrid proxy in DB while logging in using PLGrid openId (@mkasztelnik)
- Get user gravatar (@mkasztelnik)
- Sentry integration (@mkasztelnik)
- Patient case POC (@Nuanda)
- Resource and permission management (@dharezlak)
- JWT configuration (@tomek.bartynski)
- JWT Devise login strategy (@mkasztelnik)
- Policy Decision Point (PDP) REST API (@mkasztelnik)
- Accepting new users by supervisor (@dharezlak)
- Integration with PLGrid openId (@mkasztelnik)
- Use [gentelalla](https://github.com/puikinsh/gentelella) theme (@dharezlak, @mkasztelnik)
- Basic project structure (@mkasztelnik, @dharezlak)

### Changed
- Increase fade out time for flash messages into 10 seconds (@mkasztelnik)
- Rewrite migrations to avoid using ActiveRecord (@amber7b)
- Service views refactoring - separation for global/local policies management (@mkasztelnik, @Nuanda)
- Delete service ownership when user or service is destroyed (@mkasztelnik)
- WebDav browser JS files obtained from a dedicated CDN (@dharezlak)
- Unify UIs for all CRUD views (@mkasztelnik)
- Resource separation into `global` and `local` (@dharezlak)
- Simplify login form pages using `simple_form` wrapper (@mkasztelnik)
- Left menu refactoring - not it is server side rendered (@mkasztelnik)
- Upgrade to Rails 5 (@mkasztelnik, @Nuanda)

### Deprecated

### Removed

### Fixed
- Show `new` view instead of `edit` while creating new group and validation failed (@mkasztelnik)
- Show notice information to the user after new account created that account needs to
  be approved by supervisor (@mkasztelnik)
- Don't allow to create group without group owner (@mkasztelnik)
- Make zero clipboard work with turbolinks (@mkasztelnik)
- Make icheck work with turbolinks (@mkasztelnik)
- Policies do not forbid access for access methods which they do not define (@Nuanda)
- Fix group validation - at last one group owner is needed (@mkasztelnik)
- Disable turbolinks on WebDav browser view to make GWT work (@mkasztelnik)
- Fix extra spaces in markdown code blocks (@mkasztelnik)
- Improved service URI validation (@Nuanda)

### Security
