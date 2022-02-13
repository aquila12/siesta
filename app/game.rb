# frozen_string_literal: true

def draw_stagescene
  window = DrawWindow.new($args, CAMERA.w, CAMERA.h, 15)

  window.outputs.solids << CAMERA + Color[NOKIA_LCD_DARK].rgb
  $sky.draw(window.outputs)
  $level.draw(window.outputs)

  window.draw
end

def do_movement
  actor = $level.actor
  input = $state.input
  dx = input.dpad.x * PLAYER_SPEED[$state.player_type]

  if $state.time_to_idle <= 0
    stance = :rest
  else
    stance = dx.zero? ? :wait : :walk
    actor.position.x += dx
    actor.mirror = dx.negative? ? true : dx.positive? ? false : actor.mirror
  end

  dismount = input.dismount && $state.player_type == :mounted
  Horse.dismount(mirror: actor.mirror) if dismount

  actor.spr = :"#{$state.player_type}_#{stance}"
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
  input = $state.input = { }

  if $state.time < 7
    case $state.time
    when (1..3) then map_input r: true
    when (4..5) then map_input l: true
    end
  else
    map_input l: args.inputs.keyboard.key_held.a,
              r: args.inputs.keyboard.key_held.d,
              interact: args.inputs.keyboard.key_down.w,
              dismount: args.inputs.keyboard.key_down.s
  end

  $state.time_to_idle = 120 unless input.empty?
  $state.time_to_idle -= 1

  input.dpad = [intybool(input.r) - intybool(input.l), 0]
end

def init_game
  $state = $gtk.args.state

  $state.player_position = [20, TILE_SIZE]
  $state.player_type = :player
  $state.time_to_idle = 0

  $state.time = 0
  $state.clock = 6.5

  $sky = Sky.new
  $level = Level.new
end

def advance_time
  $state.time += 1 / 60.0

  $state.clock += TIME_SCALE / 60.0
  $state.clock %= 24

  $state.time_of_day = ($state.clock < 5.5 || $state.clock > 18.5) ? :night : :day
end

def tick(args)
  init_game if args.tick_count.zero?
  advance_time

  do_input(args)
  do_movement
  # puts $level.actor

  $level.update
  $level.focus($level.actor.position)

  # $game = @game = Game.new(args) if args.tick_count.zero?
  # @game.update
  draw_stagescene
end
