# frozen_string_literal: true

NOKIA_LCD_LIGHT = '#c7f0d8'
NOKIA_LCD_DARK  = '#43523d'

TILE_SIZE = 4
TILES_PER_ROW = 8

SKY_OBJECT_SIZE = 12

CAMERA = [0, 0, 84, 48]
TIME_SCALE = 24.0 / 60 / 120

SPRITE_SIZE = [0, 0, 16, 12]

SPRITES = {
  player_wait: [1],
  player_walk: [1, 2, 3, 4],
  player_rest: [5],
  mounted_wait: [0],
  mounted_walk: [24, 25, 26, 27, 28, 29],
  mounted_rest: [8, 9, 10, 11],
  smoke: [32, 33, 34, 35],
  flame: [36, 37, 38, 39],
  cactus: [40],
  gate: [41],
  bush: [42],
  campfire: [43]
}

SPRITE_TINT = {
  night: Color[NOKIA_LCD_LIGHT].rgb,
  day: Color[NOKIA_LCD_DARK].rgb
}.freeze
