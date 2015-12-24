DataTagsView = require './data-tags-view'
{CompositeDisposable} = require 'atom'
Symbols = require './symbols'
{Emitter} = require 'atom'

module.exports = DataTags =
  dataTagsView: null
  subscriptions: null
  symbols: null

  activate: (state) ->
    @symbols = new Symbols
    @dataTagsView = new DataTagsView(state.dataTagsViewState)
    @Panel = atom.workspace.addBottomPanel(item: @dataTagsView.getElement(),visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace',
    {
      'data-tags:toggle' : => @toggle()
      'data-tags:goto' : => @gotosymbol()
      'data-tags:show-desc': => @showDescription()
    }

    #@emitter.on 'selection:changed' , => console.log "shit"
    atom.workspace.observeTextEditors (editor) =>
      @subscriptions.add editor.onDidChangeSelectionRange (event) =>
          word = event.selection.getText()
          if !!word
            start= event.selection.getBufferRange().start
            scopes = atom.workspace.getActiveTextEditor().scopeDescriptorForBufferPosition(start).scopes
            scope = scopes[scopes.length-1]
            console.log scopes
            if scope in ['entity.name.tag.tags.ass.left','markup.italic.tags.ass.right']
              desc =@symbols.getDesc(word)
              @dataTagsView.setMessage(word,desc)
              @Panel.show()
            else @Panel.hide()
          else @Panel.hide()
      @subscriptions.add editor.onDidStopChanging (event) =>
        console.log event
  toggle: ->
    console.log "DataTags was activated"

  deactivate: ->
    @Panel.destroy()
    @symbols.destroy()
    @subscriptions.dispose()
    @dataTagsView.destroy()

  serialize: ->
    dataTagsViewState: @dataTagsView.serialize()

  gotosymbol: ->
    word = @getWord()
    console.log "searching for symbol #{word}"
    #TBD valid data checks
    if @symbols.invalid then @symbols.generateSymbolsListsInProject()
    matched_symbol = @symbols.matchSymbol(word)
    if matched_symbol then @showInEditor(matched_symbol)

  showInEditor : (symbol) ->
    options = {initialLine : symbol.position.row , initialColumn : symbol.position.column}
    atom.workspace.open(symbol.path,options)
    editor = atom.workspace.getActiveTextEditor()
    console.log symbol
    editor.selectToEndOfWord()

  showDescription: ->
    if @Panel.isVisible()
      @Panel.hide()
    else
      @Panel.show()

  getWord: ->
    editor = atom.workspace.getActiveTextEditor()
    # Make a word selection based on current cursor
    editor?.selectWordsContainingCursors()
    word = editor?.getSelectedText()
    return null if not word?.length
    symbol_scope=editor.scopeDescriptorForBufferPosition(editor.getCursorBufferPositions()[0])
    #symbol_scope=editor.getCursorBufferPositions()[0]
    console.log symbol_scope
    word
