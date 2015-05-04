{CompositeDisposable} = require 'atom'
_ = require 'underscore-plus'
fs = require 'fs-plus'

class Entries
  constructor: () ->
    @data = @load()

  add: (path) ->
    limit = atom.config.get('recent-finder.max')
    @set _.uniq(@get().unshift path).slice(0, limit)

  set: (data, force) ->
    if atom.config.get('recent-finder.syncImmediately') or force
      @save data
    @data = data

  clear: ->
    @set [], true

  get: ->
    if atom.config.get('recent-finder.syncImmediately')
      @data = @load()
    @data

  save: (data) ->
    localStorage['recent-finder'] = JSON.stringify data

  saveExistsOnly: (data) ->
    @save (e for e in @get() when fs.existsSync e)

  load: ->
    if localStorage['recent-finder']
      JSON.parse localStorage['recent-finder']
    else
      []

module.exports = RecentFinder =
  entries: null
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
    @entries = new Entries

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.workspace.onDidOpen (event) =>
      @addRecent event.item.getPath()

    atom.commands.add 'atom-workspace',
      'recent-finder:toggle': => @getView().toggle @entries.get()
      'recent-finder:clear': => @entries.clear()

  addRecent: (path) ->
    if fs.existsSync path
      @entries.add path

  deactivate: ->
    if @view?
      @view.destroy()
      @view = null
    @entries.saveExistsOnly()
    @subscriptions.dispose()

  # I can't depend on serialize/desilialize since its per-project based.
  serialize: ->

  getView:  ->
    unless @view?
      RecentFinderView  = require './recent-finder-view'
      @view = new RecentFinderView
    @view
