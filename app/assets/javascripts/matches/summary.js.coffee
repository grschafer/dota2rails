# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# TODO: DRY UP ANALYSIS JAVASCRIPT FILES (PULL OUT HELPER/UTILITY STUFF)
window.DOTA2RAILS.matches.summary = ->
  return false # TODO: REMOVE
  # dota player colors
  colors = ["rgba(39, 105, 229, 1)", "rgba(92, 229, 172, 1)", "rgba(172, 0, 172, 1)", "rgba(219, 216, 9, 1)", "rgba(229, 97, 0, 1)", "rgba(229, 121, 175, 1)", "rgba(145, 163, 63, 1)", "rgba(91, 196, 223, 1)", "rgba(0, 118, 30, 1)", "rgba(148, 95, 0, 1)"];

  curtick = 0
  container = document.getElementById('map')
  positions = $(container).data('positions')
  heroes = (name for name of positions when name isnt 'tick')
  dot_size = 5

  svg = d3.select("#map").append("svg")
      .attr("width", mapw)
      .attr("height", maph)
  imgs = svg.selectAll("image").data([mapfile])
  imgs.enter().append("svg:image")
    .attr("xlink:href", (d) -> d)
    .attr("width", mapw)
    .attr("height", maph)

  # positions map
  update = (tick, data) ->
    console.log tick

    # DATA JOIN
    rects = svg.selectAll("rect")
      .data(data, (d) -> d.name)

    # UPDATE
    rects.transition()
        .attr("x", (d) -> d['x'])
        .attr("y", (d) -> d['y'])

    # ENTER
    rects.enter().append("rect")
        .attr("x", (d) -> d['x'])
        .attr("y", (d) -> d['y'])
        .attr("width", 5)
        .attr("height", 5)
        .style("fill", (d, i) -> colors[i])

    # ENTER + UPDATE

    # EXIT
    rects.exit().remove()

  timer_tick = positions['tick'][0]
  update_wrapper = ->
    timer_tick += 150
    for val,idx in positions['tick']
      break if val > timer_tick
    data = []
    for h,i in heroes
      continue if idx > positions[h].length
      data.push {}
      $.extend(data[i], {name: h}, world_to_img positions[h][idx]...)
    clearInterval(timer) if data.length is 0
    update timer_tick, data
  timer = setInterval update_wrapper, 100
