Dropzone.autoDiscover = false

jQuery ($) ->

  dom = $('#dropzone').get(0)
  progressBar = $('.progress').hide()

  options = {
    previewsContainer: "#previews"
    autoProcessQueue:   false
    maxFiles:           5000

    init: ->
      @on "complete", (file) ->
        if file.status != "success"
          @failures.push file

        if @allSuccessful()
          onSuccess()
        
        @processQueue()


      @on "addedfile", (file) ->
        console.log "added file", file

      @on "dragover", () ->
        $(dom).addClass 'inverted'

      @on "dragleave", () ->
        $(dom).removeClass 'inverted'

      @on "totaluploadprogress", (per) ->
        console.log per
        $('.bar', progressBar).css width: "#{per}%"

      @on "sending", (file, xhr, formData) ->
        console.log xhr
        formData.append "path", file.fullPath

      @on "drop", () ->
        $(dom)
          .removeClass( 'inverted' )
          .addClass( 'working' )

        $('.dz-message', dom).hide()

        $.ajax
          url:      'shares'
          dataType: 'json'
          type:     'POST'

        .success (data) =>
          if data.success
            progressBar.show()
            @failures = []
            @startTime = new Date
            @key = data.id
            @options.url = "/shares/#{@key}/append"
            @processQueue()
          else
            console.log 'Fail creating share!'

        .fail () ->
          console.log 'Fail creating share!'

        @.disable()
  }

  myDropzone = new Dropzone( dom, options )
  myDropzone.failures = []
  myDropzone.allSuccessful = () ->
    _.isEmpty( @getQueuedFiles() ) &&
    _.isEmpty( @getUploadingFiles() ) &&
    _.isEmpty( @failures )


  onSuccess = ()->
    progressBar.addClass('successful')
    msg = $('#success-message')
    msg.show()
    $('.total-files-count', msg).text( myDropzone.files.length )

    duration = ((new Date) - myDropzone.startTime)/1000.0
    $('.duration', msg).text( duration )

    url = [
      location.origin
      "/shares/"
      myDropzone.key
      ".html"
    ].join ""

    $('#view-url').attr('href', url).text( url )
    
