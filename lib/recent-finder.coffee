{CompositeDisposable} = require 'atom'
_ = require 'underscore-plus'
fs = require 'fs-plus'

module.exports = RecentFinder =
  entries: null
  db: localStorage
  config:
    max:
      type: 'integer'
      default: 50
      minimum: 1
      description: "max number of entries to remember"
    syncImmediately:
      type: 'boolean'
      default: true
      description: "If true, save recent entries to localStorage on every file open and always read etnries from localStorage. If you want to sync entries across multiple atom windows immediately, this option is for you."

  activate: (state) ->
    @entries = @loadData()

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.workspace.onDidOpen (event) =>
      @addRecent event.item.getPath()

    atom.commands.add 'atom-workspace',
      'recent-finder:toggle': =>
        @getView().toggle @getEntries()
      'recent-finder:clear': =>
        @entries = []
        @saveData @entries

  loadData: ->
    if localStorage['recent-finder']
      JSON.parse localStorage['recent-finder']
    else
      []

  saveData: (data) ->
    localStorage['recent-finder'] = JSON.stringify data

  getEntries: ->
    if atom.config.get('recent-finder.syncImmediately')
      @entries = @loadData()
    (e for e in @entries when fs.existsSync e)

  addRecent: (path) ->
    limit = atom.config.get('recent-finder.max')
    entries = @getEntries()
    entries.unshift path
    @entries = _.uniq(entries).slice(0, limit)
    if atom.config.get('recent-finder.syncImmediately')
      @saveData @entries

  deactivate: ->
    if @view?
      @view.destroy()
      @view = null
    @saveData @entries
    @subscriptions.dispose()

  # I won't depend on serialize/desilialize since its per-project based.
  serialize: ->

  getView:  ->
    unless @view?
      RecentFinderView  = require './recent-finder-view'
      @view = new RecentFinderView
    @view
