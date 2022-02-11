# frozen_string_literal: true

class TimeOfDay
  class << self
    def set(t)
      t = t % 24
      sky = $state.sky

      sky.object = sky_object(t)
      sky.origin = [0, sunset_phase(t) * sky.dimensions.h * TILE_SIZE]
      $state.time_of_day = (t < 5 || t > 19) ? 'night' : 'day'
    end

    def sunset_phase(t)
      case t
      when (4..8) then (8.0 - t) / 4.0
      when (8..16) then 0.0
      when (16..20) then (t - 16.0) / 4.0
      else 1.0
      end
    end

    def sky_object(t)
      x_scale = CAMERA.w - SKY_OBJECT_SIZE
      y_scale = 4 * CAMERA.h
      p = ((t + 6) % 12) / 12.0
      x =
      {
        x: p * x_scale, y: y_scale * (p * (1 - p)) - SKY_OBJECT_SIZE,
        w: SKY_OBJECT_SIZE, h: SKY_OBJECT_SIZE,
        path: 'resources/skyobjects.png',
        tile_x: sky_object_id(t) * SKY_OBJECT_SIZE, tile_y: 0,
        tile_w: SKY_OBJECT_SIZE, tile_h: SKY_OBJECT_SIZE,
      }
    end

    def sky_object_id(t)
      case t
      when (6..9) then 0
      when (9..15) then 2
      when (15..18) then 0
      else 1
      end
    end
  end
end
