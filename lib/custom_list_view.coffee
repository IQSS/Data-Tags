module.exports =
class ListView
  constructor: (items) ->
    # Create root element
    @element = document.createElement('ul')
    @element.classList.add('list-group')
    #@element.style.border = "thick solid #0000FF";

    id=1
    for item in items
      # Create list element
      list_element = document.createElement('li')
      list_element.textContent = item
      list_element.classList.add('list-item')
      list_element.id = id
      @element.appendChild(list_element)
      list_element.addEventListener("dblclick", (event) => @myScript(event.target.textContent) );
      id++

    console.log @element

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @subscriptions.dispose()
    @element.remove()

  getList: ->
    @element

  myScript : (element) ->
    console.log element
    document.getElementById(element).style.color = "red"
