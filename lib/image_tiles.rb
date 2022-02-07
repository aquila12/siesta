# frozen_string_literal: true

ACTORS = Hash.new
OBJECTS = Hash.new
TILESET = Hash.new

class ImageTiles
  def self.load(path, grid: [1, 1], &block)
    new(path, grid.x, grid.y).instance_eval(&block)
  end

  def initialize(path, grid_x, grid_y)
    @path = path
    @u = grid_x
    @v = grid_y
  end

  class Tileset
    attr_reader :path, :dimensions
    attr_accessor :tiles

    def initialize(path, w, h)
      @path = path
      @dimensions = [w, h]
      @tiles = []
    end
  end

  class Protosprite
    attr_reader :anchor, :stances

    def initialize(anchor, **stances)
      @anchor = anchor
      @stances = stances
    end

    def new(x, y)
      Sprite.new(x, y, self)
    end
  end

  class Sprite
    attr_sprite
    attr_reader :stance

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
  end

  def _prep_tileset(x, y, w, h, count = 1)
    x, y, w, h = [x * @u, y * @v, w * @u, h * @v]
    Tileset.new(@path, w, h).tap do |t|
      t.tiles = Array.new(count) { |i| [x + w*i, y] }
    end
  end

  def tileset(name, x, y, w, h, tiles)
    TILESET[name] = _prep_tileset(x, y, w, h, tiles)
  end

  def actor(name, **stances)
    sets = stances.transform_values do |definition|
      _prep_tileset(*definition)
    end

    ACTORS[name] = Protosprite.new([0.5, 0.0], **sets)
  end

  def object(name, *ts_params, anchor: [0.5, 0.0])
    OBJECTS[name] = Protosprite.new(anchor, idle: _prep_tileset(*ts_params))
  end

  def objects(x, y, w, h, names, anchor: [0.5, 0.0])
    names.each.with_index do |name, i|
      object(name, x + w*i, y, w, h, anchor: anchor)
    end
  end
end
