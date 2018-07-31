# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

Please view this file on the master branch, on stable branches it's out of date.

## Unreleased

### Added
- Patients API (@mkasztelnik)
- Accepting `file.zip` as a correct input for segmentation (@Nuanda)

### Changed
- Segmentation output files have shorter names (@Nuanda)

### Deprecated

### Removed

### Fixed
- Fixed GitLab integration spec (@Nuanda)

### Security

## 0.10.0

### Added
- User can select segmentation run mode before start (@mkasztelnik)
- Possibility to configure custom Ansys licenses for pipeline computation (@mkasztelnik)
- `pipeline_identifier` `case_number` and `token` computation script helpers (@mkasztelnik)

### Changed
- Use Gitlab review procedure instead of labels (@mkasztelnik)
- `stage_in` returns error code when unable to download FileStore file (@mkasztelnik)
- Set JWT token expiration time to 24h (@mkasztelnik)

### Deprecated

### Removed
- Computation script repositories removed from `eurvalve.yml`, step repository
  configuration used instead (@mkasztelnik)

### Fixed
- Fix unused pipeline title missing (@mkasztelnik)

### Security

## 0.9.1

### Security
- Upgrade Sprockets gem to avoid CVE-2018-3760 vulnerability (@mkasztelnik)

## 0.9.0

### Added
- Added AVD/MVD ratio to patients' statistics (@Nuanda)
- Profile link for left avatar picture and user name (@mkasztelnik)
- Colors for patient tile connected with last pipeline status (@mkasztelnik)
- Instruction how to remove concrete IP from rack-attack fail2ban list (@mkasztelnik)
- User cannot be removed or blocked when she/he owns exclusively group (@mkasztelnik)
- Button to minimize left menu is visible always (@mkasztelnik)
- Dedicated information about deleted pipeline owner (@mkasztelnik)

### Changed
- Reintegration of segmentation service using File Store in place of OwnCloud (@jmeizner)
- Remove `brakeman` from `Gemfile` and use latest version while executing
  `gitab-ci` checks (@mkasztelnik)
- Trigger segmentation start after whole input file is uploaded (@mkasztelnik)

### Deprecated

### Removed
- Remove `faker` gem and replace it with `factory_bot` sequences (@mkasztelnik)

### Fixed
- Patients' statistics work correctly when turbolink-loaded (@Nuanda)
- Fix `GITLAB_HOST` markup formatting in `README.md` (@mkasztelnik)

### Security

## 0.8.0

### Added
- Reload pipeline step status on patient view (@mkasztelnik)
- Reload segmentation status after it is started (@mkasztelnik)
- Proper handling for rimrock computation start failure (@mkasztelnik)
- Execution time updated each second for active computation (@mkasztelnik)
- Pipeline specific input (@mkasztelnik)
- Patient clinical details now includes patient's state (preop/postop) (@Nuanda)
- New statistics about the current state of EurValve's prospective cohort (@Nuanda)

### Changed
- Labels for pipelines list view improved (@mkasztelnik)
- Segmentation temp file is removed from local disc after it is transferred into
  segmentation Philips service (@mkasztelnik)
- Use stages instead of types in Gitlab CI yml (@mkasztelnik)
- Upgrade to rubocop 0.51.0 (@mkasztelnik)
- Use addressable gem to parse URLs (@mkasztelnik)
- Upgraded rails into 5.1.4 and other gems into latest supported versions (@mkasztelnik)
- Change `factory_girl` into `factory_bot` (@mkasztelnik)
- Use preconfigured docker image for builds (@mkasztelnik)
- Extracted DataSets::Client from Patients::Details for reusability (@Nuanda)
- Lock redis version into 3.x (@mkasztelnik)
- New patient case widget to reflect new developments in pipelining (@Nuanda)
- Flow model class which stores information about pipeline flow steps (@mkasztelnik)
- Switch from PhantomJS into Chrome headless (@mkasztelnik)
- Add escaping in the documentation pdp curl example (@mkasztelnik)
- Unique while fetching resources in pdp (@mkasztelnik)
- Change comparison `show` method to `index` (@mkasztelnik)
- Pipeline steps definition refactored and generalized (@mkasztelnik)
- Change defaults for data sets (@mkasztelnik)
- Change the default root path to patients index (@Nuanda)
- Renamed `not_used_flow` into `unused_steps` (@mkasztelnik)

### Deprecated

### Removed

### Fixed
- Remove n+1 query when updating computation status (@mkasztelnik)
- Sidebar's hamburger button is operational properly toggling the left menu (@dharezlak)
- Fix patient web socket unsubscribe (@mkasztelnik)
- Patient and pipeline creation silent failures (@jmeizner)

### Security

## 0.7.0

### Added
- Show started rimrock computation source link (@mkasztelnik)
- Parameter extraction pipeline step (@amber7b)
- Automatic and manual pipeline execution mode (@mkasztelnik)
- Pipeline flows (pipeline with different steps) (@jmeizner)
- Configure redis based cache (@mkasztelnik)
- Add cache for repositories tags and versions (@mkasztelnik)
- Manual gitlab-ci push master to production step (@mkasztelnik)
- Patient details are fetched from the external data set service and shown in the patient page (@dharezlak)
- Possibility to configure automatic pipeline steps during pipeline creation (@mkasztelnik)
- Wrench automatic pipeline step icon when configuration is needed (@mkasztelnik)
- Add extra pipeline steps for CFD, ROM, 0D, PV visualization and uncertainty analysis (@amber7b)
- Computation update interval can be configured using ENV variable (@mkasztelnik)
- Add loading indicator when reloading current pipeline step (@mkasztelnik)
- Show manual pipeline steps during pipeline creation (@mkasztelnik)
- External data set service is called to fetch patient's inferred details (@dharezlak)
- Additional mocked pipelines and pipelines steps (@mkasztelnik)
- Show pipeline details (flow and owner) (@Nuanda)
- Design new pipeline disabled button (@mkasztelnik)
- Links to 4 EurValve datasets query interfaces (@mkasztelnik)
- Add possibility to configure data sets site path though ENV variable (@mkasztelnik)
- Add link to segmentation status output directory (@mkasztelnik)
- Show computation error message (@mkasztelnik)
- Gitlab endpoint can be configured using ENV variable (@mkasztelnik)
- Gitlab clone url can be configured though ENV variable (@mkasztelnik)
- Add `clone_repo(repo)` script generator helper (@mkasztelnik)

### Changed
- Segmentation run mode can be configured using yaml or ENV variable (@mkasztelnik)
- Default segmentation run mode changed into 3 (@mkasztelnik)
- Patient.case_number now used as patient ID in HTTP requests (@amber7b)
- Computation update interval changed into 30 seconds (@mkasztelnik)
- Load patient details only when needed (@mkasztelnik)
- Patient's case number is now easily available in the script generator (@dharezlak)
- Fetch patient details timeout set to 2 seconds (@mkasztelnik)
- Patient details loaded using ajax (@mkasztelnik)
- Don't show run segmentation button when segmentation is active (@mkasztelnik)
- Don't show blank option for pipeline mode (@mkasztelnik)
- Patient age inferred value expressions changed to conform with values coming from real data sets (@dharezlak)
- File browsers embedded in the pipeline views sort contents by date descendingly (@dharezlak)

### Deprecated

### Removed

### Fixed
- Output from one pipeline is not taken as different pipeline input (@mkasztelnik)
- Change step status after segmentation is submitted (@mkasztelnik)
- Error when deleting a pipeline which has data files (@jmeizner)
- Set segmentation status to failure when zip cannot be unzipped (@jmeizner)
- Don't create webdav structure when pipeline cannot be created (@mkasztelnik)
- Show error details when pipeline cannot be created (@mkasztelnik)
- Fix proxy expired email title (@mkasztelnik)
- JSON query requesting inferred patient details updated to comply with data set service's new API (@dharezlak)
- Don't show run button when manual pipeline and proxy is not valid (@mkasztelnik)
- Update computation status after computation is started (@mkasztelnik)
- Extract computations_helper GitLab host name to an env variable (@Nuanda)

### Security

## 0.6.1

## Fixed
- Fix segmentation status update after WebDav computation finished (@mkasztelnik)

## 0.6.0

### Added
- rack-attack bans are logged to `log/rack-attack.log` (@mkasztelnik)
- Show user email in admin users index view (@mkasztelnik)
- Pipeline step script generation uses ERB templates (@mkasztelnik)
- Blood flow computation is self-contained - Ansys files are downloaded from git
  repository (@mkasztelnik)
- Gitlab integration services (list branches/tags and download specific file) (@amber7b)
- Comparison of image files in pipeline comparison view (@amber7b)
- Fetch computation slurm start script from Gitlab (@mkasztelnik)
- Pipeline comparison view uses OFF viewers to show 3D mesh differences (@dharezlak)
- Enabled selection of rimrock computation version (@jmeizner, @mkasztelnik)
- Brakeman security errors check is executed by Gitlab CI (@mkasztelnik)
- Data sets API reference added to the Help section as a separate entry (@dharezlak)
- Use action cable (web sockets) to refresh computation (@mkasztelnik)
- Computation stores information about selected tag/branch and revision (@mkasztelnik)
- Pipelines comparison shows sources diff link to GitLab (@Nuanda)

### Changed
- Upgrade to ruby 2.4.1 (@mkasztelnik)
- Upgrade dependencies (@mkasztelnik)
- Upgrade to rails 5.1.2 (@mkasztelnik)
- Update rubocop to 0.49.1 (@mkasztelnik)
- Move `Webdav::Client` into `app/models` to avoid auto loading problems (@mkasztelnik)
- OFF viewer's height in pipeline's compare mode takes half of the available width (@dharezlak)
- Patient case_number is checked for unsafe characters (@Nuanda)

### Deprecated

### Removed

### Fixed
- Patient left menu focus when showing patient pipeline computation (@mkasztelnik)
- Avoid n+1 queries in patient view (@mkasztelnik)
- Disable turbolinks in links to cloud view (turbolinks does not work well with GWT) (@mkasztelnik)
- Fix random failing test connected with html escaping user name in generated emails (@mkasztelnik)
- Fix content type mismatch for file stage out (@mkasztelnik)
- Turn on `files` integration tests (@mkasztelnik)
- Fix missing tooltip messages for queued computation state (@mkasztelnik)
- Preventing WebDAV folder creation for patients with incorrect case_number (@Nuanda)

### Security

## 0.5.0

### Added
- Pipelines have own DataFiles which represent produced results (@Nuanda)
- Pipelines comparison view which present differences between files of two Pipelines (@Nuanda)
- Segmentation output is unzipped into pipeline directory (@amber7b, @mkasztelnik)
- Store in FileStore heart model computation PNG results (@mkasztelnik).
- Integration tests (tag "files") are run by GitlabCI (@mkasztelnik)

### Changed
- File browser template for multiple embed mode created (@dharezlak)
- WebDAV synchronisation takes care for pipeline-related and patient input files (@Nuanda)
- Computations are executed in the pipeline scope (@mkasztelnik)
- Move FileStore configuration into one place (@mkasztelnik)
- Make patient `case_number` factory field unique (@mkasztelnik)
- Redirect user back to previous page after proxy is regenerated successfully (@mkasztelnik)
- Prefix is removed from segmentation outputs (@mkasztelnik)
- Show compare two pipelines button only when there is more than on pipeline (@mkasztelnik)

### Deprecated

### Removed
- DataFile#handle removed since it is not going to be used anymore (@Nuanda)

### Fixed
- Policy management API handles paths with escaped characters well and limits path scope to a single service (@dharezlak)
- Move and copy policy API calls handle well resources with escaped characters (@dharezlak)
- Copy and move destinations for policy management API treated as pretty paths for proper processing (@dharezlak)
- JS resources required for the OFF viewer are loaded in the file browser direct embed mode (@dharezlak)
- Resource pretty path decodes and encodes values according to URI restrictions (@dharezlak)
- Local path exclusion validation query fixed (@ddharezlak)
- Proxy warning is shown only for active Rimrock computations (@mkasztelnik)
- Correct computation tooltip text on pipelines list (@mkasztelnik)
- When removing policies via API access method existence check is scoped to a given service (@dharezlak)
- Set Rimrock computation job id to nil while restarting computation (@mkasztelnik)
- Show missing patient outputs on pipeline diff view (@mkasztelnik)
- Path processing fixed for policy move/copy operations invoked via API (@dharezlak)
- Set correct order for pipelines computations (@mkasztelnik)

### Security

## 0.4.4

### Changed
- JWT token parameter name changed to access_token for the data sets subpage request URL (@dharezlak)

## 0.4.3

### Fixed
- JWT token passed as a URL query parameter for the data sets subpage (@dharezlak)

## 0.4.2

### Changed
- JWT token structure description updated (information about `sub` record)
  in documentation (@mkasztelnik)

## 0.4.1

### Changed
- `sub` changed from integer into string (which is required by specification) (@mkasztelnik)

## 0.4.0

### Added
- Basic rack-attack configuration (@mkasztelnik)
- Patient pipelines (@mkasztelnik)
- Patient/Pipeline file store structure is created while creating/destroying
  patient/pipeline (@mkasztelnik)
- Segmentation patient case pipeline step (@tbartynski)
- User id was added into JWT token using `sub` key (@mkasztelnik)

### Changed
- Update rubocop into 0.47.1, fix new discovered offenses (@mkasztelnik)
- JWT token expiration time extended to 6 hours (@mkasztelnik)
- Change zeroclipboard into clipboard.js because support for flash is dropped (@mkasztelnik)
- Factories fields which should be unique use unique Faker methods (@mkasztelnik)
- Simplify Webdav operations for FileStore and OwnCloud (@mkasztelnik)

### Deprecated

### Removed
- PLGrid left menu removed since we are not showing any item there (@mkasztelnik)
- PLGrid patient data synchronizer removed. FileStore is the only supported backend (@mkasztelnik)

### Fixed
- Left menu can be scrolled when high is small (@mkasztelnik)
- Policy API filters policies according to the service identified by the passed id (@dharezlak)
- A 404 error code is returned instead of the 500 code when copying/moving policy
  for a non-existent source policy (@dharezlak)
- All user groups assignments are removed while user is deleted from the system (@mkasztelnik)

### Security

## 0.3.4

### Changed
- Default Patient Case File Synchronizer changed into WebDav (@mkasztelnik)

## 0.3.3

### Fixed
- Data sets page url can be overwritten with an environment property (@dharezlak)


## 0.3.2

### Fixed

- Fixed pushing tag into production from different branch than master (@mkasztelnik)


## 0.3.1

### Fixed

- Policy API filters policies according to the service identified by the passed id (@dharezlak)


## 0.3.0

### Added
- PLGrid proxy details shown in the profile view, warning shown when proxy is
  outdated while active computations are present (@mkasztelnik)
- Support for running specs with JS support (@mkasztelnik)
- When a computation finishes the patient view is automatically reloaded in order
  to show the user the latest files produced by the computation (@Nuanda)
- OD Heart model is now incorporated in the patient case pipeline (@Nuanda)
- Show alert when unable to update patient files or run computations
  because PLGrid proxy is outdated (@mkasztelnik)
- User with active computations is notified (via email) while proxy expired (@mkasztelnik)
- Users management view redesigned, added possibility to remove user by admin (@mkasztelnik)
- Set plgrid login in OpenId request while regenerating proxy certificate (@mkasztelnik)
- Long living JWT tokens can be generated using internal API (@mkasztelnik)
- Resource paths support wildcard characters through UI and API (@dharezlak)
- User can download patient case computation stdout and stderr (@mkasztelnik)
- Data sets view from an external server was integrated as an iframe (@dharezlak)

### Changed
- Make jwt pem path configurable though system variable (@mkasztelnik)
- Externalize JWT token generation from user into separate class (@mkasztelnik)
- Make PDP URI and access method case insensitive (@mkasztelnik)
- Improve service URL form placeholder (@mkasztelnik)
- Externalize PLGrid grant id into configuration file (@mkasztelnik)
- Rename `User.with_active_computations` into `User.with_submitted_computations` (@mkasztelnik)
- Corrected SMTP config to include Auth support (@jmeizner)
- Updated PDP and Services documentation (@jmeizner)
- Update rails into 5.0.2 and other dependencies (@mkasztelnik)
- Make Computation a base class for more specialized classes (@tomek.bartynski)
- Introduced WebdavComputation and RimrockComputation that inherit from Computation class (@tomek.bartynski)
- Patient Case pipeline is now hardcoded in Patient model (@tomek.bartynski)
- Implemented classes that run Blood Flow Simulation and Heart Model Computation pipeline steps (@tomek.bartynski)

### Deprecated

### Removed

### Fixed
- Correct default pundit permission denied message is returned when no custom message is defined (@mkasztelnik)
- Missing toastr Javascript map file added (@mkasztelnik)
- Show add group member and group management help only to group group owner (@mkasztelnik)
- Unify cloud resources view with other views (surrounding white box added) (@mkasztelnik)
- Fix path parsing when alias service name is used in PDP request (@mkasztelnik)
- PLGrid profile view visible only for connected accounts (@mkasztelnik)
- PDP - wildcard at the beginning and end of resource path should not be default (@mkasztelnik)

### Security


## 0.2.0

### Added
- Application version and revision in layout footer (@mkasztelnik)
- Pundit authorized error messages for groups and services (@mkasztelnik)
- Notifications are using the JS toastr library for fancier popups (@dharezlak)
- The file store component uses portal's notification system to report errors (@dharezlak)
- Service owner can manage local policies through UI (@mkasztelnik)
- Unique user name composed with full name and email (@mkasztelnik)
- Embed atmosphere UI into cloud resources section (@nowakowski)

### Changed
- Redirect status set to 302 instead of 404 (when record not found), 401 (when
  user does not have permission to perform action) to avoid ugly "You are being
  redirected" page (@mkasztelnik)
- PDP denies everything when user is not approved (@mkasztelnik)
- Add/remove group members redesigned (@mkasztelnik)
- Update rubocop and remove new offenses (@mkasztelnik)
- Update project dependencies (@mkasztelnik)
- Update rubocop to 0.46.0, remove new discovered offences (@mkasztelnik)
- Update to rails 5.0.1 (@mkasztelnik)

### Deprecated

### Removed

### Fixed
- Service factory that used to randomly produce invalid objects (@tomek.bartynski)
- Edit/destroy group buttons visible only for group owners (@mkasztelnik)
- Administration side menu item displayed only if it is not empty (@tomek.bartynski)
- Corresponding resource entities are removed when policy API called with
  only a `path` param (@dharezlak)

### Security


## 0.1.0

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
- Additional attribute with policy proxy URL is passed to the file store browser (@dharezlak)
- Provide help panels for resource actions (@nowakowski)
- Hint regarding resource paths in global policies tab (@tomek.bartynski)
- Support path component in service uri (@tomek.bartynski)

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
- Go to new user session path after logout (@mkasztelnik)
- Got to new user session path after logout (@mkasztelnik)
- Added a spec checking for correct removal of only policies specified by the API request parameter (@dharezlak)
- File store view uses a common layout (@dharezlak)
- Service uri must not end with a slash (@tomek.bartynski)
- Resource path must start with a slash (@tomek.bartynski)
- Removed path unification in Resource model (@tomek.bartynski)
- Update to sidekiq 4.2.2 and remove unused anymore sinatra dependency (@mkasztelnik)
- Administrator is able to see all registered services (@mkasztelnik)
- Fixed path field in a form for Resource (@tomek.bartynski)

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
- Fix n+1 queries problems in service and group sections (@mkasztelnik)
- Check service policy only once on global policies view (@mkasztelnik)
- More advance validation for service `uri` overridden (@jmeizner)
- Policy management API documentation corrected (@dharezlak)
- Fix duplicates and missing part of `Service#show` (@jmeizner)
- Policy API uses a service reference when querying for access methods (@dharezlak)

### Security
