# responsible for taking all match data,
# synchronizing with time slider,
# and updating the components (map, scoreboard, eventlog, graphs)

window.DOTA2RAILS.matches.init = ->
  # convert each component js into an object (with init and update functions)
  # will I need to define load order in application.js?

ns = window.DOTA2RAILS.matches
ns.show = ->
  # get data
  # set interval, slider controls
  # send update func calls to components
    # or can use events?

  curTime = $('#curTime')
  endTime = gon.match['positions']['time'][gon.match['positions']['time'].length - 1]
  time_interval = 5000 / 2

  time = 300
  update_wrapper = ->
    $('#time_slider').val(time);
    curTime.html(time);
    console.log time
    for _,component of ns.components
      #data = component.prep_data(match)
      component.update(time)
    $('#play_pause').click() if time > endTime
  time_wrapper = ->
    time += 5
    update_wrapper()
  timer = setInterval time_wrapper, time_interval

  # TODO: DRY THIS STATE, it's checked everywhere below
  play_btn_state = 'playing'

  $('#time_slider').change ->
    time = parseInt($(this).val())
    curTime.html(time)
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
    time_interval = 5000 / parseInt($(this).val())
    if play_btn_state is 'playing'
      clearInterval(timer)
      timer = setInterval time_wrapper, time_interval

