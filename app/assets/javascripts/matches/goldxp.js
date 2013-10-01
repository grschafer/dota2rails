window.DOTA2RAILS.matches.goldxp = function() {
  var nvChart;
  nv.addGraph({
    generate: function() {
      var id = '#chart';
      var chart = nv.models.lineChart();

      chart.xAxis
        .axisLabel('Time (ms)')
        .tickFormat(d3.format(',r'));

      chart.yAxis
        .axisLabel('Voltage (v)')
        .tickFormat(d3.format('.02f'));

      d3.select(id + ' svg')
        .datum(gold_xp_data(id))
      .transition().duration(500)
        .call(chart);

      nv.utils.windowResize(function() { d3.select(id + ' svg').call(chart) });

      nvChart = chart;
      return chart;
    },
    callback: function(graph) {
      line_home = d3.selectAll('.nv-x.nv-axis .nvd3').append('g');
      line_home.attr('opacity', '1');
      line_home.each(function (d,i) {
        var max = $(this).siblings('.nv-axisMaxMin').last().children().prop('__data__');
        var t = $(this).siblings('.nv-axisMaxMin').last().attr('transform');
        var width = parseFloat(t.substring(t.indexOf("(") + 1, t.indexOf(",")));
        var min = $(this).siblings('.nv-axisMaxMin').first().children().prop('__data__');
        var scale = width / (max - min);
        var offset = -min * scale;
        line_home.attr("transform", "translate(" + offset + " 0) scale(" + scale + " 1)")
        line_home.style("stroke-width", 1/scale);
      });
    }
  });

  function gold_xp_data(id) {
    var colors = ["rgba(39, 105, 229, 1)", "rgba(92, 229, 172, 1)", "rgba(172, 0, 172, 1)", "rgba(219, 216, 9, 1)", "rgba(229, 97, 0, 1)", "rgba(229, 121, 175, 1)", "rgba(145, 163, 63, 1)", "rgba(91, 196, 223, 1)", "rgba(0, 118, 30, 1)", "rgba(148, 95, 0, 1)"];
    var dataset = [];
    for (var data_label in {gold:0, xp:0}) {
      var data = $(id).data(data_label);
      var values = [];
      for (var i = 0; i < data.tick.length; i++) {
        // TODO: get which team heroes are on!
        var c = 0;
        var r = 0;
        var d = 0;
        for (var hero in data) {
          if (hero === 'tick')
            continue
          if (c < 5)
            r += (data[hero][i] !== undefined) ? data[hero][i] : data[hero][data[hero].length - 1]
          else
            d += (data[hero][i] !== undefined) ? data[hero][i] : data[hero][data[hero].length - 1]
          c++
        }
        values.push({'x': data.tick[i], 'y': r - d});
      }
      dataset.push({key: data_label, color: (data_label === 'gold') ? 'blue' : 'green', values: values});
    }
    return dataset;
  }

  var line_home;
  function update(tick, data) {
    line = line_home.selectAll("line").data([tick]);
    line.transition()
        .attr("transform", function(d,i) {
          return "translate(" + d +  ",0)";
        })
        .ease('linear')
        .duration(1000);
    line.enter().append("line")
      .attr("x2", 0)
      .attr("y2", -420)
      .style("stroke", "red")
    //.attr("x2", function() { return Math.random() * 300 })
      //.append("g").attr("transform", "translate(32,60)")
    //line.append("line").attr('x2', 0).attr('y2', -420);
    console.log(tick);
  }
  var timer_tick = 14874; // TODO: don't hardcode!
  var timer = setInterval(function () {
    timer_tick += 900;
    update(timer_tick, null);
  }, 1000);
};
