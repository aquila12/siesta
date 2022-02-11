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
  load_stage_tiles
  adjust_stage_geometry
  load_stage_furniture
end

def load_stage_tiles
  dims = [0, 0, 210, 12]
  stage = $state.stage = {}

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

  stage.passives = []
  10.times do
    f = {}
    f.resource = %i[cactus bush gate].sample
    f.position = [rand(stage.rectangle.w), TILE_SIZE]
    f.t = 0.0
    stage.passives << f
  end
end
