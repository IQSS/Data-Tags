DataTagsView = require './data-tags-view'
{CompositeDisposable} = require 'atom'

module.exports = DataTags =
  dataTagsView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @dataTagsView = new DataTagsView(state.dataTagsViewState)
    @modalPanel = atom.workspace.addBottomPanel(item: @dataTagsView.getElement())

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
    console.log 'going to symbol data-tags'
    editor = atom.workspace.getActiveTextEditor()
    # Make a word selection based on current cursor
    editor?.selectWordsContainingCursors()
    word = editor?.getSelectedText()
    return null if not word?.length

    editors = atom.workspace.getTextEditors()
    for editor in editors
      index = editor.getText().search RegExp("(#{word})( *)(\\[.*\\]){0,1}()*(:)")
      continue  if index is -1
      point = editor.getBuffer().positionForCharacterIndex index
      console.log "found a match #{point}"
      editor.scrollToBufferPosition point
      editor.setCursorBufferPosition point
      file = editor?.buffer.file
      filePath = file?.path
      atom.workspace.open(filePath)
      return null
