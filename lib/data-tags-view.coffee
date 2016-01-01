{CompositeDisposable} = require 'atom'



module.exports =
class DataTagsView
  constructor: (serializedState) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('data-tags')

    # Create message element
    @symbol_name = document.createElement('div')
    @symbol_name.textContent = ""
    @symbol_name.classList.add('symbol-name')
    @element.appendChild(@symbol_name)

    @desc = document.createElement('div')
    @desc.textContent = "Hightlight a symbol to see his description"
    @desc.classList.add('symbol-name')
    @element.appendChild(@desc)


    @conslole_element= document.createElement('div')
    @conslole_element.classList.add('console-view')
    @conslole_element.style.backgroundColor="black"
    @conslole_element.style.height = "250px"
    #console.log @element

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @subscriptions.dispose()
    @element.remove()
    @symbol_name.remove()
    @desc.remove()

  getElement: ->
    @element

  getConsoleView: ->
    @conslole_element

  setMessage: (symbol,desc) ->
    @symbol_name.textContent = "Description for : "+symbol
    @desc.textContent = desc
    #console.log @element

  setConsoleMessaga: (msg) ->
    @conslole_element.textContent = msg
