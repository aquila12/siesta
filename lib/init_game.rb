# frozen_string_literal: true

def init_game(args)
  $state = args.state
  init_sky
  load_stage
end

def init_sky
  sky = $state.sky = {}
  sky.tiledata = [0] * 12 + [1] * 3 + [2] * 2 + [3] * 3
  sky.tileset = 'sky'
  sky.dimensions = [0, 0, 21, sky.tiledata.length]
end

# Stubby
def load_stage
  stage = $state.stage = {}
  stage.passives = []
  stage.objects = []
  stage.actors = nil

  load_stage_tiles
  adjust_stage_geometry
  load_stage_furniture
  insert_game_objects
end

def load_stage_tiles
  stage = $state.stage
  dims = [0, 0, 210, 12]

  stage.tileset = 'level'
  stage.tiledata = Array.new(dims.w * dims.h, 0) { |n| (n < dims.w) ? 1 : 0 }
  stage.dimensions = dims
end

def adjust_stage_geometry
  stage = $state.stage
  dims = stage.dimensions

  stage.rectangle = dims.scale_rect(TILE_SIZE)
  stage.viewrect = dims.scale_rect(TILE_SIZE)
  if stage.rectangle.w < CAMERA.w
    stage.viewrect.x = (stage.rectangle.w - CAMERA.w) / 2
    stage.viewrect.w = CAMERA.w
  end

  if stage.rectangle.h < CAMERA.h
    stage.viewrect.y = (stage.rectangle.h - CAMERA.h) / 2
    stage.viewrect.h = CAMERA.h
  end
end

def load_stage_furniture
  stage = $state.stage

  15.times do
    stage.passives << Spritepainter.make_sprite(
      %i[cactus bush gate].sample,
      rand(stage.rectangle.w - SPRITE_SIZE.w),
      TILE_SIZE,
      mirror: [true, false].sample
    )
  end
end

def insert_game_objects
  stage = $state.stage

  fire_x = rand(stage.rectangle.w - SPRITE_SIZE.w)
  stage.objects << Spritepainter.make_sprite(:campfire, fire_x, TILE_SIZE)
  stage.objects << Spritepainter.make_sprite(:flame, fire_x, TILE_SIZE)
  stage.objects << Spritepainter.make_sprite(:smoke, fire_x, TILE_SIZE*2)

  stage.actor = Spritepainter.make_sprite(
    :player_walk,
    20,
    TILE_SIZE
  )
end
