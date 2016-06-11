openFiles = (filePaths...) ->
  waitsForPromise ->
    promises = (atom.workspace.open(filePath) for filePath in filePaths)
    Promise.all(promises)

describe "recent-finder", ->
  [main] = []
  [pathFile1, pathFile2, pathFile3] = []

  getAllItems = ->
    main.history.getAllItems()

  beforeEach ->
    pathFile1 = atom.project.resolvePath('file1')
    pathFile2 = atom.project.resolvePath('file2')
    pathFile3 = atom.project.resolvePath('file3')
    waitsForPromise ->
      atom.packages.activatePackage('recent-finder').then (pack) ->
        main = pack.mainModule
        main.history.clear()

  afterEach ->
    main.history.clear()

  describe "initial state", ->
    it "history is empty", ->
      expect(getAllItems()).toHaveLength(0)

  describe "when file opened", ->
    it "add filePath to history", ->
      openFiles(pathFile1, pathFile2, pathFile3)
      runs ->
        expect(getAllItems()).toHaveLength(3)
        expect(getAllItems()).toEqual([pathFile3, pathFile2, pathFile1])

  describe "duplicate entries in history", ->
    it "remove older entries", ->
      openFiles(pathFile1, pathFile2)
      runs ->
        expect(getAllItems()).toHaveLength(2)
        expect(getAllItems()).toEqual([pathFile2, pathFile1])
      openFiles(pathFile1)
      runs ->
        expect(getAllItems()).toHaveLength(2)
        expect(getAllItems()).toEqual([pathFile1, pathFile2])

  describe "recent-finder.max setting", ->
    beforeEach ->
      atom.config.set('recent-finder.max', 2)

    it "remove older entries", ->
      openFiles(pathFile1, pathFile2)
      runs ->
        expect(getAllItems()).toHaveLength(2)
        expect(getAllItems()).toEqual([pathFile2, pathFile1])
      openFiles(pathFile3)
      runs ->
        expect(getAllItems()).toHaveLength(2)
        expect(getAllItems()).toEqual([pathFile3, pathFile2])

  describe "recent-finder:clear command", ->
    it "clear history", ->
      openFiles(pathFile1, pathFile2, pathFile3)
      runs ->
        expect(getAllItems()).toHaveLength(3)
        expect(getAllItems()).toEqual([pathFile3, pathFile2, pathFile1])
        workspaceElement = atom.views.getView(atom.workspace)
        atom.commands.dispatch(workspaceElement, 'recent-finder:clear')
        expect(getAllItems()).toHaveLength(0)
        expect(getAllItems()).toEqual([])
