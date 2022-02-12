# frozen_string_literal: true

class Spritepainter
  def initialize(stage, tint = [255, 255, 255])
    @path = 'resources/sprites.png'
    @stage = stage
    @r, @g, @b = tint
  end

  def self.make_sprite(what, x, y, mirror: false)
    {
      x: x, y: y, spr: what, fr: 0, t: 0.0, mirror: mirror
    }
  end

  def animate
    [@stage.actor, *@stage.objects].each do |sprite|
      f = sprite.fr + 0.1
      frames = SPRITES[sprite.spr].length
      sprite.fr = f % frames
    end

    self
  end

  def draw_override(canvas)
    tw, th = [SPRITE_SIZE.w, SPRITE_SIZE.h]
    left, bottom, right, top = -tw, -th, CAMERA.right, CAMERA.top
    ox, oy = @stage.origin
    ox += tw / 2

    [@stage.passives, @stage.objects, [@stage.actor]].each do |sprites|
      next unless sprites

      n_sprites = sprites.length
      n = 0
      while(n < n_sprites) do
        s = sprites[n]
        n += 1
        next unless s

        x, y = [s.x.round - ox, s.y.round - oy]
        next unless(x > left && y > bottom && x < right && y < top)
        t = SPRITES[s.spr][s.fr]
        ty, tx = t.divmod(TILES_PER_ROW)

        canvas.draw_sprite_3(
          x, y, tw, th, @path,
          nil, nil, @r, @g, @b, # Angle A R G B
          tx * tw, ty * th, tw, th, # Tile coords (top-down)
          s.mirror, nil, nil, nil, # Flip H V, Anchor X Y
          nil, nil, nil, nil # Source coords (bottom-up)
        )
      end
    end
  rescue => e
    puts "#{e}: #{e.message}"
    puts e.backtrace
  end
end

class Tilepainter
  def initialize(tiles, stride_i: 1, stride_j: nil, inverse: false)
    option = inverse ? 'tiles-inverse' : 'tiles'
    @path = "resources/#{tiles.tileset}#{option}.png"
    @width, @height = tiles.dimensions.w, tiles.dimensions.h

    @tiledata = tiles.tiledata
    @origin = tiles.origin

    @stride_i = stride_i || @height
    @stride_j = stride_j || @width
  end

  def draw_override(canvas)
    right, top = CAMERA.right, CAMERA.top
    i0, x0 = (@origin.x).divmod(TILE_SIZE)
    j0, y0 = (@origin.y).divmod(TILE_SIZE)

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
            t = @tiledata[n]
            ty, tx = t.divmod(TILES_PER_ROW)

            canvas.draw_sprite_3(
              x, y, TILE_SIZE, TILE_SIZE, @path,
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
