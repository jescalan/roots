console.log('roots browser thing loaded');

if(!window.jQuery){
  var script = document.createElement('script');
  script.type = "text/javascript";
  script.src = "/__roots__/jquery.min.js";
  document.getElementsByTagName('head')[0].appendChild(script);
} else {
  jQuery_loaded();
}

// jQuery loaded gets called at the end of the jquery file
jQuery_loaded = function (){
  socket_mgs_handlers = {
    error: function (data){
      console.log(data);
    }
  };
  //"<div id='roots-error'><span>compile error</span>" + error.toString().replace(/(\r\n|\n|\r)/gm, "<br>") + "</div>"

  $.ajax({
    url: "/__roots__/cfg.json",
    dataType: 'json'
  }).done(function(data){
    if(data['livereloadEnabled']){
      socket_mgs_handlers['reload'] = function (){
        window.location.reload();
      };
      socket_mgs_handlers['compiling'] = function (){
        if (!document.getElementById('roots-load-container')){
          $('body').append(
            '<div id="roots-load-container">' +
              '<div id="roots-compile-loader">' +
                '<div id="l1"></div>' +
                '<div id="l2"></div>' +
                '<div id="l3"></div>' +
                '<div id="l4"></div>' +
                '<div id="l5"></div>' +
                '<div id="l6"></div>' +
                '<div id="l7"></div>' +
                '<div id="l8"></div>' +
              '</div>' +
            '</div>'
          );
        }
      };
    }
  });

  protocol = window.location.protocol === 'http:' ? 'ws://' : 'wss://';
  address = protocol + window.location.host + window.location.pathname + '/ws';
  socket = new WebSocket(address);
  socket.onmessage = function(msg) {
    console.log(msg);
    msg = jQuery.parseJSON(msg['data']);
    if(msg['data']){
      socket_mgs_handlers[msg['func']](msg['data']);
    } else {
      socket_mgs_handlers[msg['func']]();
    }
  };

  // main.css is a general CSS file that has stuff for the roots
  // notifications. So it always gets included, even if livereload is off
  $('head').append(
    '<link rel="stylesheet" href="/__roots__/main.css"/>'
  );
};
