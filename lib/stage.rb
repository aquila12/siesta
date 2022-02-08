# frozen_string_literal: true

class Stage
  attr_reader :x, :y

  def initialize(width, height, window:)
    @left, @right = [0, width]
    @bottom, @top = [0, height]
    @cam_w = [width, window.x].min
    @cam_h = [height, window.y].min
    @off_x, @off_y = [@cam_w / 2, @cam_h / 2]
    focus(0, 0)

    @items = []
  end

  def focus(x, y)
    l, r = [x - @off_x, x + @off_x]
    b, t = [y - @off_y, y + @off_y]

    # Origin
    @x = r > @right ? (@right - @cam_w): [l, @left].max
    @y = t > @top ? (@top - @cam_h): [b, @bottom].max
  end

  def origin
    [@x, @y]
  end

  def rel(x, y)
    [x - @x, y - @y]
  end

  def camera
    [@cam_w, @cam_h]
  end

  def add(*items)
    items.each do |i|
      @items << i
      i.stage = self
    end
  end

  def remove(*items)
    items.each do |i|
      @items.delete(i)
      i.stage = nil
    end
  end
end
