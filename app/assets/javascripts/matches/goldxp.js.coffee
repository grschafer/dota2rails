# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# TODO: DRY UP ANALYSIS JAVASCRIPT FILES (PULL OUT HELPER/UTILITY STUFF)
window.DOTA2RAILS.matches.components.graph = (() ->
  line_home = null
  chart = null
  gold_color = d3.hsl(50, 1, 0.5).brighter(0.2)
  xp_color = d3.hsl(50, 1, 0.5).darker(1.2)
  init = ->
    nv.addGraph
      generate: ->
        id = '#chart'
        chart = nv.models.lineChart()

        chart.tooltips(true)
        chart.useInteractiveGuideline(true)
        data = gold_xp_data(id)
        gold_range = d3.extent(data[0].values, (d) -> d.y)
        xp_range = d3.extent(data[1].values, (d) -> d.y)
        range = gold_range.concat(xp_range)
        biggest = d3.max(range.map(Math.abs))
        chart.forceY([-biggest, biggest])

        radiant_name = gon.match.radiant_name or "radiant"
        dire_name = gon.match.dire_name or "dire"
        chart.valueFormatter((d, i) ->
          team = if d > 0 then radiant_name else dire_name
          d = Math.abs(d)
          "#{chart.yAxis.tickFormat()(d)} advantage for #{team}"
        )


        chart.xAxis
          .axisLabel('Time')
          #.tickFormat(d3.format(',r'))
          # see matches/init.js.coffee for formatTime def
          .tickFormat((d) -> window.DOTA2RAILS.matches.utils.formatTime(d))

        chart.yAxis
          .tickFormat(d3.format(',d'))

        d3.select("#{id} svg")
          .datum(data)
        .transition().duration(500)
          .call(chart)

        nv.utils.windowResize(-> d3.select("#{id} svg").call(chart))
        chart

      callback: (graph) ->
        line_home = d3.selectAll('.nv-x.nv-axis .nvd3').append('g')
        line_home.attr 'opacity', '1'
        line_home.each (d,i) ->
          max = $(this).siblings('.nv-axisMaxMin').last().children().prop('__data__')
          t = $(this).siblings('.nv-axisMaxMin').last().attr('transform')
          width = parseFloat(t.substring(t.indexOf("(") + 1, t.indexOf(",")))
          min = $(this).siblings('.nv-axisMaxMin').first().children().prop('__data__')
          scale = width / (max - min)
          offset = -min * scale
          line_home.attr "transform", "translate(#{offset} 0) scale(#{scale} 1)"
          line_home.style "stroke-width", 1/scale

    gold_xp_data = (id) ->
      colors = ["rgba(39, 105, 229, 1)", "rgba(92, 229, 172, 1)", "rgba(172, 0, 172, 1)", "rgba(219, 216, 9, 1)", "rgba(229, 97, 0, 1)", "rgba(229, 121, 175, 1)", "rgba(145, 163, 63, 1)", "rgba(91, 196, 223, 1)", "rgba(0, 118, 30, 1)", "rgba(148, 95, 0, 1)"]
      dataset = []
      for data_label in ['gold', 'xp']
        data = gon.match["#{data_label}_graph"]
        player_teams = gon.match.player_teams
        values = []
        for time,idx in data.time
          r = 0
          d = 0
          for hero,herodata of data when hero isnt 'time'
            if hero in player_teams['radiant']
              r += if herodata[idx]? then herodata[idx] else herodata[herodata.length - 1]
            else if hero in player_teams['dire']
              d += if herodata[idx]? then herodata[idx] else herodata[herodata.length - 1]
          values.push {'x': time, 'y': r - d}
        dataset.push {key: data_label, color: (if data_label is 'gold' then gold_color else xp_color), values: values}
      dataset

  update = (time) ->
    line = line_home.selectAll("line").data([time])
    line.transition()
        .attr("transform", (d,i) -> "translate(#{d} 0)")
        .ease('linear')
        .duration(1000)
    line.enter().append("line")
      .attr("x2", 0)
      .attr("y2", -420)
      .style("stroke", "red")
  #timer_tick = 14874
  #intFn = ->
    #timer_tick += 900
    #clearInterval(timer) if timer_tick > 100000
    #update timer_tick, null
  #timer = setInterval intFn, 1000
  {init: init, update: update}
)()
