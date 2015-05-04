fs = require 'fs-plus'
_  = require 'underscore-plus'

module.exports =
class Entries
  constructor: () ->
    @_data = @load()

  add: (path) ->
    return unless fs.existsSync path
    limit = atom.config.get('recent-finder.max')
    data = @get()
    data.unshift path
    @set _.uniq(data).slice(0, limit)

  set: (data, sync=@needSync()) ->
    @save data if sync
    @_data = data

  needSync: ->
    atom.config.get 'recent-finder.syncImmediately'

  clear: ->
    @set [], true

  get: (sync=@needSync()) ->
    @_data = @load() if sync
    @_data

  save: (data) ->
    data = _.filter data, (e) -> fs.existsSync e
    localStorage['recent-finder'] = JSON.stringify data

  load: ->
    if localStorage['recent-finder']
      JSON.parse localStorage['recent-finder']
    else
      []
