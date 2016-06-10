{CompositeDisposable} = require 'atom'
fs = require 'fs-plus'
_  = require 'underscore-plus'
path = require 'path'

pkgRoot = atom.packages.resolvePackagePath('fuzzy-finder')
FuzzyFinderView = require path.join(pkgRoot, 'lib', 'fuzzy-finder-view')

class Entries
  add: (filePath) ->
    items = @getItems()
    items.unshift(filePath)
    items = _.uniq(items)
    items.splice(atom.config.get('recent-finder.max'))
    @save(items)

  save: (items) ->
    localStorage['recent-finder'] = JSON.stringify(items)

  clear: ->
    @save([])

  getItems: ->
    if items = localStorage['recent-finder']
      try
        _.filter(JSON.parse(items), (item) -> fs.existsSync(item))
      catch
        []
    else
      []

class View extends FuzzyFinderView
  toggle: (items) ->
    if @panel?.isVisible()
      @cancel()
    else
      @setItems(items)
      @show()

  getEmptyMessage: (itemCount) ->
    if itemCount is 0
      'No file opend recently'
    else
      super

notifyAndDeleteSettings = (scope, params...) ->
  hasParam = (param) ->
    param of atom.config.get(scope)

  paramsToDelete = (param for param in params when hasParam(param))
  return if paramsToDelete.length is 0

  content = [
    "#{scope}: Config options deprecated.  ",
    "Automatically removed from your `connfig.cson`  "
  ]

  for param in paramsToDelete
    atom.config.set("#{scope}.#{param}", undefined)
    content.push "- `#{param}`"
  atom.notifications.addWarning(content.join("\n"), dismissable: true)

module.exports =
  entries: null
  config:
    max:
      type: 'integer'
      default: 50
      minimum: 1
      description: "max number of entries to remember"

  activate: ->
    notifyAndDeleteSettings('recent-finder', 'syncImmediately')

    @entries = new Entries
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.workspace.onDidOpen ({item}) =>
      @entries.add(filePath) if filePath = item.getPath?()

    atom.commands.add 'atom-workspace',
      'recent-finder:toggle': => @getView().toggle(@entries.getItems())
      'recent-finder:clear': => @entries.clear()

  deactivate: ->
    @view?.destroy()
    @entries.save()
    @subscriptions.dispose()
    {@view, @subscriptions, @entries} = {}

  # I can't depend on serialize/desilialize since its per-project based.
  # serialize: ->

  getView:  ->
    @view ?= new View
