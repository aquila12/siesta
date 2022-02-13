# frozen_string_literal: true

class Sky
  attr_reader :tileset, :dimensions

  attr_accessor :facing

  def initialize
    @tileset = 'sky'
    @dimensions = [0, 0, 42, tiledata.length]
    @facing = :s

    @tilepainter = Tilepainter.new(self, stride_i: 0, stride_j: 1)
  end

  def draw(outputs)
    outputs.sprites << @tilepainter
    outputs.sprites << sky_object
  end

  def tiledata
    tiles_y = (CAMERA.h / TILE_SIZE).ceil
    dp = 2.3 / (4 * tiles_y)
    p0 = 2 * sunset_phase - 0.6
    Array.new(tiles_y) { |i| (8.0 * (p0 + i*dp).clamp(0,1)).round }
  end

  def origin
    case @facing
    when :se then [0, 0]
    when :s then [CAMERA.w / 2, 0]
    when :sw then [CAMERA.w, 0]
    end
  end

  def t
    $state.clock
  end

  def sky_object
    x_scale = CAMERA.w * 2 - SKY_OBJECT_SIZE
    y_scale = 4 * CAMERA.h
    x = (((t + 6) % 12) / 12.0 * x_scale).round
    p = (x / x_scale)
    {
      x: x - origin.x, y: y_scale * (p * (1 - p)) - SKY_OBJECT_SIZE,
      w: SKY_OBJECT_SIZE, h: SKY_OBJECT_SIZE,
      path: 'resources/skyobjects.png',
      tile_x: sky_sprite_id * SKY_OBJECT_SIZE, tile_y: 0,
      tile_w: SKY_OBJECT_SIZE, tile_h: SKY_OBJECT_SIZE
    }
  end

  def sunset_phase
    case t
    when (4..8) then (8.0 - t) / 4.0
    when (8..16) then 0.0
    when (16..20) then (t - 16.0) / 4.0
    else 1.0
    end
  end

  def sky_sprite_id
    case t
    when (6..9) then 0
    when (9..15) then 2
    when (15..18) then 0
    else 1
    end
  end
end
