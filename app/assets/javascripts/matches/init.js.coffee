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

  curTick = $('#curTick')
  tick_interval = 5000 / 2

  tick = 35000
  update_wrapper = ->
    $('#tick_slider').val(tick);
    curTick.html(tick);
    console.log tick
    for _,component of ns.components
      #data = component.prep_data(match)
      component.update(tick)
    clearInterval(timer) if tick > 100000
  time_wrapper = ->
    tick += 150
    update_wrapper()
  timer = setInterval time_wrapper, tick_interval

  # TODO: DRY THIS STATE, it's checked everywhere below
  play_btn_state = 'playing'

  $('#tick_slider').change ->
    tick = parseInt($(this).val())
    curTick.html(tick)
    update_wrapper()

    if play_btn_state is 'playing'
      clearInterval(timer)
      timer = setInterval time_wrapper, tick_interval

  $('#play_pause').click ->
    if play_btn_state is 'playing'
      clearInterval(timer)
    else if play_btn_state is 'paused'
      timer = setInterval time_wrapper, tick_interval

    $(this).children().toggleClass('hide')
    play_btn_state = if play_btn_state is 'paused' then 'playing' else 'paused'

  $('#replay_speed').change ->
    tick_interval = 5000 / parseInt($(this).val())
    if play_btn_state is 'playing'
      clearInterval(timer)
      timer = setInterval time_wrapper, tick_interval

