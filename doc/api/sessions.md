# Create JSON Web Token (JWT)

JWT is used to authorize user in REST API. To generate new token use:

```
POST /api/sessions
```

Parameters:

```json
{ "user": { "email": "foo@bar", "password": "secretsecret" } }
```

When credentials are valid JWT token will be returned with basic information
about the user:

```json
{ "user": { "sub": "123", "name": "John Doe", "email": "foo@bar", "token": "eyJ0eXAiOiJ..." } }
```

`sub` record is unique and cannot be changed for concrete user.

## JSON Web Token validation

If you want to validate JWT you can use one of the libraries presented on
http://jwt.io webpage. We are using ${jwt_key_algorithm} algorithm and following
public key:

```
${jwt_public_key}
```
