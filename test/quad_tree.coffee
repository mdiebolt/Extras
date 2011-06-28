module "QuadTree"

# overwrites window.qt before each test is run
QUnit.testStart = ->
  window.qt = window.QuadTree()

test "should have default for max children", ->
  ok qt.I.maxChildren
  equals qt.I.maxChildren, 5

test "should have default for max depth", ->
  ok qt.I.maxDepth
  equals qt.I.maxDepth, 4

test "should be able to set maxChildren and maxDepth", ->
  newChildren = 7
  newDepth = 9

  qt = QuadTree
    maxChildren: 7
    maxDepth: 9

  equals qt.I.maxChildren, newChildren
  equals qt.I.maxDepth, newDepth

test "should be able to insert into the root", ->
  bounds =
    x: 40
    y: 60
    width: 25
    height: 30

  qt.insert(bounds)

  results = qt.retrieve(bounds)

  ok results.length == 1

test "should insert an array", ->
  qt.insert([{
    x: 40
    y: 50
    width: 20
    height: 20
  }, {
    x: 30
    y: 40
    width: 10
    height: 15
  }])

  equals qt.root().children().length, 2

test "should subdivide after maxChildren is reached", ->
  qt.I.maxChildren.times (n) ->
    bounds =
      x: 100 + (50 * n)
      y: 60
      width: 25
      height: 30

    qt.insert(bounds)

  qt.insert
    x: 400
    y: 50
    width: 25
    height: 30

  equals qt.root().I.nodes.length, 4, "root should have subdivided into 4 parts"
  equals qt.root().I.nodes[1].children().length, 1, "The second subdivision has 1 child since we inserted the maxChildren into the root"

test "should insert into children array when at the max depth", ->
  qt = QuadTree
    maxDepth: 2

  levelsDeep = 4

  (qt.I.maxChildren * levelsDeep).times ->
    bounds =
      x: 10
      y: 10
      width: 50
      height: 50

    qt.insert(bounds)

  equals qt.root().I.nodes[0].children().length, qt.I.maxChildren * levelsDeep  

test "should properly subdivide elements with their width and height", ->
  window.qt = QuadTree
    maxChildren: 3
    maxDepth: 3

  qt.insert
    x: 50
    y: 50
    width: 20
    height: 20

  qt.insert
    x: 300
    y: 120
    width: 40
    height: 20

  qt.insert
    x: 330
    y: 250
    width: 10
    height: 10

  qt.insert
    x: 475
    y: 380
    width: 10
    height: 10

  qt.insert
    x: 350
    y: 250
    width: 10
    height: 10

  qt.insert
    x: 340
    y: 270
    width: 10
    height: 10

  equals qt.root().children().length, 1
  equals qt.root().I.nodes[0].children().length, 1
  equals qt.root().I.nodes[3].children().length, 1
  equals qt.root().I.nodes[3].I.nodes[0].children().length, 3

test "#eachPair", ->
  5.times ->
    qt.insert
      x: 50
      y: 50
      width: 10
      height: 20

  qt.insert
    x: 250
    y: 50
    width: 20
    height: 30

  timesCalled = 0

  qt.eachPair (a, b) ->
    timesCalled++

  equals timesCalled, (5 + 4 + 3 + 2 + 1) - 5

test "#eachPair with an overlap node", ->
  5.times ->
    qt.insert
      x: 50
      y: 50
      width: 10
      height: 20

  qt.insert
    x: 150
    y: 50
    width: 20
    height: 30

  timesCalled = 0

  qt.eachPair (a, b) ->
    timesCalled++

  equals timesCalled, (6 + 5 + 4 + 3 + 2 + 1) - 6


module()

