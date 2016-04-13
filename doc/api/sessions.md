# Create JSON Web Token (JWT)

JWT is used to authorize user in REST API. To generate new token use:

```
POST /api/sessions
```

Parameters:

```json
{ "user": { "email": "foo@bar", "password: "secretsecret" } }
```

When credentials are valid JWT token will be returned with basic information
about the user:

```json
{ "user": { "name": "John Doe", "email": "foo@bar", "token": "eyJ0eXAiOiJ..." } }
```
