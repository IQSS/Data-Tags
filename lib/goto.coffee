FS = require 'fs'
PATH = require 'path'
{Point} = require 'atom'

module.exports = class Goto

  constructor: ->
    @symbols = []

  gotoSymbol: ->
    @symbols= []
    word = @getWord()
    console.log "searching for symbol #{word}"
    project_dirs = atom.project.getDirectories()
    for dir in project_dirs
      dir_path= dir.getRealPathSync()
      console.log "dir path:#{dir_path}"
      @processDirectory dir_path

    matched_symbol = @matchSymbol(word,@symbols)
    if matched_symbol then @showInEditor(matched_symbol)

  processDirectory: (dirPath) ->
    entries = FS.readdirSync(dirPath)
    for entry in entries
      filePath = PATH.join(dirPath, entry)
      stats = FS.statSync(filePath)
      if stats.isFile()
        ext = PATH.extname(filePath)
        if ext in ['.ts','.dg']
          @processFile(filePath)

  processFile: (filePath) ->
    text = FS.readFileSync(filePath, { encoding: 'utf8' })
    grammar = atom.grammars.selectGrammar(filePath, text)
    #Array::push.apply @symbols,@getAllSymbolsFromFile(filePath, grammar, text)
    for symbol in @getAllSymbolsFromFile(filePath, grammar, text)
      @symbols.push symbol

  getWord: ->
    editor = atom.workspace.getActiveTextEditor()
    # Make a word selection based on current cursor
    editor?.selectWordsContainingCursors()
    word = editor?.getSelectedText()
    return null if not word?.length
    word

  getAllSymbolsFromFile:(path,grammar,text) ->
    symbols =  []
    lines   = grammar.tokenizeLines(text)
    for tokens, lineno in lines
      offset = 0
      for token in tokens
        if @isSymbol(token)
          symbol = @cleanSymbol(token)
          if symbol
            console.log "found a symbol |#{symbol}|!"
            symbols.push({ name: token.value, path: path, position: new Point(lineno, offset)})
        offset += token.value.length
    symbols

  cleanSymbol : (token) ->
    # Return the token name.  Will return null if symbol is not a valid name.
    name = token.value.trim().replace(/"/g, '')
    name || null

  isSymbol : (token) ->
    resym = /// ^ (
      entity.name.tag.tags.slot|
      markup.italic.tags.var|
      constant.character.escape.tags
      ) ///
    if token.value.trim().length and token.scopes
      for scope in token.scopes
        if resym.test(scope)
          return true
    return false

  matchSymbol: (word, symbols) ->
    if symbols
      for symbol in symbols
        if symbol.name is word
          return symbol

  showInEditor : (symbol) ->
    options = {initialLine : symbol.position.row , initialColumn : symbol.position.column}
    atom.workspace.open(symbol.path,options)
    editor = atom.workspace.getActiveTextEditor()
    console.log editor
    editor.selectToEndOfWord()
