{WorkspaceView} = require 'atom'
Hermeneumatics = require '../lib/hermeneumatics'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "Hermeneumatics", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('hermeneumatics')

  describe "when the hermeneumatics:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.hermeneumatics')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'hermeneumatics:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.hermeneumatics')).toExist()
        atom.workspaceView.trigger 'hermeneumatics:toggle'
        expect(atom.workspaceView.find('.hermeneumatics')).not.toExist()
