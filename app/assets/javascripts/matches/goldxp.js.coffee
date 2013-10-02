window.DOTA2RAILS.matches.show = ->
  line_home = null
  nv.addGraph
    generate: ->
      id = '#chart'
      chart = nv.models.lineChart()

      chart.xAxis
        .axisLabel('Time')
        .tickFormat(d3.format(',r'))

      chart.yAxis
        .tickFormat(d3.format('.02f'))

      d3.select("#{id} svg")
        .datum(gold_xp_data(id))
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
      data = $(id).data data_label
      values = []
      for tick,idx in data.tick
        c = 0
        r = 0
        d = 0
        for hero,herodata of data when hero isnt 'tick'
          if c < 5
            r += if herodata[idx]? then herodata[idx] else herodata[herodata.length - 1]
          else
            d += if herodata[idx]? then herodata[idx] else herodata[herodata.length - 1]
          c++
        values.push {'x': tick, 'y': r - d}
      dataset.push {key: data_label, color: (if data_label is 'gold' then 'blue' else 'green'), values: values}
    dataset

  update = (tick, data) ->
    line = line_home.selectAll("line").data([tick])
    line.transition()
        .attr("transform", (d,i) -> "translate(#{d} 0)")
        .ease('linear')
        .duration(1000)
    line.enter().append("line")
      .attr("x2", 0)
      .attr("y2", -420)
      .style("stroke", "red")
  timer_tick = 14874
  intFn = ->
    timer_tick += 900
    clearInterval(timer) if timer_tick > 100000
    update timer_tick, null
  timer = setInterval intFn, 1000
