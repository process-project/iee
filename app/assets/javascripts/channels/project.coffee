 $(document).on "turbolinks:load", ->
  pipeline = document.getElementById("pipelines")

  if pipeline
    App.project = App.cable.subscriptions.create {
        channel: "ProjectChannel",
        project: pipeline.dataset.project,
        pipeline: pipeline.dataset.pipeline,
        computation: pipeline.dataset.computation
      },
      connected: ->
        console.log("ws connected")

      received: (data) ->
        if data.list
          @reloadPipelines(data.list)

      reloadPipelines: (list) ->
        document.getElementById("pipelines").outerHTML = list

  else if App.project
    App.project.unsubscribe
    App.project = null
