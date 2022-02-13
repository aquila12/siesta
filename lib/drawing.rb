# frozen_string_literal: true

class Spritepainter
  def initialize(sprites, origin)
    @path = 'resources/sprites.png'
    @sprites = sprites
    @origin = origin
    @r = @g = @b = 255
  end

  def tint=(tint)
    @r, @g, @b = tint
  end

  def animate
    n = 0
    n_sprites = @sprites.length
    while(n < n_sprites) do
      s = @sprites[n]
      clip = SPRITES[s.spr]
      n += 1
      f = s.fr + clip.rate
      s.fr = f % clip.frames.length
    end
  end

  def draw_override(canvas)
    tw, th = [SPRITE_SIZE.w, SPRITE_SIZE.h]
    left, bottom, right, top = -tw, -th, CAMERA.right, CAMERA.top
    ox, oy = @origin
    ox += tw / 2

    n = 0
    n_sprites = @sprites.length
    while(n < n_sprites) do
      s = @sprites[n]
      n += 1
      p = s.position
      x, y = [p.x.round - ox, p.y.round - oy]
      next unless(x > left && y > bottom && x < right && y < top)

      t = SPRITES[s.spr].frames[s.fr]
      ty, tx = t.divmod(TILES_PER_ROW)

      canvas.draw_sprite_3(
        x, y, tw, th, @path,
        nil, nil, @r, @g, @b, # Angle A R G B
        tx * tw, ty * th, tw, th, # Tile coords (top-down)
        s.mirror, nil, nil, nil, # Flip H V, Anchor X Y
        nil, nil, nil, nil # Source coords (bottom-up)
      )
    end
  rescue => e
    puts "#{e}: #{e.message}"
    puts e.backtrace
  end
end

class Tilepainter
  attr_accessor :inverse

  def initialize(tiles, stride_i: 1, stride_j: nil, inverse: false)
    @tiles = tiles
    @inverse = inverse

    @width, @height = @tiles.dimensions.w, @tiles.dimensions.h

    @stride_i = stride_i || @height
    @stride_j = stride_j || @width
  end

  def draw_override(canvas)
    option = @inverse ? 'tiles-inverse' : 'tiles'
    path = "resources/#{@tiles.tileset}#{option}.png"
    right, top = CAMERA.right, CAMERA.top

    tiledata = @tiles.tiledata

    o = @tiles.origin
    i0, x0 = o.x.divmod(TILE_SIZE)
    j0, y0 = o.y.divmod(TILE_SIZE)

    n0 = j0 * @stride_j + i0 * @stride_i

    y = -y0
    j = j0
    while(y < top) do
      if(j >= 0 && j < @height)
        x = -x0
        i = i0
        n = n0
        while(x < right) do
          if(i >= 0 && i < @width)
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
          n += @stride_i
        end
      end

      y += TILE_SIZE
      j += 1
      n0 += @stride_j
    end
  rescue => e
    puts "#{e}: #{e.message}"
    puts e.backtrace
  end
end
