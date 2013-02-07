# Get alias for the global scope
globals = @

describe "gamEvolve", ->
  beforeEach ->
    @addMatchers 
      toDeeplyEqual: (expected) -> _.isEqual(@actual, expected)
      toBeEmpty: (expected) -> expected.length == 0

  describe "model", ->
    it "can be created empty", ->
      model = new GE.Model()
      expect(model.version).toEqual(0)
      expect(model.data).toDeeplyEqual({})

    it "can be created with data", ->
      model = new GE.Model({a: 1, b: 2})
      expect(model.version).toEqual(0)
      expect(model.data).toDeeplyEqual({a: 1, b: 2})

    it "can be patched", ->
      # Create old data, new data, and the patches between
      oldData = 
        a: 1
        b: 
          b1: true
          b2: "hi"
      newData = 
        b: 
          b1: true
          b2: "there"
        c: 
          bob: "is cool"
      patches = GE.makePatches(oldData, newData)

      # Create model objects of the data
      oldModel = new GE.Model(oldData)
      newModel = oldModel.applyPatches(patches)

      # The new model and the old model should still both be valid and different
      expect(oldModel.version).toEqual(0)
      expect(oldModel.data).toDeeplyEqual(oldData)
      expect(newModel.version).toEqual(1)
      expect(newModel.data).toDeeplyEqual(newData)

    it "rejects conflicting patches", ->
      # Create old data, new data, and the patches between
      oldData = 
        a: 1
      newDataA = 
        a: 2 
      newDataB = 
        b: 3
      patchesA = GE.makePatches(oldData, newDataA)
      patchesB = GE.makePatches(oldData, newDataB)

      # Create model objects of the data
      oldModel = new GE.Model(oldData)
      expect(-> oldModel.applyPatches(_.flatten([patchesA, patchesB]))).toThrow()

  describe "runSteps", ->
    it "calls functions", ->
      # make test function to spy on
      globals.testFunction = jasmine.createSpy()

      layout = 
        call: "testFunction"
        params: [1, 2]

      GE.runStep(new GE.Model(), null, layout)

      expect(globals.testFunction).toHaveBeenCalledWith(1, 2)

    it "calls actions", ->
      isCalled = false

      actions = 
        doNothing: 
          paramDefs:
            x: 1
            y: "z"
          update: ->
            isCalled = true
            expect(arguments.length).toEqual(0)
            expect(@params).toDeeplyEqual
              x: 2
              y: "z"

      layout = 
        action: "doNothing"
        params: 
          x: 2
          y: "z"

      GE.runStep(new GE.Model(), actions, layout)
      expect(isCalled).toBeTruthy()

    it "calls children of actions", ->
      timesCalled = 0

      actions = 
        doNothing: 
          paramDefs: {}
          update: -> timesCalled++

      layout = 
        action: "doNothing"
        params: {}
        children: [
          {
            action: "doNothing"
            params: {}
          },
          {
            action: "doNothing"
            params: {}
          }
        ]

      GE.runStep(new GE.Model(), actions, layout)
      expect(timesCalled).toEqual(3)

    it "evaluates parameters for functions", ->
      model = new GE.Model({ person: { firstName: "bob" } })

      # make test function to spy on
      globals.testFunction = jasmine.createSpy()

      layout = 
        bind: 
          select: 
            lastName: "jon"
        children: [
          { 
            call: "testFunction"
            params: ["@model:person.firstName", "model", "$lastName"]
          }
        ]
      GE.runStep(model, null, layout)

      expect(globals.testFunction).toHaveBeenCalledWith("bob", "model", "jon")

    it "evaluates parameters for actions", ->
      oldModel = new GE.Model
        a: 1
        b: 10
        c: 20

      actions = 
        adjustModel: 
          paramDefs:
            x: null
            y: null
            z: null
            d: 2
          update: ->
            @params.x++
            @params.y--
            @params.z = 30
            expect(@params.d).toBe(2)

      layout = 
        bind: 
          select:
            c: "@model:b"
            z: "@model:c"
        children: [
          action: "adjustModel"
          params: 
            x: "@model:a"
            y: "$c"
        ]

      patches = GE.runStep(oldModel, actions, layout)
      newModel = oldModel.applyPatches(patches)

      # The new model should be changed, but the old one shouldn't be
      expect(oldModel.data.a).toBe(1)
      expect(oldModel.data.b).toBe(10)
      expect(oldModel.data.c).toBe(20)
      expect(newModel.data.a).toBe(2)
      expect(newModel.data.b).toBe(9)
      expect(newModel.data.c).toBe(30)


