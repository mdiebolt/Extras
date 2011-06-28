module "QuadTree"

test "should properly subdivide elements with their width and height", ->
  qt = QuadTree
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

  log qt.root()

  equals qt.root().children().length, 1
  equals qt.root().I.nodes[0].children().length, 1
  equals qt.root().I.nodes[3].children().length, 1
  equals qt.root().I.nodes[3].children().length, 3

module()

