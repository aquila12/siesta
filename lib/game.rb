# frozen_string_literal: true

class Game
  def initialize(args)
    @args = args
    @window = DrawWindow.new(args, 84, 48, 15)
    init_sky
    init_ground
  end

  def init_sky
    @sky_tilemap = Tilemap.new(30, 30, TILESET[:sky], 4)
    @sky_tilemap.window_shape(84, 48)
    ([0] * 15 + [1] * 2 + [2] * 3 + [3] * 2).each.with_index do |value, line|
      30.times { |n| @sky_tilemap.poke(n, line, value) }
    end
  end

  def init_ground
    @ground_tilemap = Tilemap.new(120,1, TILESET[:level_tile], 1)
    @ground_tilemap.window_shape(84, 48)
  end

  def set_time_of_day
    tod = @args.tick_count / 1200.0
    tod = 1.0 - tod if(tod > 0.5)
    tod *= 2
    @sky_tilemap.focus_window(42, 24 + tod * 100)
  end

  def draw
    tilemaps = [@sky_tilemap, @ground_tilemap]
    @ground_tilemap.focus_window(42 + @args.tick_count / 2, 24)
    set_time_of_day

    @window.outputs.sprites << tilemaps
    #@window.outputs << objects
    #@window.outputs << actors
    @window.draw
  end
end

def tick(args)
  $game = @game = Game.new(args) if args.tick_count.zero?
  #@game.update
  @game.draw
end
