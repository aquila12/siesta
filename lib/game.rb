# frozen_string_literal: true

class Game
  def initialize(args)
    @args = args
    @window = DrawWindow.new(args, 84, 48, 15)
    @stage = Stage.new(840, 60, window: [84, 48])
    @bg_stage = Stage.new(120, 120, window: [84, 48])
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
    @bg_stage.add(@sky_tilemap)
  end

  def init_sky
    @sky_tilemap = Tilemap.new(30, 30, TILESET[:sky], 4)
    ([0] * 15 + [1] * 2 + [2] * 3 + [3] * 2).each.with_index do |value, line|
      30.times { |n| @sky_tilemap.poke(n, line, value) }
    end
  end

  def init_ground
    @ground_tilemap = Tilemap.new(210,1, TILESET[:level_tile], 1)
  end

  def set_time_of_day
    tod = @args.tick_count / 1200.0
    tod = 1.0 - tod if(tod > 0.5)
    tod *= 2
    @bg_stage.focus(42, 24 + tod * 100)
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

def tick(args)
  $game = @game = Game.new(args) if args.tick_count.zero?
  @game.update
  @game.draw
end
