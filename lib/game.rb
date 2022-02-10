# frozen_string_literal: true

class Game
  def initialize(args)
    @args = args
    @window = DrawWindow.new(args, 84, 48, 15)
    @stage = Stage.new(840, 60, window: [84, 48])
    init_sky
    init_ground
    @actors = [
      ACTORS[:manuel].new(10, 4).tap { |a| a.stance = :walk },
      ACTORS[:mount].new(30, 4).tap { |a| a.stance = :walk },
      ACTORS[:mount].new(50, 4).tap { |a| a.stance = :rest },
      OBJECTS[:horse].new(70, 4)
    ]
    @stage.add(
      @ground_tilemap,
      *@actors
    )
  end

  def init_sky
    @bg_stage = Stage.new(120, 120, window: [84, 48])
    @sky_tilemap = Tilemap.new(30, 30, TILESET[:sky], 4)
    ([0] * 15 + [1] * 2 + [2] * 3 + [3] * 2).each.with_index do |value, line|
      30.times { |n| @sky_tilemap.poke(n, line, value) }
    end
    @bg_stage.add(@sky_tilemap)
  end

  def init_ground
    @ground_tilemap = Tilemap.new(210,1, TILESET[:level_tile], 1)
  end

  def update
    @actors.each { |a| a.animate(0.2) }
  end

  def draw
    tilemaps = [@sky_tilemap, @ground_tilemap]
    @stage.focus(@args.tick_count, 0)
    set_time_of_day

    @window.outputs.sprites << tilemaps
    #@window.outputs << objects
    @window.outputs.sprites << @actors if @args.tick_count
    @window.draw
  end
end

def focus_stage(x, y)
  limits = $state.stage.viewrect
  off_x, off_y = [CAMERA.w / 2, CAMERA.h / 2]

  focus = [x.round - off_x, y.round - off_y, CAMERA.w, CAMERA.h]

  # Origin
  origin = $state.stage.origin = []
  origin.x = focus.right > limits.right ? (limits.right - CAMERA.w): [focus.left, limits.left].max
  origin.y = focus.top > limits.top ? (limits.top - CAMERA.h): [focus.bottom, limits.bottom].max
end

def set_time_of_day(t)
  t %= 24
  case t
  when (4..8)
    ss = (8.0 - t) / 4.0
  when (8..16)
    ss = 0.0
  when (16..20)
    ss = (t - 16.0) / 4.0
  else
    ss = 1.0
  end

  $state.time_of_day = (ss == 1.0) ? 'night' : ''
  $state.sky.sunset = ss
end

def tick(args)
  init_game(args) if args.tick_count.zero?
  window = DrawWindow.new(args, CAMERA.w, CAMERA.h, 15)
  focus_stage(40 + args.tick_count, 0)
  set_time_of_day(24 * args.tick_count / 1200.0)
  window.outputs.sprites << Skypainter.new
  window.outputs.sprites << Tilepainter.new
  
  window.draw
  # $game = @game = Game.new(args) if args.tick_count.zero?
  # @game.update
  # @game.draw
end
