# frozen_string_literal: true

class Campfire < GameObject
  def initialize(position)
    super

    @fire = make(:campfire, position)
    @flame = make(:flame, position)
    @smoke = make(:smoke, position.rect_shift(0, TILE_SIZE))
  end

  def insert(level)
    super
    sprite @fire
    hotspot hitbox: [-6, -1, 12, 12]
  end

  def interact
    return unless $state.clock > 17

    sprite @flame, @smoke
    trigger(clock: 1) { stop_flame }
    trigger(clock: 9) { stop_smoke }
    true
  end

  def stop_flame
    @level.objects.delete(@flame)
  end

  def stop_smoke
    @level.objects.delete(@smoke)
  end
end

class Horse < GameObject
  def self.dismount(mirror: false)
    $state.player_type = :player
    position = $state.player_position.rect_shift([0, 0])
    new(position, mirror: mirror).insert($level)
  end

  def initialize(position, mirror: false)
    super(position)
    @horse = make(:horse, position, mirror: mirror)
  end

  def insert(level)
    super
    sprite @horse
    hotspot hitbox: [-8, -1, 16, 12]
  end

  def interact
    $state.player_type = :mounted
    $state.player_position.x = @position.x
    remove
    true
  end
end
