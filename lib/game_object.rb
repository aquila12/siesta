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
