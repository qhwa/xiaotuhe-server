// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require underscore-min
//= require jquery
//= require jquery_ujs
//= require angular
//= require emitter
//= require dropzone
//= require jquery.tablesort
//= require welcome
//= require dropdown
//= require moment
//= require moment.lang.zh_cn
//= require shares
//= require_self

"use strict"

$.ajaxSetup({
  beforeSend: function(xhr){
    var token = $('meta[name=csrf-token]').attr('content');
    if(token) {
      xhr.setRequestHeader( "X-CSRF-Token", token )
    }
  }
})

$(function($){
  $('.ui.dropdown').dropdown();
  $('.time').fromNow();
});

$.fn.fromNow = function(){
  return $(this).each(function(){
    var timeKey = 'raw-time';
    var $this = $(this), txt = $this.data(timeKey) || $this.text();
    $this.data(timeKey, txt)
    $this.text(moment(txt).fromNow());
  });
};
