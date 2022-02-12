# frozen_string_literal: true

def focus_stage(target)
  limits = $state.stage.viewrect
  off_x, off_y = [CAMERA.w / 2, CAMERA.h / 2]
  focus = [target.x.round - off_x, target.y.round - off_y, CAMERA.w, CAMERA.h]
  # Origin
  origin = $state.stage.origin = []
  origin.x = focus.right > limits.right ? (limits.right - CAMERA.w): [focus.left, limits.left].max
  origin.y = focus.top > limits.top ? (limits.top - CAMERA.h): [focus.bottom, limits.bottom].max
end

def draw_stagescene
  stage = $state.stage
  sky = $state.sky
  time = $state.time_of_day

  window = DrawWindow.new($args, CAMERA.w, CAMERA.h, 15)
  window.outputs.solids << CAMERA + Color[NOKIA_LCD_DARK].rgb
  window.outputs.sprites << Tilepainter.new(sky, stride_i: 0, stride_j: 1)
  window.outputs.sprites << sky.object

  window.outputs.sprites << Tilepainter.new(stage, inverse: time == :night)
  window.outputs.sprites << Spritepainter.new(stage, SPRITE_TINT[time]).animate

  window.draw
end

def demo_move
  case $state.time
  when (1..6) then dx = 1
  when (8..10) then dx = -1
  when (12..15) then dx = nil
  else dx = 0
  end

  actor = $state.stage.actor
  if dx
    actor.spr = dx.zero? ? :player_wait : :player_walk
    actor.x += 0.25 * dx
    actor.mirror = dx.negative? ? true : dx.positive? ? false : actor.mirror
  else
    actor.spr = :player_rest
  end
end

def do_movement
  actor = $state.stage.actor
  input = $state.input
  dx = input.dpad.x * 0.25

  if input.idle
    actor.spr = :player_rest
  else
    actor.spr = dx.zero? ? :player_wait : :player_walk
    actor.x += dx
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

def tick(args)
  init_game(args) if args.tick_count.zero?
  $state.time = args.tick_count / 60.0
  TimeOfDay.set($state.time * TIME_SCALE)

  do_input(args)

  if($state.time > 15)
    do_movement
  else
    demo_move
  end

  focus_stage($state.stage.actor)

  # $game = @game = Game.new(args) if args.tick_count.zero?
  # @game.update
  draw_stagescene
end
