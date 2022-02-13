# frozen_string_literal: true

NOKIA_LCD_LIGHT = '#c7f0d8'
NOKIA_LCD_DARK  = '#43523d'

TILE_SIZE = 4
TILES_PER_ROW = 8

SKY_OBJECT_SIZE = 12

CAMERA = [0, 0, 84, 48]
TIME_SCALE = 24.0 / 120

SPRITE_SIZE = [0, 0, 16, 12]

def sprite(first, count = 1, rate: 0)
  {
    frames: (first...(first + count)).to_a,
    rate: rate
  }
end

SPRITES = {
  player_wait: sprite(1),
  player_walk: sprite(1, 4, rate: 1/10),
  player_rest: sprite(5),
  mounted_wait: sprite(0),
  mounted_walk: sprite(24, 6, rate: 1/3),
  mounted_rest: sprite(8, 4, rate: 1/50),
  horse: sprite(16, 4, rate: 1/50),
  smoke: sprite(32, 4, rate: 1/12),
  flame: sprite(36, 4, rate: 1/8),
  cactus: sprite(40),
  gate: sprite(41),
  bush: sprite(42),
  campfire: sprite(43)
}

SPRITE_TINT = {
  night: Color[NOKIA_LCD_LIGHT].rgb,
  day: Color[NOKIA_LCD_DARK].rgb
}.freeze

PLAYER_SPEED = {
  player: 0.25,
  mounted: 0.5
}
