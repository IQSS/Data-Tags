#this is DataTags provider for autocomplete package
#The API of provider for autocomplete package :
#   @must include getSuggestions: ({editor, bufferPosition, scopeDescriptor})  implementation
module.exports =
class AutoComleteProvider
  selector: '.source.tags'
  disableForSelector: '.comment, .string'

  #a Regex for autocomplete SlotName Symbol
  Setregex = /\[\s*set\s*:(\s*[\w0-9_-]*)$/ #atom.config

  #a Regex for autocomplete SlotValue Symbol
  Slotregex = /([\w0-9_-]+)(\s*)(=|\+=)(\s*)$/ #atom.config

  #a Regex for autocomplete Node Symbol
  Callregex = /\[\s*call\s*:(\s*[\w0-9_-]*)$/ #atom.config

  constructor: (symbols) ->
    @symbols_index=symbols

  #this method return the suggestions list that the user will see
  #there are there types of suggestions: Node,SlotName,SlotValue
  #each according suggestions are proposed according to the current scope
  #the user is currently tying in aka like typing  [ call: ]
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

  #this method acctually create the suggestions list according to prefix
  #the method receive all the symbols associated with this type
  findSuggestionsForPrefix: (symbols, prefix,type) ->
    suggestions = []
    prefix = prefix.replace /^\s+|\s+$/g, ""
    prefix = prefix.toLowerCase()
    if !!prefix
      for symbol in symbols
        if symbol.name.toLowerCase().indexOf(prefix) != -1
          suggestions.push({text: symbol.name , leftLabel: type ,description: symbol.desc})
    else
      for symbol in symbols
        suggestions.push({text: symbol.name , leftLabel: type ,description: symbol.desc})
    suggestions

  #this method is used for changing current prefix with line prefix and matched it
  #to one of the three types prefix we are searching
  #if found a match this method return the prefix of the symbol currently typing
  getPrefix: (editor, bufferPosition,regex) ->
    line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])
    line.match(regex)?[1] or null
