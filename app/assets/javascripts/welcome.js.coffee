#= require 'angular'
"use strict"

Dropzone.autoDiscover = false

class @WelcomeCtrl

  constructor: ($scope) ->

    $scope.state        = 'ready'
    $scope.dragged_over = false
    dom                 = $('#dropzone')

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
        @multiple = !@isSingleFileDropped(items)

      isSingleFileDropped: (items)->
        items.length == 1 && items[0].webkitGetAsEntry().isFile

      uploadMultipleFiles: ()->
        $.ajax
          url:      'shares'
          dataType: 'json'
          type:     'POST'

        .success (data) =>
          if data.success
            @failures    = []
            @key         = data.id
            @options.url = "/shares/#{@key}/append"
            @processQueue()
          else
            console.log 'Fail creating share!'
        .fail () ->
          console.log 'Fail creating share!'

      onSuccess: ()->
        $scope.$apply =>
          $scope.state = 'success'
          $scope.elapsed = ((new Date) - @startTime)/1000.0
          $scope.view_url = [
            location.origin
            "/shares/"
            @key
            ".html"
          ].join ""

          $scope.count_down = 5
          @countDown()

      allSuccessful: () ->
        _.isEmpty( @getQueuedFiles() ) &&
        _.isEmpty( @getUploadingFiles() ) &&
        _.isEmpty( @failures )

      countDown: ->
        $scope.$apply ->
          $scope.count_down -= 1

        if $scope.count_down <= 0
          @redirect()
        else
          setTimeout @countDown.bind(@), 1000

      redirect: ->
        location.href = $scope.view_url


    (()->

      @on "complete", (file) ->
        @failures.push( file ) unless file.status == "success"
        @processQueue()

      @on "success", (file) ->
        id = JSON.parse( file.xhr.response ).id
        @key = id if id
        @onSuccess() if @allSuccessful()

      @on "dragover", () ->
        $scope.$apply () ->
          $scope.dragged_over = true

      @on "dragleave", () ->
        $scope.$apply () ->
          $scope.dragged_over = false

      @on "totaluploadprogress", (per) ->
        $scope.progress = per

      @on "sending", (file, xhr, formData) ->
        console.log file
        formData.append "path", file.fullPath

      @on "drop", (evt) ->
        @processDrop( evt.dataTransfer.items )

      @on "queued", (evt) ->
        @startTime          = new Date
        $scope.files_count  = @files.length
        $scope.dragged_over = false
        $scope.state        = 'processing'

        if @multiple
          @uploadMultipleFiles()
        else
          @processQueue()


      ).call myDropzone
