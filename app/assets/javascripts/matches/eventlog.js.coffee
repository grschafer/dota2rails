# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# TODO: DRY UP ANALYSIS JAVASCRIPT FILES (PULL OUT HELPER/UTILITY STUFF)
window.DOTA2RAILS.matches.components.eventlog = (() ->
  # we want these variables to persist between init and update funcs
  eventlog = last_scrolled = null

  eventlist = null

  init = ->
    eventlog = document.getElementById 'eventlog'
    last_scrolled = null

    eventlist = []
    eventlist = eventlist.concat(x) for x in [gon.match.roshans, gon.match.buybacks, gon.match.runes, gon.match.kill_list]
    eventlist.sort (a,b) ->
        return -1 if a.time < b.time
        return 0 if a.time is b.time
        return 1 if a.time > b.time

  format_event = (evt) ->
    iconize_hero = (hero) ->
      "<img src='#{window.DOTA2RAILS.matches.heroiconpaths[hero]}' />"
    iconize_killers = (killers) ->
      # returns a string of img tags (icons) for only the heroes (filters out creeps, towers) in the given list
      hero_killers = []
      hero_killers = hero_killers.concat(iconize_hero(name)) for name of killers when name.indexOf("hero") isnt -1
      hero_killers.join('')
    switch evt.event
      when 'rune_spawn' then "#{evt.rune_type} rune spawned"
      when 'rune_bottle' then "#{evt.rune_type} rune bottled by #{iconize_hero(evt.hero)}"
      when 'rune_pickup' then "#{evt.rune_type} rune used by #{iconize_hero(evt.hero)}"
      when 'roshan_kill' then "#{evt.team} killed Roshan"
      when 'aegis_pickup' then "#{iconize_hero(evt.hero)} picked up aegis"
      when 'aegis_denied' then "#{iconize_hero(evt.hero)} denied the aegis"
      when 'aegis_stolen' then "#{iconize_hero(evt.hero)} stole the aegis"
      when 'buyback' then "#{iconize_hero(evt.hero)} bought back for #{evt.cost} gold"
      when 'kill' then "#{iconize_killers(evt.killers)} killed #{iconize_hero(evt.hero)}, earning #{evt.bounty_gold} gold, #{evt.bounty_xp} xp"
      when 'deny' then "#{iconize_killers(evt.killers)} denied #{iconize_hero(evt.hero)}"

  update = (time) ->
    # find all events within 30 seconds on either side of current time
    # join to div/p/li
    # eventual transition animation

    # TODO: INEFFICIENT!!
    # use d3.binary_search then slice (instead of filter)
    cur_events = eventlist.filter((x) -> time > x.time)

    eventlog = d3.select('#eventlog')
    # NOTE: (d.event + d.time) may not be enough to ensure uniqueness
    #   ie - somebody could kill 2 heroes at the exact same time
    events = eventlog.selectAll('p')
      .data(cur_events, (d) -> d.event + d.time)

    # TODO: probably inefficient
    # fadeout highlight over 30 in-game seconds
    # hsl(50,1,0.5).brighter(x) turns to white between x=1.9 and x=2
    #events.filter((d) -> this.style.backgroundColor isnt "rgb(255,255,255)")
    events.style('background-color', (d) -> d3.hsl(50, 1, 0.5).brighter((time - d.time) / 15))

    # add new events to the top of the eventlog div
    new_event = events.enter().insert('p', ":first-child")
      #.style('background-color', 'yellow')
    #new_event.transition()
    #  .duration(15000)
    #  .style('background-color', 'white')
    new_event.append('small')
      .text((d) -> window.DOTA2RAILS.matches.utils.formatTime(d.time))
      .style('padding-right', '2em')
    new_event.append('span').html((d) -> "#{format_event(d)}")

    events.exit().remove()

  {init: init, update: update}
)()
