#Meteor.call 'getLights', (err, lights) ->
#  Session.get

Template.panel.helpers
  template: -> if Session.get('object')
    Session.get('object').split(':')[0] + 'Panel'

collapses = ['controlCollapse', 'presetCollapse', 'scheduleCollapse']
Template.panel.events
  'click core-toolbar': (evt) ->
    target = $(evt.currentTarget).data('target')
    collapse = $('#' + target)[0]
    collapse.toggle()

    collapses.forEach (id) ->
      $('#' + id)[0].opened = false unless id is target

Template.huePanel.rendered = ->
  @autorun ->
    if Session.get 'object'
      parts = Session.get('object').split(':')
      Meteor.call "get state/#{parts[0]}", parts[1], parts[2], (err, state) ->
        state.bri = 0 unless state.on
        Session.set 'state', state

Template.huePanel.helpers
  state: -> Session.get 'state'
  rgb: (focus) ->
    state = Session.get 'state'
    "hsla(#{Math.round(state.hue * 360 / 65535)}, #{if focus is 'sat' then state.sat else 100}%, #{if focus is 'bri' then state.bri/2 else 50}%, 1)"

Template.huePanel.events
  'change paper-slider': (evt) ->
    state =
      hue: $('#hue')[0].value
      sat: $('#sat')[0].value
      bri: $('#bri')[0].value
      colormore: 'hs'
    state.on = state.bri > 0

    Session.set 'state', state
    parts = Session.get('object').split(':')
    Meteor.call "set state/#{parts[0]}", parts[1], parts[2], state

Template.wemoPanel.rendered = ->
  @autorun ->
    if Session.get 'object'
      parts = Session.get('object').split(':')
      Meteor.call "get state/#{parts[0]}", parts[1], parts[2], (err, state) ->
        Session.set 'state', state

Template.wemoPanel.helpers
  stateAttrs: ->
    checked: 'checked' if Session.get 'state'

Template.wemoPanel.events
  'change input': (evt) ->
    state  = $(evt.target).is(':checked')
    Session.set 'state', state
    parts = Session.get('object').split(':')
    Meteor.call "set state/#{parts[0]}", parts[1], parts[2], state

Template.objects.events
  'core-activate core-selector': (evt) ->
    Session.set 'object', evt.target.selected
    Session.set 'state', {}

Template.contexts.events
  'core-activate core-selector': (evt) ->
    Session.set 'objects', evt.target.selected.split(';')
    Session.set 'object', null
    Session.set 'state', {}

Session.setDefault 'objects', []
Template.objects.rendered = ->
  @autorun ->
    if Session.get('objects').length is 0 then return
    $('[flag=obj] paper-item').hide()
    Session.get('objects').forEach (obj) ->
      $('[path="' + obj + '"]').show()
