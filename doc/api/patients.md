# Patients API

Access to the patients management API is authorized by delegating user
credentials (using Bearer Authorization header). You can download your
security (JSON web) token from your profile page in the EurValve Portal
(navigate through the upper right dropdown menu).

The API exposes the following REST methods:

## `GET /api/patients`

Returns a list of all registered patients with information about patient
pipelines.

Response body:

```json
{
  "data": [
    {
      "type": "patient",
      "id": "case-number-1",
      "attributes": { "case_number": "case-number-1" },
      "relationships": {
        "pipelines": {
          "data": [
            { "id": "1", "type": "pipeline" },
            { "id": "2", "type": "pipeline" }
          ]
        }
      }
    }
  ]
}
```

Example using cURL:

```
curl -H "Authorization: Bearer {user_token}" ${root_url}api/patients
```

## `GET /api/patients/:case_number`

Returns patient details with information about patient pipelines.

Response body:

```json
{
  "data": {
    "type": "patient",
    "id": "case-number-1",
    "attributes": { "case_number": "case-number-1" },
    "relationships": {
      "pipelines": {
        "data": [
          { "id": "1", "type": "pipeline" },
          { "id": "2", "type": "pipeline" }
        ]
      }
    }
  }
}
```

Example using cURL:

```
curl -H "Authorization: Bearer {user_token}" ${root_url}api/patients/case-number-1
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
    "attributes": { "case_number": "new-case-number" },
    "relationships": {
      "pipelines": {
        "data": []
      }
    }
  }
}
```

Example using cURL:

```
curl -X POST --data '{ "data": { "type": "patient", "attributes": { "case_number": "new-case-number" } } }' -H "Content-Type: application/json" -H "Authorization: Bearer {user_token}" ${root_url}api/patients
```

## `DELETE /api/patients/:case_number`

Destroy patient and all patient pipelines

Example using cURL:

```
curl -H "Authorization: Bearer {user_token}" -X DELETE ${root_url}api/patients/case-number-1
```
