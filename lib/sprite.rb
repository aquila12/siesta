# frozen_string_literal: true

class Sprite
  attr_sprite
  attr_reader :stance
  attr_accessor :stage

  def initialize(x, y, protosprite)
    @x, @y = x, y

    @stances = protosprite.stances
    @anchor_x, @anchor_y = protosprite.anchor

    self.stance = :idle
  end

  def stance=(name)
    @stance = name
    tileset = @stances[name]

    @tiles = tileset.tiles
    @loop_t = 1.0 * @tiles.length

    @t = 0.0
    animate(0.0)

    @path = tileset.path
    @tile_w, @tile_h = tileset.dimensions
    @w, @h = tileset.dimensions
  end

  def animate(rate)
    @t += rate
    @t -= @loop_t if @t > @loop_t
    @tile_x, @tile_y = @tiles[@t.to_i]
  end

  def position
    [@x, @y]
  end

  def x
    @x - @stage.x
  end

  def y
    @y - @stage.y
  end
end
