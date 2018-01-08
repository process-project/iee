# Policy Decision Point (PDP)

Policy decision point gives simple answer to following question: does user have
permission to invoke a method on a given `resource`. Resource is identified by
a unique `uri`, method is one of the following: `get`, `post`, `put`, `delete`, etc.

```
GET /api/pdp?uri={uri_path}&access_method={get|post|put|delete}
```

PDP is secured by [JWT](https://jwt.io). Which can be currently copied from
Profile page. Token should be sent in the **Authorization** header using the
**Bearer** schema. The content of the header should look like the following:

```
Authorization: Bearer <token>
```

## Response

If user is able to perform selected method on a given resource a `200` response code
is returned, otherwise `403` is returned. If token is not valid or expired `401`
is returned.

## Example

```
curl -H "Authorization: Bearer <token>" ${root_url}api/pdp?uri=http://test\&access_method=get
```
