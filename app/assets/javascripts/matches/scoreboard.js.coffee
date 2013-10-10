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
  player_names = gon.match.player_names
  player_teams = gon.match.player_teams
  #heroes = (name for name of positions when name isnt 'tick')

  #radrows.enter().append("tr")
    #.attr("xlink:href", (d) -> d)
    #.attr("width", mapw)
    #.attr("height", maph)

  update = (time) ->
    for scoreboard,idx in scoreboards
      break if scoreboard['time'] > time

    #data = []
    #for hero,s of scoreboards[idx-1] when hero isnt 'time'
      #name = (name for h,name of player_names when h is hero)[0]
      #data.push [name, hero, s.l, s.k, s.d, s.a, s.i0, s.i1, s.i2, s.i3, s.i4, s.i5, s.g, s.lh, s.dn, s.gpm, s.xpm]
    #console.log time

    data = {'radiant': [], 'dire': []}
    for team,heroes of player_teams
      for hero in heroes
        s = scoreboards[idx-1][hero]
        name = player_names[hero]
        data[team].push [name, hero, s.l, s.k, s.d, s.a, s.i0, s.i1, s.i2, s.i3, s.i4, s.i5, s.g, s.lh, s.dn, s.gpm, s.xpm]

    # DATA JOIN
    radtable = d3.select("#radiant_players")
    radrows = radtable.selectAll("tr")
      .data(data['radiant'])
    radcells = radrows.selectAll("td")
      .data((d) -> d)
    radcells.attr("class", "") # clear stale item icons

    iconcells = radcells.filter((d) -> typeof d is "string" and (d.indexOf("npc_") is 0 or d.indexOf("item_") is 0))
    iconcells.attr("class", (d) -> "#{d}-icon")
    textcells = radcells.filter((d) -> typeof d isnt "string" or (d.indexOf("npc_") isnt 0 and d.indexOf("item_") isnt 0))
    textcells.classed("cell-change", (d) -> this.textContent isnt "#{d}")
    textcells.text((d) -> d)

    diretable = d3.select("#dire_players")
    direrows = diretable.selectAll("tr")
      .data(data['dire'])
    direcells = direrows.selectAll("td")
      .data((d) -> d)
    direcells.attr("class", "") # clear stale item icons

    iconcells = direcells.filter((d) -> typeof d is "string" and (d.indexOf("npc_") is 0 or d.indexOf("item_") is 0))
    iconcells.attr("class", (d) -> "#{d}-icon")
    textcells = direcells.filter((d) -> typeof d isnt "string" or (d.indexOf("npc_") isnt 0 and d.indexOf("item_") isnt 0))
    textcells.classed("cell-change", (d) -> this.textContent isnt "#{d}")
    textcells.text((d) -> d)
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
