 $(document).on "turbolinks:load", ->
  pipeline = document.getElementById("pipeline")

  if pipeline
    App.pipeline = App.cable.subscriptions.create {
        channel: "PipelineChannel",
        patient: pipeline.dataset.patient,
        pipeline: pipeline.dataset.pipeline,
        computation: pipeline.dataset.computation
      },
      connected: ->
        console.info("pipeline web socket connected")

      received: (data) ->
        console.log("reloading whole step")
        if data.reload_step
          $.ajax
            method: 'get'
            url: window.location.href
            cache: false
            success: (response) ->
              document.getElementById("pipeline").outerHTML = response
        else
          console.log("replacing menu %o", data)
          document.getElementById("computations").outerHTML = data.menu

        if data.reload_files
          console.log("reloading output files")
          eurvalve.filestore.Embed.refreshFileBrowser("patient-outputs")
  else if App.pipeline
    App.pipeline.unsubscribe
    App.pipeline = null
