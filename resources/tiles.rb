ImageTiles.load('resources/tiles.png', grid: [4, 4]) do
  actor :manuel,
    idle: [0, 0, 2, 2],
    walk: [0, 0, 2, 2, 4],
    rest: [8, 0, 2, 2]

  object :horse, 0, 2, 4, 2, 4

  actor :mount,
    idle: [0, 4, 4, 3],
    walk: [4, 4, 4, 3, 6],
    rest: [16, 1, 4, 3, 4]

  objects 0, 13, 2, 2, %i[cactus bush gate]

  tileset :level_tile, 0, 15, 1, 1, 24
  tileset :sky, 24, 15, 1, 1, 5

  objects 23, 12, 3, 3, %i[:sun_low :moon :sun_high], anchor: [0.5, 0.5]
  object :cloud, 27, 10, 5, 2
end
