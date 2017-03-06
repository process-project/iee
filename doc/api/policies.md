# Policy management API

Access to the policy management API is authorized by delegating user
credentials (using Bearer Authorization header) and providing a service token
via the `X-SERVICE-TOKEN` header with each of the requests. The path attibute
can contain a wildcard character at the end (and **only there**) to match any path part
(e.g. http://host.com/path/*).
The API exposes the following REST methods:

## `GET /api/policies[?path=...]`

`path`: A coma-separated list of paths or a single path.

Returns a list of policies for a given path (or paths). The matching of paths is exact without
any regular expression processing.

Response body:

```
{
  "policies": [
    {
      "path": "...",
      "managers": {
        "users": ["..."],
        "groups": ["..."]
      },
      "permissions": [
        {
          "type": "user_permission|group_permission",
          "entity_name": "...",
          "access_methods": ["..."]
        }
      ]
    }
  ]
}
```

Example using cURL:

```
curl -H "X-SERVICE-TOKEN: {service_token}" -H "Authorization: Bearer {user_token}" ${root_url}api/policies?path=/path
```

## `POST /api/policies`

Creates or merges the given policy.

Request body:

```
{
  "path": "...",
  "managers": {
    "users": ["..."],
    "groups": ["..."]
  },
  "permissions": [
    {
      "type": "user_permission|group_permission",
      "entity_name": "...",
      "access_methods": ["..."]
    }
  ]
}
```

Response contains the resulting status code of a method call. After a successful creation
a `201` status is returned. When the given policy is merged with an existing one a `200` status is
returned. If the body is invalid or given user or methods do not exist a `400`
status is returned instead.

Example using cURL:

```
curl -X POST --data '{ "path": "/a/path", "permissions": [ { "type": "user_permission", "entity_name": "user@host.com", "access_methods": [ "get", "post" ] } ] }' -H "Content-Type: application/json" -H "X-SERVICE-TOKEN: {service_token}" -H "Authorization: Bearer {user_token}" ${root_url}api/policies
```

## `DELETE /api/policies?path=...[&user=...|group=...[&access_method=...]]`

Deletes policies identified by given parameters. Values used for individual parameters can be
obtained by using the `/api/policy_entities` method.

`path`: A coma-separated list of paths.

`user`: A coma-separated list of user emails.

`group`: A coma-separated list of group names.

`access_method`: A coma-separated list of access method names.

If corresponding policies are found and deleted `204` status is
returned. In case the resources for given parameters cannot be found a `400` status is returned.

Example using cURL:

```
curl -X DELETE -H "X-SERVICE-TOKEN: {service_token}" -H "Authorization: Bearer {user_token}" ${root_url}api/policies?path=/helloPath
```

## `GET /api/policy_entities`

Returns a list of policy entities which can be used to define new policies and delete existing ones.

Response body:

```
{
  "policy_entities": [
    {
      "type": "user_entity|group_entity|access_method_entity",
      "name": "..."
    }
  ]
}
```

Example using cURL:

```
curl -H "X-SERVICE-TOKEN: {service_token}" -H "Authorization: Bearer {user_token}" ${root_url}api/policy_entities
```
