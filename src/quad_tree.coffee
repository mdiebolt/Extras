((window) ->
  MAX_CHILDREN = 5
  MAX_DEPTH = 4

  QuadTree = (I) ->
    I ||= {}

    root = Node()

    self =      
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

    self.maxChildren = (val) ->
      if val?
        MAX_CHILDREN = val

        return self
      else
        MAX_CHILDREN

    self.maxDepth = (val) ->
      if val?
        MAX_DEPTH = val

        return self
      else
        MAX_DEPTH

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
      nodes: []

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
        I.children.clear()
        I.nodes.invoke('clear')
        return I.nodes.clear()

      insert: (item) ->
        if I.nodes.length
          index = findQuadrant(item)
          I.nodes[index].insert(item)
          return true

        I.children.push(item)

        if (I.depth < MAX_DEPTH) && (I.children.length > MAX_CHILDREN)          
          subdivide()
          I.children.each (child) ->
            return self.insert(child)

          return I.children.clear();

      retrieve: (item) ->     
        index = findQuadrant(item)

        I.nodes[index]?.retrieve(item) || I.children


    return self

  window.QuadTree = QuadTree
)(window)
