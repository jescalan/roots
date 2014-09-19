!(function(){
  var loc = window.location;
  var protocol = loc.protocol === 'http:' ? 'ws://' : 'wss://';
  var address = protocol + loc.host + loc.pathname + '/ws';
  (new WebSocket(address)).onmessage = handle_msg;

  var handlers = {
    error: show_error,
    compiling: show_compiling,
    reload: function(){ loc.reload() }
  }

  insert_css();
  load_config();

  function handle_msg(msg){
    var msg = JSON.parse(msg.data);
    handlers[msg.type](msg.data);
  }

  function insert_css(){
    var style = document.createElement("link");
    style.setAttribute("rel", "stylesheet");
    style.setAttribute("type", "text/css");
    style.setAttribute("href", "/__roots__/main.css");
    document.head.appendChild(style);
  }

  function load_config(){
    if (!__livereload) handlers.reload = function(){};
  }

  function show_error(error){
    remove_compiling();
    if (document.getElementById('roots-error')) return

    var el = document.createElement("div")
    var cleanError = error.replace ? error.replace(/(\r\n|\n|\r)/gm, '<br>') : "";
    el.innerHTML = "<div id='roots-error'><pre><span>compile error</span>" + cleanError + "</pre></div>";
    document.body.appendChild(el);
  }

  function show_compiling(){
    console.log('compiling')
    if (document.getElementById('roots-load-container')) return

    var el = document.createElement("div");
    el.innerHTML = '<div id="roots-load-container"><div id="roots-compile-loader"><div id="l1"></div><div id="l2"></div><div id="l3"></div><div id="l4"></div><div id="l5"></div><div id="l6"></div><div id="l7"></div><div id="l8"></div></div></div>';
    document.body.appendChild(el);
  }

  function remove_compiling(){
    var el = document.getElementById('roots-load-container');
    el.parentNode.removeChild(el);
  }

}());
