{CompositeDisposable} = require 'atom'
SymbolsModel = require './symbols-model'
{Emitter} = require 'atom'
NodesSymbolsListView = require './nodes_symbols_list_view'
AutoComleteProvider = require './auto_complete_provider'
{TextEditor} = require 'atom'
{TextEditorView} = require 'atom-space-pen-views'
ConsoleView = require './console_view'
path = require 'path'

module.exports = DataTags =
  subscriptions: null

  config:
    cli_path:
      title: 'CLI Path'
      description: 'Enter the absolute path to the CLI jar file'
      type: 'string'
      default: path.resolve(__dirname, '..', 'cli', 'DataTagsLib.jar')

  serialize: ->

  activate: (state) ->
    @symbols_model = new SymbolsModel #this is the symbol index object
    @provider = new AutoComleteProvider(@symbols_model) #this is DataTags provider for autocomplete package
    @ConsoleView =new ConsoleView(@symbols_model)

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
      #each time the user changed the buffer/file content then symbols needs to be re-index
      @subscriptions.add editor.onDidStopChanging (event) =>
        @symbols_model.invalidate()

    #each time the project root is changed then we need to re-index the symbols in the project
    @subscriptions.add atom.project.onDidChangePaths( (path)->DataTags.symbols.generateSymbolsListsInProject())

  OpenCLIPanel: ->
    console.log "CLI panel was toggeld"
    if (not @symbols_model.TagSpacePath?.length) and (not @symbols_model.DesicionGraphPath?.length)
      atom.notifications.addError("Invaliad Project Direcotry", dismissable: true ,detail: "Current Prjoect Direcotry doesn't contain a .TS or .DG file")
      return
    @ConsoleView.toggle()

  createNodeSymbolListView: ->
    unless @NodesSymbolsListView?
      NodesSymbolsListView = require './nodes_symbols_list_view'
      @NodesSymbolsListView =new NodesSymbolsListView(@symbols_model)
    @NodesSymbolsListView

  toggle: ->
    console.log "DataTags was activated"

  deactivate: ->
    @DescriptionPanel.destroy()
    @symbols_model.destroy()
    @subscriptions.dispose()
    @DescriptionView.destroy()
    @ConsoleView.destroy()

  provide: ->
    @provider
