# frozen_string_literal: true

class Level
  attr_reader :actor

  attr_reader :tiledata, :tileset, :dimensions, :origin

  attr_reader :viewrect, :objects, :hotspots

  def initialize
    load_area($state.area)

    init_geometry
    load_furniture
    load_doors
    insert_game_objects
    init_painters
  end

  def load_area(what)
    @dimensions = dims = [0, 0, 210, 12]
    @tileset = 'level'
    @tiledata = Array.new(dims.w * dims.h, 0) { |n| (n < dims.w) ? 1 : 0 }
    @objects = []
    @hotspots = []
    @triggers = []
    @object_idx = {}
    @anon = 1
  end

  def load_furniture
    15.times do
      insert_object(
        GameObject.make(
          %i[cactus bush gate].sample,
          [ rand(@rectangle.w - SPRITE_SIZE.w), TILE_SIZE],
          mirror: [true, false].sample
        )
      )
    end
  end

  def load_doors
    insert_hotspot auto: true, hitbox: [0, 0, 16, CAMERA.h] do
      insert_object(GameObject.make(:cactus, [rand(40), rand(20)]))
      true
    end

    insert_hotspot auto: false, hitbox: [@rectangle.w - 16, 0, 16, CAMERA.h] do
      insert_object(GameObject.make(:bush, [@rectangle.w - rand(40), rand(20)]))
      false
    end
  end

  def insert_game_objects
    @campfire = Campfire.new([CAMERA.w * 2 + rand(CAMERA.w), TILE_SIZE])
    @horse = Horse.new([CAMERA.w * 3 + rand(CAMERA.w), TILE_SIZE])

    @campfire.insert(self)
    @horse.insert(self)

    @actor = GameObject.make(:player_rest, $state.player_position)
    insert_object(@actor)
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

  def insert_object(*objects)
    @objects.concat(objects)
  end

  def insert_hotspot(**definition, &block)
    @hotspots << { handler: block, position: [0, 0] }.merge(definition)
  end

  def insert_trigger(clock:, &block)
    @triggers << { time: clock..(clock + 1), handler: block}
  end

  def focus(target)
    off_x, off_y = [CAMERA.w / 2, CAMERA.h / 2]
    focus = [target.x.round - off_x, target.y.round - off_y, CAMERA.w, CAMERA.h]

    @origin.x = focus.right > @viewrect.right ? (@viewrect.right - CAMERA.w): [focus.left, @viewrect.left].max
    @origin.y = focus.top > @viewrect.top ? (@viewrect.top - CAMERA.h): [focus.bottom, @viewrect.bottom].max
  end

  def check_hotspots
    interacting = $state.input.interact
    pos = $state.player_position

    @hotspots.each do |h|
      next unless h.auto || interacting
      rect = h.hitbox.rect_shift(h.position)
      next unless pos.inside_rect? rect
      h.flag = h.handler.call
    end
    @hotspots.delete_if { |h| h.flag }
  end

  def check_triggers
    @triggers.each do |t|
      next unless t.time.include? $state.clock
      t.handler.call
      t.flag = true
    end
    @triggers.delete_if { |t| t.flag }
  end

  def update
    check_hotspots
    check_triggers

    @spritepainter.animate
    @spritepainter.tint = SPRITE_TINT[$state.time_of_day]
    @tilepainter.inverse = $state.time_of_day == :night
  end

  def draw(outputs)
    outputs.sprites << @tilepainter
    outputs.sprites << @spritepainter
  end
end
