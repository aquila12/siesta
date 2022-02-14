# frozen_string_literal: true

class Sky
  attr_reader :tileset, :dimensions

  attr_accessor :facing

  def initialize
    @tileset = 'sky'
    @dimensions = [0, 0, 42, tiledata.length]
    @rectangle = @dimensions.scale_rect(TILE_SIZE)
    @clouds = Array.new(3) { gen_cloud(x: rand(@rectangle.w)) }

    @tilepainter = Tilepainter.new(self, stride_i: 0, stride_j: 1)
  end

  def update
    @clouds.each do |c|
      c.x += 0.1 * (c.y / @rectangle.h) ** 1.2
      c.merge! gen_cloud if c.x > @rectangle.w
    end
  end

  def draw(outputs)
    outputs.sprites << @tilepainter
    outputs.sprites << sky_object
    outputs.sprites << @clouds.map { |c| object_at(c.what, c.x, c.y) }
  end

  def tiledata
    tiles_y = (CAMERA.h / TILE_SIZE).ceil
    dp = 2.3 / (4 * tiles_y)
    p0 = 2 * sunset_phase - 0.6
    Array.new(tiles_y) { |i| (8.0 * (p0 + i*dp).clamp(0,1)).round }
  end

  def origin
    case $level.facing
    when :se then [0, 0]
    when :s then [CAMERA.w / 2, 0]
    when :sw then [CAMERA.w, 0]
    end
  end

  def t
    $state.clock
  end

  def sky_object
    x_scale = @rectangle.w - 12
    y_scale = 4 * @rectangle.h
    x = (((t + 6) % 12) / 12.0 * x_scale).round
    p = (x / x_scale)
    object_at(celestial_object, x, y_scale * (p * (1 - p)) - 12)
  end

  def object_at(what, x, y)
    src_rect = SKY_OBJECTS[what]
    {
      x: x - origin.x, y: y - origin.y, w: src_rect.w, h: src_rect.h,
      path: 'resources/skyobjects.png',
      tile_x: src_rect.x, tile_y: src_rect.y,
      tile_w: src_rect.w, tile_h: src_rect.h
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

  def celestial_object
    case t
    when (6..9) then :sun_low
    when (9..15) then :sun_high
    when (15..18) then :sun_low
    else :moon
    end
  end

  def gen_cloud(x: -32)
    y = @rectangle.h / 3 + rand(@rectangle.h / 2)
    { x: x, y: y, what: random_cloud(y) }
  end

  def random_cloud(y)
    r = rand + (y.to_f / @rectangle.h)
    case
    when r > 1.4 then :altostratus
    when r > 0.6 then :stratocumulus
    else :cumulus
    end
  end
end
