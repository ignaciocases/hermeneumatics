_ = require "underscore-plus"
hermeneumaticsView = require './hermeneumatics-view'
HNProvider = require "./hn-provider"
ImageEditor = require 'image-view'
path = require 'path'
example = require './example'

module.exports =
  editorSubscription: null
  providers: []
  autocomplete: null
  hermeneumaticsView: null

  ###
   * Registers a SnippetProvider for each editor view
  ###
  activate: ->
    atom.packages.activatePackage("autocomplete-plus")
      .then (pkg) =>
        @autocomplete = pkg.mainModule
        @registerProviders()

    atom.workspaceView.command "hermeneumatics:open-image", => @openImage()

  openImage: ->
    editor = atom.workspace.activePaneItem
    match = editor.getBuffer().getText().match(/@imageFile: .*[\.jpg|tiff|png|gif]/i)
    if match
      fileNames = match[0].split("@imageFile: ")
      fileName = (fileNames.filter (e) -> e != "")[0]
      atom.workspaceView.open(atom.project.getPath()+'/hn/maya/images/'+fileName[0..2]+"/"+fileName)
      console.log(example.helloWorld__T__(" from Coffeescript" + fileName))
      #imageEditor = new ImageEditor(path.join(__dirname, '/hn/maya/images/TIK/', fileName))


  ###
   * Registers a SnippetProvider for each editor view
  ###
  registerProviders: ->
    @editorSubscription = atom.workspaceView.eachEditorView (editorView) =>
      if editorView.attached and not editorView.mini
        provider = new HNProvider editorView

        @autocomplete.registerProviderForEditorView provider, editorView

        @providers.push provider

  ###
   * Cleans everything up, unregisters all SnippetProvider instances
  ###
  deactivate: ->
    @editorSubscription?.off()
    @editorSubscription = null

    @providers.forEach (provider) =>
      @autocomplete.unregisterProvider provider

    @providers = []
