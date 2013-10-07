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

  tick = 35000
  update_wrapper = ->
    tick += 150
    console.log tick
    for _,component of ns.components
      #data = component.prep_data(match)
      component.update(tick)
    clearInterval(timer) if tick > 100000
  timer = setInterval update_wrapper, 1000

