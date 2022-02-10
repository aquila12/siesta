# frozen_string_literal: true

TILE_SIZE = 4
TILES_PER_ROW = 8

CAMERA = [0, 0, 84, 48]

class Skypainter
  def draw_override(canvas)
    sky = $state.sky
    path = "resources/#{sky.tileset}tiles.png"
    right, top = CAMERA.right, CAMERA.top
    skydata = sky.data

    y = -(sky.sunset * skydata.length * TILE_SIZE)
    j = 0
    while(y < top) do
      t = skydata[j]
      ty, tx = [0, t]
      if(j < skydata.length)
        x = 0
        while(x < right) do
          canvas.draw_sprite_3(
            x, y, TILE_SIZE, TILE_SIZE, path,
            nil, nil, nil, nil, nil, # Angle A R G B
            TILE_SIZE * tx, TILE_SIZE * ty, TILE_SIZE, TILE_SIZE, # Tile coords (top-down)
            nil, nil, nil, nil, # Flip H V, Anchor X Y
            nil, nil, nil, nil # Source coords (bottom-up)
          )
          x += TILE_SIZE
        end
      end

      y += TILE_SIZE
      j += 1
    end
  rescue => e
    puts "#{e}: #{e.message}"
    puts e.backtrace
  end
end

class Tilepainter
  def draw_override(canvas)
    stage = $state.stage
    tod = $state.time_of_day
    path = "resources/#{stage.tileset}tiles#{tod}.png"
    dims = stage.dimensions
    width, height = dims.w, dims.h

    tiledata = stage.tiledata

    origin = stage.origin
    right, top = CAMERA.right, CAMERA.top
    i0, x0 = (origin.x).divmod(TILE_SIZE)
    j0, y0 = (origin.y).divmod(TILE_SIZE)

    n0 = j0 * width + i0

    y = -y0
    j = j0
    while(y < top) do
      if(j >= 0 && j < height)
        x = -x0
        i = i0
        n = n0
        while(x < right) do
          if(i >= 0 && i < width)
            t = tiledata[n]
            ty, tx = t.divmod(TILES_PER_ROW)

            canvas.draw_sprite_3(
              x, y, TILE_SIZE, TILE_SIZE, path,
              nil, nil, nil, nil, nil, # Angle A R G B
              TILE_SIZE * tx, TILE_SIZE * ty, TILE_SIZE, TILE_SIZE, # Tile coords (top-down)
              nil, nil, nil, nil, # Flip H V, Anchor X Y
              nil, nil, nil, nil # Source coords (bottom-up)
            )
          end
          x += TILE_SIZE
          i += 1
          n += 1
        end
      end

      y += TILE_SIZE
      j += 1
      n0 += width
    end
  rescue => e
    puts "#{e}: #{e.message}"
    puts e.backtrace
  end
end
