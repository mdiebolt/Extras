module "QuadTree"

test "should have default for max children", ->
  qt = QuadTree()

  ok qt.MAX_CHILDREN
  equals qt.MAX_CHILDREN(), 5

test "should have default for max depth", ->




module()