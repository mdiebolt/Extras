module "QuadTree"

# overwrites window.qt before each test is run
QUnit.testStart = ->
  window.qt = window.QuadTree()

test "should have default for max children", ->
  ok qt.maxChildren
  equals qt.maxChildren(), 5

test "should have default for max depth", ->
  ok qt.maxDepth
  equals qt.maxDepth(), 4 

test "should be able to set maxChildren and maxDepth", ->
  newChildren = 7
  newDepth = 9

  qt.maxChildren(newChildren)
  qt.maxDepth(newDepth)

  equals qt.maxChildren(), newChildren
  equals qt.maxDepth(), newDepth

  qt.maxChildren(3)
  qt.maxDepth(4)

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
  (qt.maxChildren()).times (n) ->
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
  qt.maxDepth(2)

  (qt.maxChildren() * 3).times (n) ->
    bounds =
      x: 0
      y: 0
      width: 50
      height: 50

    qt.insert(bounds)

  equals qt.root().I.nodes[0].I.nodes[0].children().length, qt.maxChildren() * 3   

test "should properly subdivide elements with their width and height", ->
  qt.maxChildren(5)
  qt.maxDepth(4)

  qt.insert
    x: 50
    y: 50
    width: 20
    height: 20

  qt.insert
    x: 160
    y: 230
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
    x: 350
    y: 250
    width: 10
    height: 10

  qt.insert
    x: 340
    y: 270
    width: 10
    height: 10

  qt.insert
    x: 325
    y: 290
    width: 10
    height: 10

  qt.insert
    x: 475
    y: 380
    width: 10
    height: 10

  qt.insert
    x: 500
    y: 400
    width: 10
    height: 10

  log qt.root().I.nodes[3].children()

  equals qt.root().children().length, 2
  equals qt.root().I.nodes[0].children().length, 1
  equals qt.root().I.nodes[3].children().length, 1
  equals qt.root().I.nodes[3].I.nodes[0].children().length, 4
  equals qt.root().I.nodes[3].I.nodes[3].children().length, 1 

  equals qt.root().I.nodes[3].I.nodes[2].children().length, 0, "This should be 0 if we are taking width and height into account"

module()

