 $(document).on "turbolinks:load", ->
  pipeline = document.getElementById("pipeline")

  if pipeline
    App.pipeline = App.cable.subscriptions.create {
        channel: "PipelineChannel",
        patient: pipeline.dataset.patient,
        pipeline: pipeline.dataset.pipeline,
        computation: pipeline.dataset.computation
      },
      received: (data) ->
        if data.reload_step
          @reloadStep()
        else
          @reloadMenu(data.menu)

        if data.reload_files
          @reloadOutputs()

      reloadStep: ->
        $.ajax
          method: 'get'
          url: window.location.href
          cache: false
          success: (response) ->
            document.getElementById("pipeline").outerHTML = response

      reloadMenu: (menu) ->
        document.getElementById("computations").outerHTML = menu

      reloadOutputs: ->
        eurvalve.filestore.Embed.refreshFileBrowser("patient-outputs")

  else if App.pipeline
    App.pipeline.unsubscribe
    App.pipeline = null
