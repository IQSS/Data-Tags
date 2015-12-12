DataTagsView = require './data-tags-view'
{CompositeDisposable} = require 'atom'
GOTO = require './goto'

module.exports = DataTags =
  dataTagsView: null
  modalPanel: null
  subscriptions: null
  goto: null

  activate: (state) ->
    @goto = new GOTO
    @dataTagsView = new DataTagsView(state.dataTagsViewState)
    #@modalPanel = atom.workspace.addBottomPanel(item: @dataTagsView.getElement())

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace',
    {
      'data-tags:toggle': => @toggle()
      'data-tags:goto' : => @gotosymbol()
    }

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @dataTagsView.destroy()

  serialize: ->
    dataTagsViewState: @dataTagsView.serialize()

  toggle: ->
    console.log 'DataTags was toggled!'

  gotosymbol: ->
    @goto.gotoSymbol()
