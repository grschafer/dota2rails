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
  ns.utils.number_regex = /^\d+$/

init_filter_form = ->
  $('#filter_form_submit').click ->
    $.post '/filter', $('#filter_form').serialize(), (data) ->
      # replace results pane with returned rendered matchlist
      $('table').replaceWith(data)

ns.index = ->
  init_filter_form()

# ugh, I should really pick up a JS framework or something
ns.mymatches = ->
  init_filter_form()

  $(document)
    .ajaxStart( ->
      $('.spinner').show()
    )
    .ajaxStop( ->
      $('.spinner').hide()
    )

  uploader = $("#s3-uploader").S3Uploader()

  makeAlert = (severity, msg) ->
    "<div class='alert alert-#{severity}'>#{msg}</div>"
  makeNotifKey = -> (new Date()).getTime() + "-" + Math.round(Math.random() * 100000)
  latest_notif_key = null

  # TODO: add validation to only accept .dem files
  $("#s3-uploader").bind 's3_uploads_start', ->
    latest_notif_key = makeNotifKey()
    $('.notif_type').val(latest_notif_key)
    uploader.additional_data({'notif_key': latest_notif_key})
    $('#uploader-alerts').append(makeAlert('info', 'Replay upload started'))
  $("#s3-uploader").bind 'ajax:success', ->
    $('#uploader-alerts').append(makeAlert('success', 'Replay upload completed successfully'))
    $('.upload-notiform.url').find('.notif-btn').removeAttr('disabled')
  $("#s3-uploader").bind 's3_upload_failed', (e, content) ->
    $('#uploader-alerts').append(makeAlert('danger', "#{content.filename} failed to upload : #{content.error_thrown}"))

  $("#search-btn").click ->
    match_id = $('#match-finder > input[type=text]').val()

    if ns.utils.number_regex.test(match_id)
      $("#match-finder").removeClass("has-error")
      $.getJSON '/matchurls', {'match_id': match_id}, (data) ->
        if data.status is "success"
          $('#requester-alerts').append(makeAlert('success', data.msg))
          $('#process-btn').removeAttr('disabled')
          $('#process-btn').html("Process #{match_id}")
          $('#process-btn').click ->
            latest_notif_key = makeNotifKey()
            $('.notif_type').val(latest_notif_key)
            $.post '/request_match', {'match_id': match_id, 'notif_key': latest_notif_key}, (data) ->
              if data.status is "success"
                $('#requester-alerts').append(makeAlert('success', data.msg))
                $('.upload-notiform.match_id').find('.notif-btn').removeAttr('disabled')
              else
                $('#requester-alerts').append(makeAlert('danger', data.msg))
        else
          $('#requester-alerts').append(makeAlert('danger', data.msg))
    else
      $("#match-finder").addClass("has-error")
      $('#requester-alerts').append(makeAlert('danger', 'Match Id must only contain numbers'))

  $('.notif-btn').click (e) ->
    thisForm = $(this).closest('form')
    that = this
    notif_key = $(thisForm).find('.notif_type').val()
    notif_method = $(thisForm).find('.notif_method').val()
    notif_address = $(thisForm).find('.notif_address').val()
    req_data = {notif_method: notif_method, notif_address: notif_address, notif_key: notif_key}
    $.post '/request_notification', req_data, (data) ->
      if data.status is "success"
        $(that).closest('.modal-body').find('.alertbox').append(makeAlert('success', data.msg))
      else
        $(that).closest('.modal-body').find('.alertbox').append(makeAlert('danger', 'Registering notification failed'))



# break out into show.js.coffee?
ns.show = ->

  # get match data (~1 MB) from S3 and merge it into match metadata
  $.getJSON gon.match['url'], (match_data) ->
    $.extend(gon.match, match_data)

    $('.spinner').hide()
    $('#heading').text('Match ' + gon.match['match_id'])

    $('.btn-share').click ->
      $('#share-modal').modal('show')
      $('#share-text').focus()
      $('#share-text').select()

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

