# frozen_string_literal: true

class GameObject
  def self.make(what, position, mirror: false)
    { position: position, spr: what, fr: 0, t: 0.0, mirror: mirror }
  end

  def initialize(position)
    @position = position
    @sprites = []
  end

  def make(*args)
    self.class.make(*args)
  end

  def insert(level)
    @level = level
  end

  def remove
    @sprites.each do |s|
      @level.objects.delete(s)
    end
  end

  def sprite(*s)
    @level.objects.push(*s)
    @sprites.push(*s)
  end

  def hotspot(hitbox:, auto: false, &block)
    block ||= proc { interact }
    @level.insert_hotspot(auto: auto, position: @position, hitbox: hitbox, &block)
  end

  def trigger(*args, &block)
    block ||= proc { timeout }
    @level.insert_trigger(*args, &block)
  end
end

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
