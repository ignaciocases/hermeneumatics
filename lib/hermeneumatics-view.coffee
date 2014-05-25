{View} = require 'atom'

module.exports =
class HermeneumaticsView extends View
  @content: ->
    @div class: 'hermeneumatics overlay from-top', =>
      @div "The Hermeneumatics package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    atom.workspaceView.command "hermeneumatics:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "HermeneumaticsView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
