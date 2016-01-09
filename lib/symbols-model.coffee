FS = require 'fs'
PATH = require 'path'
{Point} = require 'atom'

module.exports = class SymbolsModel

  constructor: ->
    @slots_symbols = []
    @nodes_symbols= []
    @value_symbols=[]
    @DesicionGraphPath=''
    @TagSpacePath=''
    @invalid = true
    @generateSymbolsListsInProject()

  generateSymbolsListsInProject: ->
    @slots_symbols = []
    @nodes_symbols= []
    @value_symbols=[]
    project_dirs = atom.project.getDirectories()
    for dir in project_dirs
      dir_path= dir.getRealPathSync()
      #console.log "dir path:#{dir_path}"
      @processDirectory dir_path
    @invalid =false

  processDirectory: (dirPath) ->
    entries = FS.readdirSync(dirPath)
    for entry in entries
      filePath = PATH.join(dirPath, entry)
      stats = FS.statSync(filePath)
      if stats.isFile()
        ext = PATH.extname(filePath)
        if ext == '.ts'
          @processFile(filePath)
          @TagSpacePath = filePath
        if ext == '.dg'
          @processFile(filePath)
          @DesicionGraphPath = filePath

  processFile: (filePath) ->
    for editor in atom.workspace.getTextEditors()
      if editor.getPath() == filePath
        text = editor.getText()
      else
        text = FS.readFileSync(filePath, { encoding: 'utf8' })
    grammar = atom.grammars.selectGrammar(filePath, text)
    @getAllSymbolsFromFile(filePath, grammar, text)

  getAllSymbolsFromFile:(path,grammar,text) ->
    lines   = grammar.tokenizeLines(text)
    last_symbols_used= null
    for tokens, lineno in lines
      offset = 0
      for token in tokens

        if @isSlotSymbol(token,path)
          symbol = @cleanSymbol(token)
          if symbol
            @slots_symbols.push({ name: token.value, path: path, position: new Point(lineno, offset), desc: "There is no Description" ,values: []})
            last_symbols_used =@slots_symbols

        else if @isValueSymbol(token,path)
          symbol = @cleanSymbol(token)
          if symbol
            element = { name: token.value, path: path, position: new Point(lineno, offset), desc: "There is no Description"}
            @value_symbols.push(element)
            @slots_symbols[@slots_symbols.length-1].values.push(element)
            last_symbols_used =@value_symbols

        else if @isNodeSymbol(token,path)
          symbol = @cleanSymbol(token)
          if symbol
            #console.log "found node #{token.value} in [#{lineno},#{offset}] in file #{path}"
            @nodes_symbols.push({ name: token.value, path: path, position: new Point(lineno, offset)})
            last_symbols_used =@nodes_symbols

        else if @isDesc(token,path)
          #console.log "found a desc"
          last_symbols_used[last_symbols_used.length-1].desc=token.value
          #console.log @slots_symbols[@slots_symbols.length-1]

        offset += token.value.length

  cleanSymbol : (token) ->
    # Return the token name.  Will return null if symbol is not a valid name.
    name = token.value.trim().replace(/"/g, '')
    name || null

  isValueSymbol : (token,filePath) ->
    resym = /// ^ (
      markup.italic.tags.var
      ) ///
    if PATH.extname(filePath) != ".ts"
      return false
    if token.value.trim().length and token.scopes
      for scope in token.scopes
        if resym.test(scope)
          return true
    return false

  isSlotSymbol : (token,filePath) ->
    resym = /// ^ (
      entity.name.tag.tags.slot.def
      ) ///
    if PATH.extname(filePath) != ".ts"
      return false
    if token.value.trim().length and token.scopes
      for scope in token.scopes
        if resym.test(scope)
          return true
    return false

  isNodeSymbol : (token,filePath) ->
    resym = /// ^ (
      constant.character.escape.tags
      ) ///
    if PATH.extname(filePath) != ".dg"
      return false
    if token.value.trim().length and token.scopes
      for scope in token.scopes
        if resym.test(scope)
          return true
    return false

  isDesc : (token,filePath) ->
    resym = /// ^ (
      source.tags.note.content
      ) ///
    if PATH.extname(filePath) != ".ts"
      return false
    if token.value.trim().length and token.scopes
      for scope in token.scopes
        if resym.test(scope)
          return true
    return false

  matchSymbol: (word) ->
    if @invalid then @generateSymbolsListsInProject()
    if @slots_symbols
      for symbol in @slots_symbols
        if symbol.name is word
          return symbol
    if @nodes_symbols
      for symbol in @nodes_symbols
        if symbol.name is word
          return symbol
    if @value_symbols
      for symbol in @value_symbols
        if symbol.name is word
          return symbol

  getDesc: (symbol) ->
    #console.log "Searching description for #{symbol}"
    matched_symbol = @matchSymbol(symbol)
    if matched_symbol?
      matched_symbol.desc
    else
      "There is no Description for #{symbol}"

  invalidate: ->
    console.log "symbols are now invalid"
    @invalid=true

  getNodeSymbols: ->
    if @invalid then @generateSymbolsListsInProject()
    @nodes_symbols

  getSlotsSymbols: ->
    if @invalid then @generateSymbolsListsInProject()
    @slots_symbols

  getSlotValueSymbols: ->
    if @invalid then @generateSymbolsListsInProject()
    @value_symbols

  showInEditor : (symbol) ->
    options = {initialLine : symbol.position.row , initialColumn : symbol.position.column}
    atom.workspace.open(symbol.path,options)
    editor = atom.workspace.getActiveTextEditor()
    #console.log symbol
    editor.selectToEndOfWord()
