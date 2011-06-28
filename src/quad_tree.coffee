###
  based on QuadTree.js by Mike Chambers
  https://github.com/mikechambers/ExamplesByMesh/blob/master/JavaScript/QuadTree/src/QuadTree.js  
###

((window) ->
  QuadTree = (I) ->
    I ||= {}

    $.reverseMerge I,
      maxChildren: 5
      maxDepth: 4

    root = Node
      maxChildren: I.maxChildren
      maxDepth: I.maxDepth

    self =   
      I: I

      eachPair: (iterator) ->
        root.eachPair(iterator)

      insert: (obj) ->
        if Object.isArray(obj)
          obj.each (item) ->
            root.insert(item)
        else 
          root.insert(obj)

      retrieve: (item) -> 
        root.retrieve(item).copy()

      root: -> root

    return self

  Node = (I) ->
    I ||= {}

    $.reverseMerge I, 
      children: []
      depth: 1
      maxChildren: 5
      maxDepth: 4
      nodes: []
      parent: null
      x: 0
      y: 0
      width: App.width || 640
      height: App.height || 480

    overlapChildren = []
    out = []

    TOP_LEFT = 0
    TOP_RIGHT = 1
    BOTTOM_LEFT = 2
    BOTTOM_RIGHT = 3

    findQuadrant = (item) ->
      {x, y} = I

      x_midpoint = x + halfWidth()
      y_midpoint = y + halfHeight()

      left = item.x <= x_midpoint
      top = item.y <= y_midpoint

      index = TOP_LEFT

      if left
        unless top
          index = BOTTOM_LEFT
      else
        if top
          index = TOP_RIGHT
        else
          index = BOTTOM_RIGHT

      return index

    halfWidth = -> (I.width / 2).floor()
    halfHeight = -> (I.height / 2).floor()

    subdivide = ->
      increased_depth = I.depth + 1

      half_width = halfWidth()
      half_height = halfHeight()

      4.times (n) ->
        I.nodes[n] = Node
          depth: increased_depth            
          maxChildren: I.maxChildren
          maxDepth: I.maxDepth
          parent: self
          x: I.x + (half_width * (n % 2))
          y: I.y + (half_height * (if n < 2 then 0 else 1))
          width: half_width
          height: half_height          

    self = 
      I: I

      clear: ->
        overlapChildren.clear()
        I.children.clear()
        I.nodes.clear()

        I.nodes.invoke('clear')

      children: -> I.children.concat(overlapChildren)

      insert: (item) ->
        if I.nodes.length
          index = findQuadrant(item)          
          nodeBounds = I.nodes[index].I

          if (item.x >= nodeBounds.x && item.x + item.width <= nodeBounds.x + nodeBounds.width) && 
             (item.y >= nodeBounds.y && item.y + item.height <= nodeBounds.y + nodeBounds.height)
            I.nodes[index].insert(item)
          else
            overlapChildren.push(item)

          return

        I.children.push(item)

        if (I.depth < I.maxDepth) && (self.children().length > I.maxChildren)
          subdivide()

          I.children.each (child) ->          
            self.insert(child)

          I.children.clear()

      eachPair: (iterator) ->
        if length = I.nodes.length
          length.times (n) ->
            I.nodes[n].eachPair(iterator)
        else
          collidables = self.children()

          if I.parent && I.parent.children().length
            collidables = collidables.concat(I.parent.children()) 

          if collidables.length > 1
            collidables.eachPair (A, B) ->            
              iterator(A, B) 

      retrieve: (item) -> 
        out.clear()

        if I.nodes.length
          index = findQuadrant(item)

          out.push.apply(out, I.nodes[index].retrieve(item))

        out.push.apply(out, overlapChildren)
        out.push.apply(out, I.children)

        return out

  window.QuadTree = QuadTree
)(window)
