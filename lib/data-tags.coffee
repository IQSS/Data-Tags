DescriptionView = require './description-panel-view'
{CompositeDisposable} = require 'atom'
Symbols = require './symbols'
{Emitter} = require 'atom'
NodesSymbolsListView = require './nodes_symbols_list_view'
SlotsProvider = require './auto_complete_provider'
{TextEditor} = require 'atom'
{TextEditorView} = require 'atom-space-pen-views'
ConsoleView = require './console_view'

module.exports = DataTags =
  subscriptions: null

  serialize: ->

  activate: (state) ->
    @symbols = new Symbols #this is the symbol index object

    @DescriptionView = new DescriptionView()
    @DescriptionPanel = atom.workspace.addTopPanel(item: @DescriptionView.getElement(),visible: false)
    
    @provider = new AutoComleteProvider(@symbols) #this is DataTags provider for autocomplete package

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command
    @subscriptions.add atom.commands.add 'atom-workspace',
    {
      'data-tags:toggle' : => @toggle()
      'data-tags:goto' : => @gotosymbol()
      'data-tags:show_node': => @createNodeSymbolListView().toggle()
      'data-tags:open-cli' : =>@OpenCLIPanel()
    }

    #foreach TextEditor in opended we add the following events
    atom.workspace.observeTextEditors (editor) =>
      #each time the user mark a word a description panel will pop
      @subscriptions.add editor.onDidChangeSelectionRange (event) =>
          word = event.selection.getText()
          if !!word
            start= event.selection.getBufferRange().start
            scopes = atom.workspace.getActiveTextEditor().scopeDescriptorForBufferPosition(start).scopes
            scope = scopes[scopes.length-1]
            #Currently in DataTags language only Slots has description
            if scope in ['entity.name.tag.tags.ass.left','markup.italic.tags.ass.right'] #add to atom.config
              desc =@symbols.getDesc(word)
              @DescriptionView.setMessage(word,desc)
              @DescriptionPanel.show()
            else @DescriptionPanel.hide()
          else @DescriptionPanel.hide()

      #each time the user changed the buffer/file content then symbols needs to be re-index
      @subscriptions.add editor.onDidStopChanging (event) =>
        @symbols.invalidate()

    #each time the project root is changed then we need to re-index the symbols in the project
    @subscriptions.add atom.project.onDidChangePaths( (path)->DataTags.symbols.generateSymbolsListsInProject())

  OpenCLIPanel: ->
    console.log "CLI panel was toggeld"
    if (not @symbols.TagSpacePath?.length) and (not @symbols.DesicionGraphPath?.length)
      atom.notifications.addError("Invaliad Project Direcotry", dismissable: true ,detail: "Current Prjoect Direcotry doesn't contain a .TS or .DG file")
      return
    if @ConsoleView?
      @ConsoleView.destroy()
      @ConsoleView=null
    else
      @ConsoleView =new ConsoleView(@symbols)

  createNodeSymbolListView: ->
    unless @NodesSymbolsListView?
      NodesSymbolsListView = require './nodes_symbols_list_view'
      @NodesSymbolsListView =new NodesSymbolsListView(@symbols)
    @NodesSymbolsListView

  toggle: ->
    console.log "DataTags was activated"

  deactivate: ->
    @DescriptionPanel.destroy()
    @symbols.destroy()
    @subscriptions.dispose()
    @DescriptionView.destroy()
    @ConsoleView.destroy()


  gotosymbol: ->
    word = @getWord()
    #console.log "searching for symbol #{word}"
    matched_symbol = @symbols.matchSymbol(word)
    if matched_symbol then @symbols.showInEditor(matched_symbol)

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
