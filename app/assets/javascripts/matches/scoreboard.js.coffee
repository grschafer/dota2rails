# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# TODO: DRY UP ANALYSIS JAVASCRIPT FILES (PULL OUT HELPER/UTILITY STUFF)
window.DOTA2RAILS.matches.components.scoreboard = (() ->
  # dota player colors
  colors = ["rgba(39, 105, 229, 1)", "rgba(92, 229, 172, 1)", "rgba(172, 0, 172, 1)", "rgba(219, 216, 9, 1)", "rgba(229, 97, 0, 1)", "rgba(229, 121, 175, 1)", "rgba(145, 163, 63, 1)", "rgba(91, 196, 223, 1)", "rgba(0, 118, 30, 1)", "rgba(148, 95, 0, 1)"];

  container = document.getElementById('scoreboard')
  #scoreboards = $(container).data('scoreboards')
  #players = $(container).data('players')
  scoreboards = gon.match.scoreboards
  players = gon.match.player_names
  #heroes = (name for name of positions when name isnt 'tick')

  #radrows.enter().append("tr")
    #.attr("xlink:href", (d) -> d)
    #.attr("width", mapw)
    #.attr("height", maph)

  update = (time) ->
    for scoreboard,idx in scoreboards
      break if scoreboard['time'] > time

    data = []
    for hero,s of scoreboards[idx-1] when hero isnt 'time'
      name = (name for name,h of players when h is hero)[0]
      data.push [name, hero, s.l, s.k, s.d, s.a, s.i0, s.i1, s.i2, s.i3, s.i4, s.i5, s.g, s.lh, s.dn, s.gpm, s.xpm]
    #console.log time

    # DATA JOIN
    radtable = d3.select("#radiant_players")
    radrows = radtable.selectAll("tr")
      .data(data[0..4])
    radcells = radrows.selectAll("td")
      .data((d) -> d)
    iconcells = radcells.filter((d) -> typeof d is "string" and (d.indexOf("npc_") is 0 or d.indexOf("item_") is 0))
    iconcells.attr("class", (d) -> "#{d}-icon")
    othercells = radcells.filter((d) -> typeof d isnt "string" or (d.indexOf("npc_") isnt 0 and d.indexOf("item_") isnt 0))
    othercells.classed("cell-change", (d) -> this.textContent isnt d and this.textContent isnt "#{d}")
    othercells.text((d) -> d)

    diretable = d3.select("#dire_players")
    direrows = diretable.selectAll("tr")
      .data(data[5..9])
    direcells = direrows.selectAll("td")
      .data((d) -> d)
    iconcells = direcells.filter((d) -> typeof d is "string" and (d.indexOf("npc_") is 0 or d.indexOf("item_") is 0))
    iconcells.attr("class", (d) -> "#{d}-icon")
    othercells = direcells.filter((d) -> typeof d isnt "string" or (d.indexOf("npc_") isnt 0 and d.indexOf("item_") isnt 0))
    othercells.classed("cell-change", (d) -> this.textContent isnt d and this.textContent isnt "#{d}")
    othercells.text((d) -> d)
    #direcells.classed("cell-change", (d) -> this.textContent isnt d and this.textContent isnt "#{d}")

  #timer_tick = scoreboards[2]['tick']
  #update_wrapper = ->
    #timer_tick += 450
    #for val,idx in scoreboards
      #break if val['tick'] > timer_tick

    #data = []
    #for hero,s of scoreboards[idx-1] when hero isnt 'tick'
      #name = (name for name,h of players when h is hero)[0]
      #data.push [name, hero, s.l, s.k, s.d, s.a, s.i0, s.i1, s.i2, s.i3, s.i4, s.i5, s.g, s.lh, s.dn, s.gpm, s.xpm]

    #clearInterval(timer) if idx is scoreboards.length - 1
    #update timer_tick, data
  #timer = setInterval update_wrapper, 3000
  {update: update}
)()
