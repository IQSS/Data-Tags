DataTagsView = require './data-tags-view'
{CompositeDisposable} = require 'atom'
Symbols = require './symbols'
{Emitter} = require 'atom'
NodesSymbolsListView = require './nodes_symbols_list_view'
SlotsProvider = require './auto_complete_provider'

module.exports = DataTags =
  dataTagsView: null
  subscriptions: null
  symbols: null

  activate: (state) ->
    @symbols = new Symbols
    @dataTagsView = new DataTagsView(state.dataTagsViewState)
    @Panel = atom.workspace.addBottomPanel(item: @dataTagsView.getElement(),visible: false)
    @Console = atom.workspace.addBottomPanel(item: @dataTagsView.getConsoleView(),visible: true)

    @provider = new SlotsProvider(@symbols)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace',
    {
      'data-tags:toggle' : => @toggle()
      'data-tags:goto' : => @gotosymbol()
      'data-tags:show-desc': => @showDescriptionPanel()
      'data-tags:show_node': => @createNodeSymbolListView().toggle()
    }

    #@emitter.on 'selection:changed' , => console.log "shit"
    atom.workspace.observeTextEditors (editor) =>
      @subscriptions.add editor.onDidChangeSelectionRange (event) =>
          word = event.selection.getText()
          if !!word
            start= event.selection.getBufferRange().start
            scopes = atom.workspace.getActiveTextEditor().scopeDescriptorForBufferPosition(start).scopes
            scope = scopes[scopes.length-1]
            if scope in ['entity.name.tag.tags.ass.left','markup.italic.tags.ass.right']
              desc =@symbols.getDesc(word)
              @dataTagsView.setMessage(word,desc)
              @Panel.show()
            else @Panel.hide()
          else @Panel.hide()
      @subscriptions.add editor.onDidStopChanging (event) =>
        @symbols.invalidate()

    @subscriptions.add atom.project.onDidChangePaths( (path)->DataTags.symbols.invalidate())



  createNodeSymbolListView: ->
    unless @NodesSymbolsListView?
      NodesSymbolsListView = require './nodes_symbols_list_view'
      @NodesSymbolsListView =new NodesSymbolsListView(@symbols)
    @NodesSymbolsListView

  toggle: ->
    console.log "DataTags was activated"

  deactivate: ->
    @Panel.destroy()
    @symbols.destroy()
    @subscriptions.dispose()
    @dataTagsView.destroy()

  serialize: ->
    dataTagsViewState: @dataTagsView.serialize()

  ShowNodesList: ->
    console.log "show node was toggled"
    #if !@NodesSymbolsListView.panel.isVisible
    @NodesSymbolsListView.panel.show()


  gotosymbol: ->
    word = @getWord()
    #console.log "searching for symbol #{word}"
    matched_symbol = @symbols.matchSymbol(word)
    if matched_symbol then @symbols.showInEditor(matched_symbol)


  showDescriptionPanel: ->
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

  provide: ->
    @provider
