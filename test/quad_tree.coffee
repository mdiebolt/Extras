module "QuadTree"

# overwrites window.qt before each test is run
QUnit.testStart = ->
  window.qt = QuadTree()

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


module()