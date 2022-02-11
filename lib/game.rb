# frozen_string_literal: true

def focus_stage(x, y)
  limits = $state.stage.viewrect
  off_x, off_y = [CAMERA.w / 2, CAMERA.h / 2]

  focus = [x.round - off_x, y.round - off_y, CAMERA.w, CAMERA.h]

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
  window.outputs.sprites << Spritepainter.new(stage, SPRITE_TINT[time])

  window.draw
end

def tick(args)
  init_game(args) if args.tick_count.zero?
  focus_stage(40 + args.tick_count, 0)
  TimeOfDay.set(args.tick_count * TIME_SCALE)

  # $game = @game = Game.new(args) if args.tick_count.zero?
  # @game.update
  draw_stagescene
end
