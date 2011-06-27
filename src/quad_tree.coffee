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

      eachCollisionPair: (A, B) ->
        return $.noop

      clear: -> root.clear()

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
      bounds: 
        x: 0
        y: 0
        width: App.width || 640
        height: App.height || 480
      children: []
      depth: 0
      maxChildren: 5
      maxDepth: 4
      nodes: []

    stuckChildren = []
    out = []

    TOP_LEFT = 0
    TOP_RIGHT = 1
    BOTTOM_LEFT = 2
    BOTTOM_RIGHT = 3

    findQuadrant = (item) ->
      {x, y} = I.bounds

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

    halfWidth = ->
      (I.bounds.width / 2).floor()

    halfHeight = ->
      (I.bounds.height / 2).floor()

    subdivide = ->
      increased_depth = I.depth + 1

      half_width = halfWidth()
      half_height = halfHeight()

      4.times (n) ->
        I.nodes[n] = Node
          bounds: 
            x: half_width * (n % 2)
            y: half_height * (if n < 2 then 0 else 1)
            width: half_width
            height: half_height
          depth: increased_depth

    self = 
      I: I

      clear: ->
        stuckChildren.clear()
        I.children.clear()
        I.nodes.invoke('clear')
        I.nodes.clear()

      children: ->
        I.children.concat(stuckChildren)

      insert: (item) ->
        if I.nodes.length
          index = findQuadrant(item)          
          node = I.nodes[index]

          if (item.x >= node.I.bounds.x && 
              item.x + item.width <= node.I.bounds.x + node.I.bounds.width && 
              item.y >= node.I.bounds.y && 
              item.y + item.height <= node.I.bounds.y + node.I.bounds.height)
            I.nodes[index].insert(item)
          else
            stuckChildren.push(item)

          return

        I.children.push(item)

        if (I.depth < I.maxDepth) && (I.children.length > I.maxChildren)
          subdivide()

          debugger

          I.children.each (child) ->          
            self.insert(child)

          I.children.clear()

      retrieve: (item) ->  
        out.clear()

        if I.nodes.length
          index = findQuadrant(item)

          out.push.apply(out, I.nodes[index].retrive(item))

        out.push.apply(out, stuckChildren)
        out.push.apply(out, I.children)

        return out

  window.QuadTree = QuadTree
)(window)
