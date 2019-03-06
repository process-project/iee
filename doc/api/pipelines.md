# Pipelines API

In order to perform any kind of computation on the EurValve infrastructure
one needs to create suitable pipelines. Pipelines constitute series of
computations, of various kinds, executed one after another in order
to deliver a specific output. Thus, pipelines are constructed from
computations (also known as "steps"), and computations could be of many
different kinds. However, no matter the type (or "flow") of pipeline, they
are managed in a similar way.

Access to the pipeline management API is authorized by delegating user
credentials (using the Bearer Authorization header). The tokens in examples
below were generated for your personal use. Please do not share them in
any way. If the server responds with a timeout error, please refresh this
page to receive a new token. You can also download your security
(JSON web) token from your profile page: ${profile_url}.

The API exposes the following REST methods:

## `POST /api/patients/:case_number/pipelines`

Creates a new pipeline for patient identified with **case_number**. You are
able to set *name* and *flow* for the new pipeline, as shown below.

Request body:

```json
{
  "data": {
    "type": "pipeline",
    "attributes": { "name": "new-pipeline", "flow": "avr_from_scan_rom" }
  }
}
```

The *flow* attribute is crucial as it determines what type of pipeline is
going to be executed for this patient. The following pipeline types are
currently available:

${flows}

Response body:


```json
{ 
  "data": {
    "id": "3",
    "type": "pipeline",
    "attributes": { 
      "iid": 3,
      "name": "new-pipeline",
      "flow": "avr_from_scan_rom",
      "inputs_dir": "development/patients/new-case-number/pipelines/3/inputs/",
      "outputs_dir": "development/patients/new-case-number/pipelines/3/outputs/"
    },
    "relationships": {
      "computations": {
        "data": [
          { "id":"8", "type": "computation" },
          { "id":"7", "type": "computation" }
        ]
      }
    }
  },
  "included": [
    { 
      "id": "8", 
      "type": "computation", 
      "attributes": { 
        "status": "created",
        "error_message": null,
        "exit_code": null,
        "pipeline_step": "blood_flow_simulation",
        "revision": null,
        "tag_or_branch": "master",
        "required_files": ["fluid_virtual_model", "ventricle_virtual_model"]
      }
    },
    {
      "id": "7",
      "type": "computation",
      "attributes": {
        "status": "created",
        "error_message": null,
        "exit_code": null,
        "pipeline_step": "heart_model_calculation",
        "revision": null,
        "tag_or_branch":"master", 
        "required_files": ["estimated_parameters"]
      }
    }
  ]
}
```

Example using cURL:

```
curl -X POST --data '{ "data": { "type": "pipeline", "attributes": { "name": "new-pipeline", "flow": "avr_from_scan_rom" } } }' -H "Content-Type: application/json" -H "Authorization: Bearer ${user_token}" ${root_url}api/patients/case-number-1/pipelines
```

You can see more `computation` elements in your case - their number
depends on the type (or `flow`) of the created pipeline.

Notable data includes:

- `iid`: pipeline identifier in the scope of this patient,
useful at a later stage
- `inputs_dir`: where input files should be uploaded (using the WebDAV 
protocol)
- `outputs_dir`: where output files can be downloaded from (using 
the WebDAV protocol)
- `computation.status`: should be set to `created` for all 
computations
- `computation.pipeline_step`: the type of computation being 
executed
- `computation.required_files`: an array of input files you need to 
provide in order to be able to execute this computation. If empty,
the computation can be executed straight away with no input data.

The computation execution mechanism recognizes suitable input files
through regular expression patterns. Patterns which correspond to
the values found in the `computation.required_files` array are as follows:

```
${required_files}
```

By default, computations which require input files will wait for you (or
another user/service) to upload them to the `inputs_dir` WebDAV folder.
However, please note that earlier computations in a given pipeline may
create, as their outputs, files which will become inputs for computations
executed during later steps, as specified by the flow of your pipeline.

Please consult ${webdav_docs_url} for documentation on how to use the WebDAV
protocol to place files inside the inputs dir.

## `GET /api/patients/:case_number/pipelines`

Returns a list of all pipelines for a given patient.

Response body:

```json
{
  "data": [
    {
      "id": "3",
      "type": "pipeline",
      "attributes": { "iid": 3, "name": "new-pipeline", "flow": "avr_from_scan_rom" }
    },
    {
      "id": "2",
      "type": "pipeline",
      "attributes": { "iid": 2, "name": "auto1", "flow": "unused_steps" }
    }
  ]
}
```

Example using cURL:

```
curl -H "Authorization: Bearer ${user_token}" ${root_url}api/patients/case-number-1/pipelines
```

## `GET /api/patients/:case_number/pipelines/:iid`

Returns detailed information about the pipeline identified by **iid**.
Use this operation to monitor the progress of a pipeline. The following
JSON document is returned for the pipeline in question.

The response body looks exactly like the one returned when a new pipeline
is created. This time we will make note of the following attributes:

- `computation.status`: depending on the progress on a given computation,
it could be one of `${computation_statuses}`
- `computation.error_message`: can provide useful diagnostic information
if something goes wrong during execution
- `computation.exit_code`: for computations executed on a supercomputer
the exit code of the executed script may be available.

If the computation status equals `finished`, output files (if any)
can be found in `outputs_dir` and downloaded with the WebDAV protocol
(see ${webdav_docs_url}). If the status is `error` then the remaining
attributes may provide some hints about what has happened.

Example using cURL:

```
curl -H "Authorization: Bearer ${user_token}" ${root_url}api/patients/case-number-1/pipelines/2
```

## `DELETE /api/patients/:case_number/pipelines/:iid`

Destroy the pipeline identified by **iid**.

Example using cURL:

```
curl -H "Authorization: Bearer ${user_token}" -X DELETE ${root_url}api/patients/case-number-1/pipelines/2
```
