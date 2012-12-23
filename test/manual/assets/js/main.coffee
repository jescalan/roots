# Add scripts to load to this array. These can be loaded remotely like jquery
# is below, or can use file paths, like 'vendor/underscore'
js = ["http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js", '/js/waypoints.min.js']

# this will fire once the required scripts have been loaded
require js, ->
  $ ->
    setTimeout (-> $('.icon').css opacity: 1), 500

    # stick the navigation when it needs to be stuck --------------

    if $(window).scrollTop() > 392
      $('#cssnav').css top: 5

    $(window).on 'scroll', ->
      if $(window).scrollTop() > 392
        $('#cssnav').css top: 5
      else
        $('#cssnav').css top: 385 - $(window).scrollTop()

    # waypoints ---------------------------------------------------

    $('.cssdocs h3').waypoint ->
      $('#cssnav li').removeClass 'active'
      $("a[href='##{$(@).text()}']").parent().addClass 'active'

    # smooth scrolling --------------------------------------------

    $('a[href*=#]:not([href=#])').on 'click', ->
      if location.pathname.replace(/^\//,'') == @.pathname.replace(/^\//,'') || location.hostname == @.hostname
        target = if $(@.hash).length then $(@.hash) else $("[name=#{this.hash.slice(1)}]")
        if target.length
          # this needs to be 1 if scrolling down, -1 if scrolling up. ugh.
          factor = if target.offset().top > $(window).scrollTop() then -1 else 1
          $('html,body').animate({ scrollTop: target.offset().top - factor }, 500)
          return false
      