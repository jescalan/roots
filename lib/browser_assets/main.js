!(function() {
  var protocol      = window.location.protocol === 'http:' ? 'ws://' : 'wss://';
  var address       = protocol + window.location.hostname + ":" + __rootsport + window.location.pathname + '/ws';
  var socket        = new WebSocket(address);
  socket.onmessage  = handleSocketMessage;

  var socket_mgs_handlers = {
    error: set_roots_error,
    compiling: show_compiling_indicator,
    reload: function(){window.location.reload()}
  };

  insert_roots_css();
  load_roots_config();

  function handleSocketMessage(msg) {
    msg = JSON.parse(msg.data);
    socket_mgs_handlers[msg.func].call(this, msg.data);
  }

  function set_roots_error(error) {
    if (document.getElementById('roots-error')) return

    var elm = document.createElement("div");
    elm.innerHTML = '<div id="roots-error">' +
                      '<pre>' +
                        '<span>compile error</span>' +
                        error.replace(/(\r\n|\n|\r)/gm, '<br>') +
                      '</pre>' +
                    '</div>';

    document.body.appendChild(elm);
  }

  function show_compiling_indicator() {
    if (document.getElementById('roots-load-container')) return;

    var elm = document.createElement("div");
    elm.innerHTML = '<div id="roots-load-container">' +
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
                    '</div>';

    document.body.appendChild(elm);
  }

  function insert_roots_css() {
    var style = document.createElement("link");
    style.setAttribute("rel", "stylesheet");
    style.setAttribute("type", "text/css");
    style.setAttribute("href", "/__roots__/main.css");

    document.head.appendChild(style);
  }

  function load_roots_config() {
    var http = new XMLHttpRequest();
    http.open("GET", "/__roots__/conf.json", true)

    http.onreadystatechange = function() {
      if (http.readyState == 4 && http.status == 200) {
        var responseTxt = http.responseText;
        var data = JSON.parse(responseText);

        if(data.livereloadenabled != true) {
          socket_mgs_handlers.reload = function() {}
        }
      }
    }
  }
}());
