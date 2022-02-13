# frozen_string_literal: true

class GameObject
  def self.make(what, position, mirror: false)
    { position: position, spr: what, fr: 0, t: 0.0, mirror: mirror }
  end
end

class Campfire
  INTERACT_HITBOX = [-TILE_SIZE, -TILE_SIZE, TILE_SIZE*2, TILE_SIZE*2]

  def initialize(position)
    @hitbox = INTERACT_HITBOX.rect_shift([position])

    @fire = GameObject.make(:campfire, position)
    @flame = GameObject.make(:flame, position)
    @smoke = GameObject.make(:smoke, position)#.rect_shift(0, TILE_SIZE))
  end

  def insert(level)
    @level = level
    @level.objects.push(@fire)

    @level.insert_hotspot(auto: false, rect: @hitbox) { interact }
  end

  def remove
    @level.objects.delete(@fire)
    @level.objects.delete(@flame)
    @level.objects.delete(@smoke)
  end

  def interact
    return unless $state.clock > 17

    @level.objects.push(@flame, @smoke)
    @level.insert_trigger(clock: 1) { stop_flame }
    @level.insert_trigger(clock: 9) { stop_smoke }
  end

  def stop_flame
    @level.objects.delete(@flame)
  end

  def stop_smoke
    @level.objects.delete(@smoke)
  end
end

class Horse
  INTERACT_HITBOX = [-SPRITE_SIZE.w/2, -TILE_SIZE, SPRITE_SIZE.w, TILE_SIZE*2]

  def initialize(position)
    @hitbox = INTERACT_HITBOX.rect_shift([position])
    @horse = GameObject.make(:horse, position)
  end

  def insert(level)
    @level = level
    @level.objects.push(@horse)

    @level.insert_hotspot(auto: false, rect: @hitbox) { interact }
  end

  def remove
    @level.objects.delete(@horse)
  end

  def interact
    $state.player_type = :mounted
    remove
  end
end
