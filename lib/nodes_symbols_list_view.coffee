{SelectListView} = require 'atom-space-pen-views'

module.exports = class NodesSymbolsListView extends SelectListView
  initialize:  (symbol_indexer)->
    super
    @panel = atom.workspace.addModalPanel(item: this, visible: false)
    @addClass('nodes-symbols-view')
    @Symbol_index=symbol_indexer
    @setLoading("Nodes in Project")
    #@setItems(symbols)
    #@focusFilterEditor()

  viewForItem: (item) ->
    "<li>#{item.name}</li>"

  confirmed: (item) ->
    console.log("#{item.name} was selected")
    @Symbol_index.showInEditor(item)
    @cancel()


  cancel: ->
    console.log("This view was cancelled")
    @panel.hide()

  destroy: ->
    @cancel()
    @panel.destroy()

  toggle: ->
    if @panel.isVisible()
      @cancel()
    else
      @populate()
      @attach()

  populate: ->
    console.log("populating node symbol list")
    @setItems(@Symbol_index.getNodeSymbols())

  getFilterKey: ->
    'name'

  cancelled: ->
    @panel.hide()

  attach: ->
    @storeFocusedElement()
    @panel.show()
    @focusFilterEditor()
