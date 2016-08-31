# Policy management API

Access to the policy management API is authorized by delegating user
credentials (using Bearer Authorization header) and providing a service token
via the `X-SERVICE-TOKEN` header with each of the requests. The API exposes the
following REST methods:

## `GET /api/policies[?path=...]`

`path`: A coma-separated list of paths or a single path.

Returns a list of policies for a given path (or paths). The matching of paths is exact without
any regular expression processing.

Response body:

```json
{
  policies: [
    {
      path: "...",
      managers: {
        users: ["..."],
        groups: ["..."]
      },
      permissions: [
        type: "user_permission|group_permission",
        entity_name: "...",
        access_methods: ["..."]
      ]
    }
  ]
}
```

## `POST /api/policies`

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

## `DELETE /api/resource_policy?resource_path={path}`

If a corresponding resource policies (and the resource itself) are found and deleted `204` status is
returned. In case the resource cannot be found `404` status is returned.

Example using cURL:

```
curl -X DELETE -H "X-SERVICE-TOKEN: {service_token}" https://valve.cyfronet.pl/api/resource_policy?resource_path=/helloPath
```
