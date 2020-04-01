# Pipelines API

## `GET /api/projects`

Get a list of projects

Response body:

```json
{
    “project_ids”: ["UC2", "UC1"]
}

```

## `GET /api/projects/:project_id/pipelines`

Get a list of pipelines for a given :project_id

Response body:

```json
{
    “pipeline_ids”: ["LOFAR_pipeline", "LOFAR_preparation"]
}

```

## `GET /api/projects/:project_id/pipelines/:pipeline_id/computations`

Get list of pipeline steps' parameters and their possible values for a given :project_id and :pipeline_id

Response body:

```json
{
  "step1":{
     "Container name":{
        "label":"container_name",
        "name":"Container name",
        "description":"Name of your container",
        "rank": 0,
        "datatype":"multi",
        "default":"some_container_name",
        "values":[ "some_container_name" ]
     },
     "Container tag":{
        "label":"container_tag",
        "name":"Container tag",
        "description":"Tag of the container used on registry",
        "rank": 0,
        "datatype":"multi",
        "default":"latest",
        "values":[ "latest" ]
     },
     ...
  },
  "step2":{
    ...
  },
  ...
}

```


## `POST /api/projects/:project_id/pipelines/:pipeline_id/computations`

Launch a :pipeline_id in :project_id with appropriate parameters' values for each step.

Request body:

```json
{
    "steps": [
        {
            "step_name": "S1",
             "parameters": {"key1": "value", "key2":"value"}
        },
        {
            "step_name": "S2",
             "parameters": {"key1": "value1", "key2":"value2"}
        }
    ]
}

```

Response: OK with :id of the computation


## `GET /api/projects/:project_id/pipelines/:pipeline_id/computations/:id`

Get status of each step's for a given :project_id, :pipeline_id and :id of the computation

Response body:

```json
{
    "S1": "status",
    "S2" : "status"
}

```
