{View ,TextEditorView} = require 'atom-space-pen-views'
path = require 'path'
{BufferedProcess, Point} = require 'atom'

module.exports =
class ConsoleView
  CLI= null
  Panel = null
  consoleElement =null
  editor =null
  SymbolIndexer = null

  constructor: (symbol_indexer) ->
    SymbolIndexer= symbol_indexer
    @root = document.createElement('div')

    consoleElement = document.createElement('textarea')
    consoleElement.classList.add('console-view')
    consoleElement.setAttribute('id','console')
    consoleElement.readOnly=true
    @root.appendChild(consoleElement)

    header = document.createElement('div')
    header.textContent = "Type your answer:"
    @root.appendChild(header)

    editor = document.createElement('atom-text-editor')
    editor.setAttribute('mini',true)
    @root.appendChild(editor)

    editor.addEventListener 'keydown', @InsertTextToConsole

    Panel=atom.workspace.addBottomPanel({item: @root , visible: false})

  CreateCLIProcess: ->
    command ="java"
    jar_path = atom.config.get('data-tags.cli_path')

    args=['-jar',jar_path,SymbolIndexer.TagSpacePath,SymbolIndexer.DesicionGraphPath]


    stderr = (lines) ->
      atom.notifications.addError("CLI Error", dismissable: true ,detail: lines)
      CLI.kill()
      Panel.hide()
      consoleElement.textContent = ""
      editor.model.setText("")

    exit = (code) -> console.log("The process exited with code: #{code}")
    process = new BufferedProcess({command, args,stderr,exit})
    CLI = process.process
    CLI.stdin.setEncoding('utf8')
    CLI.stdout.on('data' , (data) ->
      #console_element = document.getElementById('console')
      consoleElement.textContent+= data
      consoleElement.scrollTop = consoleElement.scrollHeight
    )
    #CLI.stderr.on('data' , (data) ->
    #  atom.notifications.addError("CLI Error", dismissable: true ,detail: data)
    #  ConsoleView.onConsoleError()
    #)

  InsertTextToConsole: (event) ->
    if event.keyCode == 13 #enter ==13
      text = editor.model.getText()+'\n'
      editor.model.setText("")
      #console_element = document.getElementById('console')
      consoleElement.textContent  += text
      consoleElement.scrollTop = consoleElement.scrollHeight
      CLI.stdin.write(text)

  resetCLI: ()->
    console.log "reseting console"
    CreateCLIProcess()
    consoleElement.textContent = ""
    editor.setText= ""

  toggle: ->
    if Panel.isVisible()
      CLI.stdin.write('\\quit\n') # shutting process gracefully first if no error occured
      CLI.kill()
      Panel.hide()
      consoleElement.textContent = ""
      editor.setText= ""
    else
      @CreateCLIProcess()
      Panel.show()

  destroy: ->
    Panel.hide()
    CLI.kill()
    @root.remove()
    @editor.remove()
    @console.remove()
    Panel.destroy()
