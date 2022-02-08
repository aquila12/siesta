# frozen_string_literal: true

class Tilemap
  attr_accessor :stage

  def initialize(width, height, tileset, default = 0)
    @map = Array.new(width * height, default)
    @width = width
    @height = height
    @px, @py = tileset.dimensions
    @path = tileset.path
    @tiles = tileset.tiles
    @x, @y = [0, 0]
  end

  def peek(x, y)
    return if x < 0 || y < 0
    return if x >= @width || y > @height
    @map[y * @width + x]
  end

  def poke(x, y, v)
    return if x < 0 || y < 0
    return if x >= @width || y > @height
    @map[y * @width + x] = v
  end

  def draw_override(canvas)
    ox, oy = @stage.rel(@x, @y)
    right, top = @stage.camera
    i0, x0 = (-ox).divmod(@px)
    j0, y0 = (-oy).divmod(@py)

    n0 = j0 * @width + i0

    y = -y0
    j = j0
    while(y < top) do
      if(j >= 0 && j < @height)
        x = -x0
        i = i0
        n = n0
        while(x < right) do
          if(i >= 0 && i < @width)
            t = @map[n]
            tx, ty = @tiles[t]

            canvas.draw_sprite_3(
              x, y, @px, @py, @path,
              nil, nil, nil, nil, nil, # Angle A R G B
              tx, ty, @px, @py, # Tile coords (top-down)
              nil, nil, nil, nil, # Flip H V, Anchor X Y
              nil, nil, nil, nil # Source coords (bottom-up)
            )
          end
          x += @px
          i += 1
          n += 1
        end
      end

      y += @py
      j += 1
      n0 += @width
    end
  end
end
