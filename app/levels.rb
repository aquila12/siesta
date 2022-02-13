# frozen_string_literal: true

AREAS = {
  track: {
    facing: :se,
    dimensions: [210, 12],
    tileset: 'level',
    tile_loader: proc do
      stratum 0, 1
      stratum 1 do |i|
        case i
        when (20..30), (33..40)
          [4, 5, 6].sample
        else 0
        end
      end
    end,
    furniture_loader: proc do
      insert_object(GameObject.make(:gate, [32*TILE_SIZE, TILE_SIZE]))
      15.times do
        insert_object(
          GameObject.make(
            %i[cactus bush gate].sample,
            [ rand(@rectangle.w - SPRITE_SIZE.w), TILE_SIZE],
            mirror: [true, false].sample
          )
        )
      end
    end,
    door_loader: proc do
      insert_hotspot(
        position: [32 * TILE_SIZE, TILE_SIZE],
        hitbox: WARP_HITBOX,
      ) { load_level :field, at: [16, TILE_SIZE] }
    end
  },

  field: {
    facing: :s,
    dimensions: [42, 12],
    tileset: 'level',
    tile_loader: proc do
      stratum 0, 1
      stratum 1 do |i|
        case i
        when (0..5), (36..41)
          [4, 5, 6].sample
        else
          rand < 0.2 ? 7 : 3
        end
      end
    end,
    door_loader: proc do
      insert_hotspot(
        auto: true,
        position: [0, 0],
        hitbox: WARP_HITBOX,
      ) { load_level :track, at: [32 * TILE_SIZE, TILE_SIZE]}
    end
  }
}
