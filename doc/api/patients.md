# Patients API

Access to the patients management API is authorized by delegating user
credentials (using Bearer Authorization header). The token in examples
below were generated for your personal use, please do not share them in
any way. If server responds with a timeout error, please refresh this
page to receive a new token. You can also download your security
(JSON web) token from your profile page: ${profile_url}.

The API exposes the following REST methods:

## `GET /api/patients`

Returns a list of all registered patients.

Response body:

```json
{
  "data": [
    {
      "type": "patient",
      "id": "case-number-1",
      "attributes": { "case_number": "case-number-1" }
    }
  ]
}
```

Example using cURL:

```
curl -H "Authorization: Bearer ${user_token}" ${root_url}api/patients
```

## `GET /api/patients/:case_number`

Returns patient details.

Response body:

```json
{
  "data": {
    "type": "patient",
    "id": "case-number-1",
    "attributes": { "case_number": "case-number-1" }
  }
}
```

Example using cURL:

```
curl -H "Authorization: Bearer ${user_token}" ${root_url}api/patients/case-number-1
```

## `POST /api/patients`

Create new patient

Request body:

```json
{
  "data": {
    "type": "patient",
    "attributes": { "case_number": "new-case-number" }
  }
}
```

Response body:


```json
{
  "data": {
    "type": "patient",
    "id": "new-case-number",
    "attributes": { "case_number": "new-case-number" }
  }
}
```

Example using cURL:

```
curl -X POST --data '{ "data": { "type": "patient", "attributes": { "case_number": "new-case-number" } } }' -H "Content-Type: application/json" -H "Authorization: Bearer ${user_token}" ${root_url}api/patients
```

## `DELETE /api/patients/:case_number`

Destroy patient and all pipelines created for this patient

Example using cURL:

```
curl -H "Authorization: Bearer ${user_token}" -X DELETE ${root_url}api/patients/case-number-1
```
