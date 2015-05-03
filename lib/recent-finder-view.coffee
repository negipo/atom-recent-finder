path = require 'path'
fs   = require 'fs-plus'
packagePath = atom.packages.resolvePackagePath('fuzzy-finder')
FuzzyFinderView = require path.join(packagePath, 'lib', 'fuzzy-finder-view')

module.exports =
class RecentFinderView extends FuzzyFinderView
  toggle: (items) ->
    if @panel?.isVisible()
      @cancel()
    else
      @setItems []
      # console.log items
      @setItems items
      @show()

  getEmptyMessage: (itemCount) ->
    if itemCount is 0
      'No file opend recently'
    else
      super

  destroy: ->
