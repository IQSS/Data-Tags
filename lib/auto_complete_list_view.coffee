{SelectListView} = require 'atom-space-pen-views'

module.exports = class MyList extends SelectListView
 initialize:  (items)->
   super
   @addClass('overlay from-top')
   @setItems(items)
   @focusFilterEditor()

 viewForItem: (item) ->
   "<li>#{item}</li>"

 confirmed: (item) ->
   console.log("#{item} was selected")

 cancelled: ->
   console.log("This view was cancelled")
