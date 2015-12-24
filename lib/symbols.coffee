FS = require 'fs'
PATH = require 'path'
{Point} = require 'atom'

module.exports = class Symbols

  constructor: ->
    @slots_symbols = []
    @nodes_symbols= []
    @invalid = true
    @generateSymbolsListsInProject()

  generateSymbolsListsInProject: ->
    @slots_symbols = []
    @nodes_symbols= []
    project_dirs = atom.project.getDirectories()
    for dir in project_dirs
      dir_path= dir.getRealPathSync()
      console.log "dir path:#{dir_path}"
      @processDirectory dir_path
    @invalid =false

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
    @getAllSymbolsFromFile(filePath, grammar, text)

  getAllSymbolsFromFile:(path,grammar,text) ->
    lines   = grammar.tokenizeLines(text)
    prev_is_symbol =false
    for tokens, lineno in lines
      offset = 0
      for token in tokens

        if @isSlotSymbol(token)
          symbol = @cleanSymbol(token)
          if symbol
            @slots_symbols.push({ name: token.value, path: path, position: new Point(lineno, offset), desc: "There is no Description"})
        else if @isNodeSymbol(token)
          symbol = @cleanSymbol(token)
          if symbol
            @nodes_symbols.push({ name: token.value, path: path, position: new Point(lineno, offset)})

        else if @isDesc(token)
          #console.log "found a desc"
          @slots_symbols[@slots_symbols.length-1].desc=token.value
          #console.log @slots_symbols[@slots_symbols.length-1]

        offset += token.value.length

  cleanSymbol : (token) ->
    # Return the token name.  Will return null if symbol is not a valid name.
    name = token.value.trim().replace(/"/g, '')
    name || null

  isSlotSymbol : (token) ->
    resym = /// ^ (
      entity.name.tag.tags.slot.def|
      markup.italic.tags.var
      ) ///
    if token.value.trim().length and token.scopes
      for scope in token.scopes
        if resym.test(scope)
          return true
    return false

  isNodeSymbol : (token) ->
    resym = /// ^ (
      constant.character.escape.tags
      ) ///
    if token.value.trim().length and token.scopes
      for scope in token.scopes
        if resym.test(scope)
          return true
    return false

  isDesc : (token) ->
    resym = /// ^ (
      source.tags.note.content
      ) ///
    if token.value.trim().length and token.scopes
      for scope in token.scopes
        if resym.test(scope)
          return true
    return false

  matchSymbol: (word) ->
    if @slots_symbols
      for symbol in @slots_symbols
        if symbol.name is word
          return symbol
    if @nodes_symbols
      for symbol in @nodes_symbols
        if symbol.name is word
          return symbol

  getDesc: (symbol) ->
    console.log "Searching description for #{symbol}"
    if @invalid then @generateSymbolsListsInProject()
    matched_symbol = @matchSymbol(symbol)
    if matched_symbol?
      matched_symbol.desc
    else
      "There is Description for #{symbol}"

  invalidate: ->
    @invalid=true
