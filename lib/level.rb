# frozen_string_literal: true

class Level
  attr_reader :actor

  attr_reader :tiledata, :tileset, :dimensions, :origin

  attr_reader :viewrect, :objects

  def initialize
    load_area($state.area)

    init_geometry
    load_furniture
    insert_game_objects
    init_painters
  end

  def load_area(what)
    @dimensions = dims = [0, 0, 210, 12]
    @tileset = 'level'
    @tiledata = Array.new(dims.w * dims.h, 0) { |n| (n < dims.w) ? 1 : 0 }
    @objects = []
    @object_idx = {}
    @anon = 1
  end

  def load_furniture
    15.times do
      insert_object(
        make_object(
          %i[cactus bush gate].sample,
          [ rand(@rectangle.w - SPRITE_SIZE.w), TILE_SIZE],
          mirror: [true, false].sample
        )
      )
    end
  end

  def insert_game_objects
    fire_x = rand(@rectangle.w - SPRITE_SIZE.w)
    insert_object(make_object(:campfire, [fire_x, TILE_SIZE]))
    insert_object(make_object(:flame, [fire_x, TILE_SIZE]))
    insert_object(make_object(:smoke, [fire_x, TILE_SIZE*2]))

    @actor = make_object(:player_rest, $state.player_position)
    insert_object(@actor, name: :actor)
  end

  def init_geometry
    @origin = [0, 0]

    @rectangle = @dimensions.scale_rect(TILE_SIZE)
    @viewrect = @dimensions.scale_rect(TILE_SIZE)
    if @rectangle.w < CAMERA.w
      @viewrect.x = (@rectangle.w - CAMERA.w) / 2
      @viewrect.w = CAMERA.w
    end

    if @rectangle.h < CAMERA.h
      @viewrect.y = (@rectangle.h - CAMERA.h) / 2
      @viewrect.h = CAMERA.h
    end
  end

  def init_painters
    @tilepainter = Tilepainter.new(self)
    @spritepainter = Spritepainter.new(@objects, @origin)
  end

  def make_object(what, position, mirror: false)
    { position: position, spr: what, fr: 0, t: 0.0, mirror: mirror }
  end

  def insert_object(object, name: nil)
    # @object_idx[name] = object
    @objects << object
  end

  def focus(target)
    off_x, off_y = [CAMERA.w / 2, CAMERA.h / 2]
    focus = [target.x.round - off_x, target.y.round - off_y, CAMERA.w, CAMERA.h]

    @origin.x = focus.right > @viewrect.right ? (@viewrect.right - CAMERA.w): [focus.left, @viewrect.left].max
    @origin.y = focus.top > @viewrect.top ? (@viewrect.top - CAMERA.h): [focus.bottom, @viewrect.bottom].max
  end

  def update
    @spritepainter.animate
    @spritepainter.tint = SPRITE_TINT[$state.time_of_day]
    @tilepainter.inverse = $state.time_of_day == :night
  end

  def draw(outputs)
    outputs.sprites << @tilepainter
    outputs.sprites << @spritepainter
  end
end
