 $(document).on "turbolinks:load", ->
  pipeline = document.getElementById("pipelines")

  if pipeline
    App.patient = App.cable.subscriptions.create {
        channel: "PatientChannel",
        patient: pipeline.dataset.patient,
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

  else if App.patient
    App.patient.unsubscribe
    App.patient = null
