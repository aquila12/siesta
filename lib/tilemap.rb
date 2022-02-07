# frozen_string_literal: true

class Tilemap
  def initialize(width, height, tileset, default = 0)
    @map = Array.new(width * height, default)
    @width = width
    @height = height
    @px, @py = tileset.dimensions
    @path = tileset.path
    @tiles = tileset.tiles
  end

  def window_shape(w, h)
    @right, @top = w, h
    @dx, @dy = [w / 2, h / 2]
  end

  def focus_window(x, y)
    x -= @dx
    y -= @dy
    @i, @ox = x.divmod(@px)
    @j, @oy = y.divmod(@py)
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
    n0 = @j * @width + @i

    y = -@oy
    j = @j
    while(y < @top) do
      if(j >=0 && j < @height)
        x = -@ox
        i = @i
        n = n0
        while(x < @right) do
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
