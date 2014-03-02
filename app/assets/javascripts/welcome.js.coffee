Dropzone.autoDiscover = false

jQuery ($) ->

  dom = $('#dropzone').get(0)
  progressBar = $('.progress').hide()

  options = {
    previewsContainer:  "#previews"
    autoProcessQueue:   false
    maxFiles:           5000
    url:                "/shares"
    clickable:          "#dropzone"
  }

  myDropzone = new Dropzone( document.body, options )

  _.extend myDropzone,

    failures: []

    processDrop: (items) ->
      @startTime  = new Date
      @singleFile = @isSingleFileDropped(items)

      if @singleFile
        setTimeout ()=>
          @processQueue()
        , 5
      else
        @processing = true
        @uploadMultipleFiles()

      @disable()
      progressBar.show()

    isSingleFileDropped: (items)->
      items.length == 1 && items[0].webkitGetAsEntry().isFile

    uploadMultipleFiles: ()->
      $.ajax
        url:      'shares'
        dataType: 'json'
        type:     'POST'

      .success (data) =>
        if data.success
          @failures = []
          @key = data.id
          @options.url = "/shares/#{@key}/append"
          @processQueue()
        else
          console.log 'Fail creating share!'
      .fail () ->
        console.log 'Fail creating share!'

    onSuccess: ()->
      progressBar.addClass('successful')
      msg = $('#success-message')
      msg.show()
      $('.total-files-count', msg).text( @files.length )

      duration = ((new Date) - @startTime)/1000.0
      $('.duration', msg).text( duration )

      url = [
        location.origin
        "/shares/"
        @key
        ".html"
      ].join ""

      $('#view-url').attr('href', url).text( url )

    allSuccessful: () ->
      _.isEmpty( @getQueuedFiles() ) &&
      _.isEmpty( @getUploadingFiles() ) &&
      _.isEmpty( @failures )

  (()->

    @on "complete", (file) ->
      @failures.push( file ) unless file.status == "success"
      @processQueue()

    @on "success", (file) ->
      id = JSON.parse( file.xhr.response ).id
      @key = id if id
      @onSuccess() if @allSuccessful()

    @on "dragover", () ->
      $(dom).addClass 'inverted'

    @on "dragleave", () ->
      $(dom).removeClass 'inverted'

    @on "totaluploadprogress", (per) ->
      $('.bar', progressBar).css width: "#{per}%"

    @on "sending", (file, xhr, formData) ->
      formData.append "path", file.fullPath

    @on "addedfile", (evt) ->
      $(dom)
        .removeClass( 'inverted' )
        .addClass( 'working' )

      $('.dz-message', dom).hide()
      unless @processing
        setTimeout ()=>
          @processQueue()
        ,5

    @on "drop", (evt) ->
      @processDrop( evt.dataTransfer.items )

    ).call myDropzone
