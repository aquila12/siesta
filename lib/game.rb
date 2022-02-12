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

def demo_move(t)
  case t % 16
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

def tick(args)
  init_game(args) if args.tick_count.zero?
  TimeOfDay.set(args.tick_count * TIME_SCALE)

  demo_move(args.tick_count / 60.0)

  focus_stage($state.stage.actor)

  # $game = @game = Game.new(args) if args.tick_count.zero?
  # @game.update
  draw_stagescene
end
