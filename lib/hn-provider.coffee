{Range}  = require "atom"
_ = require "underscore-plus"
Client = require("node-rest-client").Client
promisify = require('deferred').promisify
{Provider, Suggestion, Utils} = require "autocomplete-plus"
fuzzaldrin = require "fuzzaldrin"

module.exports =
class HNProvider extends Provider
  wordRegex: /(')?(\?\.\#)?[a-zA-Z0-9?'².*]+/g
  exclusive: true
  that = this
  @glyphs: []

  initialize: ->
    client = new Client
    uri = "http://www.uooh.org/api/catalog"
    # uri = "http://localhost:8080/api/catalog"
    client.get uri, (data, response) =>
      # parsed response body as js object
      # console.log(data)
      @glyphs = data
      # @glyphs = JSON.parse(data)
      # console.log(@glyphs)
      # raw response
      # console.log(response)

  buildSuggestions: ->
    selection = @editor.getSelection()
    prefix = @prefixOfSelection selection
    return unless prefix.length

    suggestions = @findSuggestionsForPrefix prefix
    return unless suggestions.length
    return suggestions

  findSuggestionsForPrefix: (prefix) ->
    # glyphs = @glyphs.concat @getCompletionsForCursorScope()

    # we will want autocompletions from a given source in the future
        # Do we want autocompletions from all open buffers?
    # if atom.config.get "autocomplete-plus.includeCompletionsFromAllBuffers"
    #   buffers = atom.project.getBuffers()
    # else
    #   buffers = [@editor.getBuffer()]
    #
    # # Collect words from all buffers using the regular expression
    # matches = []
    # matches.push(buffer.getText().match(@wordRegex)) for buffer in buffers
    #
    # # Flatten the matches, make it an unique array
    # aList = _.flatten matches
    # glyphs = glyphs.concat aList
    # glyphs = @unique glyphs

    # console.log(@glyphs)

    suggestions = for result in @glyphs
      # resultPath = path.resolve directory, result

      # Check in the database

      # chan = new Suggestion this,
      #     word: "CHAN"
      #     prefix: "cha"
      #     label: "CHAN-na CHAN"
      #     data:
      #       body: "CHAN"
      # variant = ""
      variant = ""
      if result.variant == "1"
        variant = ""
      else
        variant = String.fromCharCode(parseInt("832" + result.variant))

      imgs = result.images.join("")

      new Suggestion this,
        word: result.transliteration + variant
        prefix: prefix
        label: "<span>#{result.transcription} '#{result.gloss}'</span>" + imgs
        renderLabelAsHtml: true
        data:
          body:
            if result.variant == "1"
              result.transliteration
            else
              result.transliteration + "._" + result.variant

    results = fuzzaldrin.filter(suggestions, prefix, key:"word")
    return results

  unique: (arr) ->
    out = []
    seen = new Set

    i = arr.length
    while i--
      item = arr[i]
      unless seen.has item
        out.push item
        seen.add item

    return out

  # Private: Finds autocompletions in the current syntax scope (e.g. css values)
  #
  # Returns an {Array} of strings
  getCompletionsForCursorScope: ->
    cursorScope = @editor.scopesForBufferPosition @editor.getCursorBufferPosition()
    completions = atom.syntax.propertiesForScope cursorScope, "editor.completions"
    completions = completions.map (properties) -> _.valueForKeyPath properties, "editor.completions"
    return Utils.unique _.flatten(completions)

  confirm: (suggestion) ->
    selection = @editor.getSelection()
    startPosition = selection.getBufferRange().start
    buffer = @editor.getBuffer()

    # Replace the prefix with the body
    cursorPosition = @editor.getCursorBufferPosition()
    buffer.delete Range.fromPointWithDelta(cursorPosition, 0, -suggestion.prefix.length)
    @editor.insertText suggestion.data.body

    # # Move the cursor behind the body
    # suffixLength = suggestion.data.body.length - suggestion.prefix.length
    # @editor.setSelectedBufferRange [startPosition, [startPosition.row, startPosition.column + suffixLength]]

    setTimeout(=>
      @editorView.trigger "autocomplete-plus:activate"
    , 100)

    return false # Don't fall back to the default behavior
