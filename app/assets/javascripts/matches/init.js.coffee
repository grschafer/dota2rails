# responsible for taking all match data,
# synchronizing with time slider,
# and updating the components (map, scoreboard, eventlog, graphs)

window.DOTA2RAILS.matches.init = ->
  # convert each component js into an object (with init and update functions)
  # will I need to define load order in application.js?

# break out into show.js.coffee?
ns = window.DOTA2RAILS.matches
ns.show = ->
  # get data
  # set interval, slider controls
  # send update func calls to components
    # or can use events?

  curTime = $('#curTime')
  startTime = gon.match['positions']['time'][0]
  endTime = gon.match['positions']['time'][gon.match['positions']['time'].length - 1]
  time_interval = 1000 / 2 # interval at which to update all components by the time_delta
  time_delta = 1 # how much ingame time to add (in seconds)

  sec_to_hms = (time) ->
    h = parseInt(time / 3600)
    h = if h is 0 then "" else "#{h}:"
    m = parseInt(parseInt(time % 3600) / 60)
    m = if m < 10 then "0#{m}" else m
    s = parseInt(time % 60)
    s = if s < 10 then "0#{s}" else s
    "#{h}#{m}:#{s}"

  gameDuration = sec_to_hms(endTime - startTime)
  update_time_label = () ->
    gameTime = time - startTime
    curTime.html("#{sec_to_hms(gameTime)} / #{gameDuration}")
    slider= $('#time_slider')
    scale = slider.width() / (endTime - startTime)
    leftOffset = gameTime * scale - 42 # 42 is half-width of text "01:23 / 45:67"
    curTime.css('left', leftOffset)

  time = startTime
  update_wrapper = ->
    $('#time_slider').val(time);
    update_time_label()
    #console.log time
    for _,component of ns.components
      #data = component.prep_data(match)
      component.update(time, time_interval)
    $('#play_pause').click() if time > endTime
  time_wrapper = ->
    time += time_delta # how much ingame time to add (in seconds)
    update_wrapper()
  timer = setInterval time_wrapper, time_interval

  # TODO: DRY THIS STATE, it's checked everywhere below
  play_btn_state = 'playing'

  $('#time_slider').change ->
    time = parseInt($(this).val())
    update_time_label()
    update_wrapper()

    if play_btn_state is 'playing'
      clearInterval(timer)
      timer = setInterval time_wrapper, time_interval

  $('#play_pause').click ->
    if play_btn_state is 'playing'
      clearInterval(timer)
    else if play_btn_state is 'paused'
      timer = setInterval time_wrapper, time_interval

    $(this).children().toggleClass('hide')
    play_btn_state = if play_btn_state is 'paused' then 'playing' else 'paused'

  $('#replay_speed').change ->
    time_interval = 1000 / parseInt($(this).val())
    if play_btn_state is 'playing'
      clearInterval(timer)
      timer = setInterval time_wrapper, time_interval

