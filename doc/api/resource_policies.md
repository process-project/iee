# Resource policy management API

Access to the resource policy management API is authorized by providing a service token
via the `X-SERVICE-TOKEN` header with each of the requests. The API exposes the following
REST methods:  

## `POST /api/resource_policy`

Request body:

```
{ "resource_path": "/a/path", "user": "user@host.com", "access_methods": [ "get", "post" ]}
```

Response contains the resulting status code of a method call. After a successful creation
a `201` status is returned. If the body is invalid or given user or methods do not exist a `400`
status is returned instead.

Example using cURL:

```
curl -X POST --data '{ "resource_path": "/a/path", "user": "user@host.com", "access_methods": [ "get", "post" ]}' -H "Content-Type: application/json" -H "X-SERVICE-TOKEN: {service_token}" https://valve.cyfronet.pl/api/resource_policy
```

## `GET /api/resource_policy_entities`

Response body:

```
{ "users": [ "user@host.com", "another@domain.com" ], "groups": [ "group1", "group2" ], "methods": [ "get", "post" ] }
```

Example using cURL:

```
curl -H "X-SERVICE-TOKEN: {service_token}" https://valve.cyfronet.pl/api/resource_policy_entities
```