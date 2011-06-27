module "QuadTree"

# overwrites window.qt before each test is run
QUnit.testStart = ->
  window.qt = window.QuadTree()

test "should properly subdivide elements with their width and height", ->
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

  equals qt.root().children().length, 2
  equals qt.root().I.nodes[0].children().length, 1
  equals qt.root().I.nodes[3].children().length, 1
  equals qt.root().I.nodes[3].I.nodes[0].children().length, 4
  equals qt.root().I.nodes[3].I.nodes[3].children().length, 1 

  equals qt.root().I.nodes[3].I.nodes[2].children().length, 0, "This should be 0 if we are taking width and height into account"

module()

