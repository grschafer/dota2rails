# responsible for taking all match data,
# synchronizing with time slider,
# and updating the components (map, scoreboard, eventlog, graphs)

ns = window.DOTA2RAILS.matches
ns.init = ->

  # http://stackoverflow.com/a/11287084/751774
  # converts seconds (2347) to [H:]M:S (39:07)
  formatMin = d3.time.format "%M:%S"
  formatHour = d3.time.format "%H:%M:%S"
  formatTime = (d) ->
    if d < 0
      "-#{formatMin(new Date(2012, 0, 1, 0, 0, -d))}"
    else if d > 3600
      formatHour(new Date(2012, 0, 1, 0, 0, d))
    else
      formatMin(new Date(2012, 0, 1, 0, 0, d))
  ns.utils.formatTime = formatTime

ns.index = ->
  $("#s3-uploader").S3Uploader()

  $("#s3-uploader").bind 's3_uploads_start', (e) ->
    $('#upload-notiform').show()

# break out into show.js.coffee?
ns.show = ->
  # get data
  # set interval, slider controls
  # send update func calls to components
    # or can use events?
  for _,component of ns.components
    if component.hasOwnProperty('init')
      component.init()

  curTime = $('#curTime')
  startTime = gon.match['positions']['time'][0]
  endTime = gon.match['positions']['time'][gon.match['positions']['time'].length - 1]
  time = startTime
  time_interval = 1000 / 2 # interval at which to update all components by the time_delta
  time_delta = 1 # how much ingame time to add (in seconds)

  gameDuration = ns.utils.formatTime(endTime)
  update_time_label = () ->
    curTime.html("#{ns.utils.formatTime(time)} / #{gameDuration}")
    slider= $('#time_slider')
    scale = slider.width() / (endTime - startTime)
    leftOffset = (time + 90) * scale - 42 # 42 is half-width of text "01:23 / 45:67"
    curTime.css('left', leftOffset)
  window.onresize = ->
    update_time_label()

  update_wrapper = ->
    $('#time_slider').val(time)
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

