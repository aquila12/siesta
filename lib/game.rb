# frozen_string_literal: true

def draw_stagescene
  window = DrawWindow.new($args, CAMERA.w, CAMERA.h, 15)

  window.outputs.solids << CAMERA + Color[NOKIA_LCD_DARK].rgb
  $sky.draw(window.outputs)
  $level.draw(window.outputs)

  window.draw
end

def demo_move
  case $state.time
  when (1..6) then dx = 1
  when (8..10) then dx = -1
  when (12..15) then dx = nil
  else dx = 0
  end

  actor = $level.actor
  if dx
    actor.spr = dx.zero? ? :player_wait : :player_walk
    actor.position.x += 0.25 * dx
    actor.mirror = dx.negative? ? true : dx.positive? ? false : actor.mirror
  else
    actor.spr = :player_rest
  end
end

def do_movement
  actor = $level.actor
  input = $state.input
  dx = input.dpad.x * 0.25

  if input.idle
    actor.spr = :player_rest
  else
    actor.spr = dx.zero? ? :player_wait : :player_walk
    actor.position.x += dx
    actor.mirror = dx.negative? ? true : dx.positive? ? false : actor.mirror
  end
end

def intybool(x)
  x ? 1 : 0
end

def map_input(**what)
  what.each do |k, v|
    $state.input[k] = v if v
  end
end

def do_input(args)
  input = $state.input = {}

  map_input l: args.inputs.keyboard.key_held.a,
            r: args.inputs.keyboard.key_held.d

  $state.time_to_idle = 120 unless input.empty?
  $state.time_to_idle -= 1
  input.idle = $state.time_to_idle <= 0

  input.dpad = [intybool(input.r) - intybool(input.l), 0]
end

def init_game
  $state = $gtk.args.state

  $state.player_position = [20, TILE_SIZE]
  $state.time_to_idle = 0

  $state.time = 0
  $state.clock = 6.0

  $sky = Sky.new
  $level = Level.new
end

def advance_time
  $state.time += 1 / 60.0

  $state.clock += TIME_SCALE / 60.0
  $state.clock %= 24

  $state.time_of_day = ($state.clock < 5 || $state.clock > 19) ? :night : :day
end

def tick(args)
  init_game if args.tick_count.zero?
  advance_time

  do_input(args)

  if($state.time > 15)
    do_movement
  else
    demo_move
  end

  $level.update
  $level.focus($level.actor.position)

  # $game = @game = Game.new(args) if args.tick_count.zero?
  # @game.update
  draw_stagescene
end
