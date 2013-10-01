# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# TODO: DRY UP ANALYSIS JAVASCRIPT FILES (PULL OUT HELPER/UTILITY STUFF)
window.DOTA2RAILS.matches.eventlog = ->
  eventlog = document.getElementById 'eventlog'

  last_scrolled = null
  update = (tick) ->
    console.log tick

    smallest_diff = Number.MAX_VALUE
    scrollto_obj = null
    $('#eventlog .event').each (i, elem) ->
      diff = Math.abs($(elem).data('tick') - tick)
      if diff <= smallest_diff
        smallest_diff = diff
        scrollto_obj = elem
      else
        return false # break early (events are sorted by tick)

    if last_scrolled isnt scrollto_obj
      $(last_scrolled).css('background-color': $(scrollto_obj).css('background-color'))
      $(scrollto_obj).css('background-color': 'yellow')
      gapy = - $('#eventlog .event').eq(0).offset().top
      console.log "#{gapy} + #{scrollto_obj.offsetTop} = #{gapy + scrollto_obj.offsetTop}"
      $(eventlog).scrollTo(scrollto_obj, scrollto_obj, {
        gap: {y: gapy},
        animation: {duration: 2000}
        })
      last_scrolled = scrollto_obj

  timer_tick = 34000
  update_wrapper = ->
    timer_tick += 100
    clearInterval(timer) if timer_tick > 63000
    update timer_tick
  timer = setInterval update_wrapper, 200
