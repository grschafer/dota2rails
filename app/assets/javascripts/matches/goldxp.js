window.DOTA2RAILS.matches.goldxp = function() {
  function d3_graph() {
    var data = $('#gold_graph').data('gold');

    var margin = {top: 20, right: 80, bottom: 30, left:50},
      width = 960 - margin.left - margin.right,
      height = 500 - margin.top - margin.bottom;

    var x = d3.scale.linear().range([0, width]);
    var y = d3.scale.linear().range([height, 0]);
    // TODO: use dota player colors
    var color = d3.scale.category10()
      .domain(d3.keys(data).filter(function(key) { return key !== "tick"; }));
    var xAxis = d3.svg.axis().scale(x).orient("bottom");
    var yAxis = d3.svg.axis().scale(y).orient("left");

    var line = d3.svg.line()
      .interpolate("basis")
      .x(function(d,i) {
        return x(data.tick[i]);
      })
      .y(function(d) {
        return y(d);
      });

    var svg = d3.select("#gold_graph").append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    var heroes = color.domain().map(function(name) {
      return {
        name: name,
        values: data[name]
      };
    });

    x.domain(d3.extent(data.tick));

    y.domain([
      d3.min(heroes, function(h) { return d3.min(h.values); }),
      d3.max(heroes, function(h) { return d3.max(h.values); }),
    ]);

    svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis);

    svg.append("g")
      .attr("class", "y axis")
      .call(yAxis)
      .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text("Earned Gold")

    var hero = svg.selectAll("hero")
      .data(heroes)
      .enter().append("g")
      .attr("class", "city");

    hero.append("path")
      .attr("class", "line")
      .attr("d", function(d) {
        return line(d.values);
      })
      .style("stroke", function(d) {
        return color(d.name)
      });

    hero.append("text")
      .datum(function(d) { return {name: d.name, value: d.values[d.values.length - 1]}; })
      .attr("transform", function(d) {
        return "translate(" + x(data.tick[data.tick.length - 1]) + "," + y(d.value) + ")";
      })
      .attr("x", 3)
      .attr("dy", ".35em")
      .attr("style", function(d) { return "fill:" + color(d.name); })
      .text(function(d) { return d.name; });
  }
  d3_graph();

  var nvChart;
  var elems = ['#gold_chart', '#xp_chart'];
  [0,1].forEach(function (i) {
    nv.addGraph(function() {
      var id = elems[i];
      var chart = nv.models.lineChart();

      chart.xAxis
        .axisLabel('Time (ms)')
        .tickFormat(d3.format(',r'));

      chart.yAxis
        .axisLabel('Voltage (v)')
        .tickFormat(d3.format('.02f'));

      d3.select(id + ' svg')
        .datum(sinAndCos(id))
      .transition().duration(500)
        .call(chart);

      nv.utils.windowResize(function() { d3.select(id + ' svg').call(chart) });

      nvChart = chart;
      return chart;
    });
  });

  function sinAndCos(id) {
    var colors = ["rgba(39, 105, 229, 0.3)", "rgba(92, 229, 172, 0.3)", "rgba(172, 0, 172, 0.3)", "rgba(219, 216, 9, 0.3)", "rgba(229, 97, 0, 0.3)", "rgba(229, 121, 175, 0.3)", "rgba(145, 163, 63, 0.3)", "rgba(91, 196, 223, 0.3)", "rgba(0, 118, 30, 0.3)", "rgba(148, 95, 0, 0.3)"];
    var sin = [],
        cos = [];
    var data = $(id).data(id.substring(1, id.indexOf("_")));
    var dataset = [];
    var colorIdx = 0;
    for (var hero in data) {
      if (hero === 'tick')
      continue;
      var values = [];
    for (var i = 0; i < data[hero].length; i++) {
      values.push({x: data.tick[i], y: data[hero][i]});
    }
    dataset.push({key: hero, values: values, color: colors[colorIdx]});
    colorIdx++;
    }
    return dataset;

    for (var i = 0; i < 100; i++) {
      sin.push({x: i, y: Math.sin(i/10)});
      cos.push({x: i, y: .5 * Math.cos(i/10)});
    }

    return [
      {
        values: sin,
        key: 'Sine Wave',
        color: '#ff7f0e'
      },
      {
        values: cos,
        key: 'Cosine Wave',
        color: '#2ca02c'
      }
    ];
  }
};
