{CompositeDisposable} = require 'atom'



module.exports =
class DescriptionView
  constructor: () ->
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


  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()
    @symbol_name.remove()
    @desc.remove()

  getElement: ->
    @element

  setMessage: (symbol,desc) ->
    @symbol_name.textContent = "Description for : "+symbol
    @desc.textContent = desc
