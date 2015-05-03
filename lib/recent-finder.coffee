{CompositeDisposable} = require 'atom'
_ = require 'underscore-plus'
fs = require 'fs-plus'

module.exports = RecentFinder =
  config:
    max:
      type:    'integer'
      default: 100
      minimum: 1

  activate: (state) ->
    @recentEntries = if state then state.data else []
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.workspace.onDidOpen (event) =>
      @addRecent event.item.getPath()

    atom.commands.add 'atom-workspace',
      'recent-finder:toggle': =>
        @createRecentFinderView().toggle(@getRecent())

  getRecent: ->
    (e for e in @recentEntries when fs.existsSync e)

  addRecent: (path) ->
    # console.log path
    @recentEntries.unshift path
    limit = atom.config.get('recent-finder:max')
    @recentEntries = _.uniq(@recentEntries).slice(0, limit)
    # console.log @recentEntries

  deactivate: ->
    if @recentFinderView?
      @recentFinderView.destroy()
      @recentFinderView = null
    @subscriptions.dispose()

  serialize: ->
    @recentEntries = (e for e in @recentEntries when fs.existsSync e)
    data: @recentEntries

  createRecentFinderView:  ->
    unless @recentFinderView?
      RecentFinderView = require './recent-finder-view'
      @recentFinderView = new RecentFinderView @recentEntries
    @recentFinderView
