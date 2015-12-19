DataTagsView = require './data-tags-view'
{CompositeDisposable} = require 'atom'
Symbols = require './symbols'


module.exports = DataTags =
  dataTagsView: null
  modalPanel: null
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
      'data-tags:ShowPanel': => @ShowPanel()
      'data-tags:goto' : => @gotosymbol()
      'data-tags:show-desc': => @showDescription()
    }


  deactivate: ->
    @Panel.destroy()
    @subscriptions.dispose()
    @dataTagsView.destroy()

  serialize: ->
    dataTagsViewState: @dataTagsView.serialize()

  ShowPanel: ->
    console.log 'DataTags was toggled!'
    if @Panel.isVisible()
      @Panel.hide()
    else
      @Panel.show()

  gotosymbol: ->
    word = @getWord()
    console.log "searching for symbol #{word}"
    #TBD valid data checks
    @symbols.generateSymbolsListsInProject()
    matched_symbol = @symbol.matchSymbol(word)
    if matched_symbol then @showInEditor(matched_symbol)

  showInEditor : (symbol) ->
    options = {initialLine : symbol.position.row , initialColumn : symbol.position.column}
    atom.workspace.open(symbol.path,options)
    editor = atom.workspace.getActiveTextEditor()
    console.log symbol
    editor.selectToEndOfWord()

  showDescription: ->
    console.log 'showDescription was toggled!'
    if @Panel.isVisible()
      @Panel.hide()
    else
      @Panel.show()
    symbol = @getWord()
    desc =@symbols.getDesc(symbol)
    @dataTagsView.setMessage(symbol,desc)

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
