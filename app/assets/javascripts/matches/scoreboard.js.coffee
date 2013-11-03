# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# TODO: DRY UP ANALYSIS JAVASCRIPT FILES (PULL OUT HELPER/UTILITY STUFF)
window.DOTA2RAILS.matches.components.scoreboard = (() ->

  # we want these variables to persist between init and update funcs
  scoreboards = player_names = player_teams = last_update_idx = null
  highlight_columns = null

  # takes thresholds and returns a function that maps a value to
  # a color based on the thresholds
  # eg - assists_colorizer = colorizer(1,2,3,4)
  #      assists_colorizer(3) # returns rgb(190,190,60)
  colorizer = () ->
    thresholds = arguments
    factor = 2.0 / thresholds.length
    (val) ->
      val = -val if val < 0
      yellow = d3.hsl(50,1,0.5)
      for threshold,idx in thresholds
        return yellow.brighter(2.0 - factor * idx) if val < threshold
      yellow

  init = ->
    scoreboards = gon.match.scoreboards
    player_names = gon.match.player_names
    player_teams = gon.match.player_teams
    last_update_idx = null

    # rules for highlighting changes in columns based on magnitude of the
    # change in the contained value (kills, gold, last hits, etc.)
    # the index number refers to the index within text_cells below (which does
    # not include icon cells (hero and items))
    highlight_columns = []
    highlight_columns[1] = colorizer(1,2,3) # levels
    highlight_columns[2] = highlight_columns[4] = colorizer(1,2,3,4,5) # kills, assists
    highlight_columns[3] = colorizer(1,2) # deaths
    highlight_columns[5] = colorizer(100,300,600,1000,3000) # gold
    highlight_columns[6] = colorizer(2,4,7,11) # last hits
    highlight_columns[7] = colorizer(1,2,3,5) # denies


  update = (time) ->
    for scoreboard,idx in scoreboards
      break if scoreboard['time'] > time

    # don't update scoreboard if we're not showing new data
    # TODO: should this instead be controlled by a separate timer in matches/init.js.coffee?
    return if idx is last_update_idx
    last_update_idx = idx

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

      # sum levels, kills, deaths, assists, gold, last hits, denies
      summable_cols = [2,3,4,5,12,13,14]
      # average gpm, xpm
      avg_cols = [15,16]

      total_row = ['Total/Avg']
      for i in summable_cols
        total_row[i] = data[team].reduce(((sum,row) -> sum + row[i]), 0)
      for i in avg_cols
        total_row[i] = data[team].reduce(((sum,row) -> sum + row[i]), 0) / data[team].length
      data[team].push total_row

    # DATA JOIN
    radtable = d3.select("#radiant_players")
    radrows = radtable.selectAll("tr")
      .data(data['radiant'])
    radcells = radrows.selectAll("td")
      .data((d) -> d)

    # iconcells (hero and items) are in columns 1 and 6-11 of the table
    iconcells = radcells.filter((d,i) -> i == 1 or 6 <= i <= 11 )
    iconcells.attr("class", (d) -> if (d? and d isnt 0) then "#{d}-icon" else "")
    textcells = radcells.filter((d,i) -> i != 1 and (i < 6 or i > 11))
    textcells.style("background-color", (d,i) ->
      if highlight_columns[i]?
        highlight_columns[i](d - parseInt(this.textContent)) or "")
    textcells.text((d) -> d)

    diretable = d3.select("#dire_players")
    direrows = diretable.selectAll("tr")
      .data(data['dire'])
    direcells = direrows.selectAll("td")
      .data((d) -> d)

    iconcells = direcells.filter((d,i) -> i == 1 or 6 <= i <= 11 )
    iconcells.attr("class", (d) -> if (d? and d isnt 0) then "#{d}-icon" else "")
    textcells = direcells.filter((d,i) -> i != 1 and (i < 6 or i > 11))
    textcells.style("background-color", (d,i) ->
      if highlight_columns[i]?
        highlight_columns[i](d - parseInt(this.textContent)) or "")
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
  {init: init, update: update}
)()
