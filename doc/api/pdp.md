# Policy Decision Point (PDP)

Policy decision point gives simple answer to following question: does user have
permissions to invoke `action` on selected `resource`. Resource is identified by
unique `uri`, action is one of following: `get`, `post`, `put`, `delete`.

```
GET /api/pdp?uri={uri_path}&action={get|post|put|delete}
```

PDP is secured by [JWT](https://jwt.io). Which can be currently copied from
Profile page. Token should be sent in the **Authorization** header using the
**Bearer** schema. The content of the header should look like the following:

```
Authorization: Bearer <token>
```

## Response

If uses is able to perform selected action on given resource `200` response code
is returned, otherwise `403` is returned. If token is not valid or expired `401`
is returned.

## Example

```
curl -H "Authorization: Bearer <token>" https://valve.cyfronet.pl/api/pdp?uri=http://test&action=get
```
