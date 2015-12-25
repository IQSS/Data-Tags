module.exports =
class SlotsProvider
  selector: '.source.tags'
  disableForSelector: '.comment, .string'
  Setregex = /\[\s*set\s*:(\s*[\w0-9_-]*)$/
  Slotregex = /([\w0-9_-]+)(\s*)(=|\+=)(\s*)$/
  Callregex = /\[\s*call\s*:(\s*[\w0-9_-]*)$/

  constructor: (symbols) ->
    @symbols_index=symbols
    #console.log "created provider"

  getSuggestions: ({editor, bufferPosition, scopeDescriptor}) ->
    prefix = @getPrefix(editor,bufferPosition,Callregex)
    if prefix? then return @findSuggestionsForPrefix(@symbols_index.getNodeSymbols(),prefix,"Node")

    prefix = @getPrefix(editor,bufferPosition,Setregex)
    if prefix? then return @findSuggestionsForPrefix(@symbols_index.getSlotsSymbols(),prefix,"Slot Name")

    slot_name = @getPrefix(editor,bufferPosition,Slotregex)
    if slot_name?
      suggestions = []
      slot_symbol=@symbols_index.matchSymbol(slot_name)
      for value in slot_symbol.values
        suggestions.push({text: value.name , leftLabel: "Slot Value" ,description: value.desc})
      return suggestions


  findSuggestionsForPrefix: (symbols, prefix,type) ->
    suggestions = []
    #console.log "prefix is |#{prefix}|"
    prefix = prefix.replace /^\s+|\s+$/g, ""
    prefix = prefix.toLowerCase()
    if !!prefix
      for symbol in symbols
        #console.log "symbol name #{symbol.name} , prefix is #{prefix} , index is #{symbol.name.toLowerCase().indexOf(prefix)}"
        if symbol.name.toLowerCase().indexOf(prefix) != -1
          suggestions.push({text: symbol.name , leftLabel: type ,description: symbol.desc})
    else
      for symbol in symbols
        suggestions.push({text: symbol.name , leftLabel: type ,description: symbol.desc})
    suggestions


  getPrefix: (editor, bufferPosition,regex) ->
    line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])
    #console.log "current match #{line.match(regex)}"
    line.match(regex)?[1] or null
