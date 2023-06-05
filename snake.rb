#!/usr/bin/env ruby

require 'gosu'

SCALE = 1
MARGIN = 50
BG_SIZE = 32


module Direction
  LEFT = [-1, 0]
  RIGHT = [1, 0]
  UP = [0, -1]
  DOWN = [0, 1]
end

def get_screen_pos(grid_x, grid_y)
  return [(grid_x * BG_SIZE * SCALE) + MARGIN + grid_x,
          (grid_y * BG_SIZE * SCALE) + MARGIN + grid_y
  ]
end

def get_grid_pos(screen_x, screen_y)
  x = (screen_x - MARGIN) / (BG_SIZE * SCALE)
  y = (screen_y - MARGIN) / (BG_SIZE * SCALE)
  return [x, y]
end

class Snake
  def initialize
    @head = Gosu::Image.new("#{__dir__}/images/head.png")
    @body = Gosu::Image.new("#{__dir__}/images/body.png")
    @x = @y = 0
    @history = []
    @speed = 2
    @length = 3
    @direction = Direction::RIGHT
    p @direction
  end

  def key_press(left = false, right = false, up = false, down = false)
    gp = get_grid_pos(@x, @y)
    p gp
    gx = gp[0] - gp[0].floor
    gy = gp[1] - gp[1].floor
    p [gx, gy]


    # if gy.abs > 0.5 && (left || right)
    #   gp[1] += @direction[0]
    # end
    # if gx.abs > 0.5 && (up || down)
    #   gp[0] += @direction[0]
    # end

    if left && @direction != Direction::RIGHT
      @direction = Direction::LEFT
      @y = @y.round # snap to nearest row/col
    elsif right && @direction != Direction::LEFT
      @direction = Direction::RIGHT
      @y = @y.round # snap to nearest row/col
    elsif up && @direction != Direction::DOWN
      @direction = Direction::UP
      @x = @x.round # snap to nearest row/col
    elsif down && @direction != Direction::UP
      @direction = Direction::DOWN
      @x = @x.round # snap to nearest row/col
    end
  end

  def update(dt, apple)
    oldx = @x.floor
    oldy = @y.floor

    @x += @direction[0] * @speed * dt
    @y += @direction[1] * @speed * dt
    newx = @x.floor
    newy = @y.floor

    if oldx != newx || oldy != newy
      if @history.length == @length
        @history.delete_at(0)
      end
      @history.append([oldx, oldy])
      p [@x, @y]
    end



    if intersects(apple[0], apple[1])
      @length += 1
      return true
    end
    return false
  end

  def draw()
    pos = get_screen_pos(@x, @y)
    pos[0] += BG_SIZE / 2
    pos[1] += BG_SIZE / 2

    if @direction == Direction::LEFT
      @head.draw_rot(pos[0], pos[1], 0, 180, 0.5, 0.5, SCALE, SCALE)
    elsif @direction == Direction::RIGHT
      @head.draw_rot(pos[0], pos[1], 0, 0, 0.5, 0.5, SCALE, SCALE)
    elsif @direction == Direction::UP
      @head.draw_rot(pos[0], pos[1], 0, 270, 0.5, 0.5, SCALE, SCALE)
    elsif @direction == Direction::DOWN
      @head.draw_rot(pos[0], pos[1], 0, 90, 0.5, 0.5, SCALE, SCALE)
    end

    for pos in @history
      bp = get_screen_pos(pos[0], pos[1])
      bp[0] += BG_SIZE / 2
      bp[1] += BG_SIZE / 2
      @body.draw_rot(bp[0], bp[1], 0, 0, 0.5, 0.5, SCALE, SCALE)
    end
  end

  def intersects(grid_x, grid_y)

    # p "Snake(#{[@x, @y]}), Apple(#{[grid_x, grid_y]})"
    if @x.floor == grid_x && @y.floor == grid_y
      return true
    end

    for pos in @history
      gx, gy = get_grid_pos(pos[0], pos[1])
      gx = gx.floor
      gy = gy.floor
      if gx == grid_x && gy == grid_y
        return true
      end
    end
    return false
  end
end

class Window < Gosu::Window
  def initialize
    super 800, 800

    self.caption = 'Sample Example'

    @keyboard = Gosu::Image.new("#{__dir__}/images/keyboard.png")
    @background = Gosu::Image.new("#{__dir__}/images/grass.png")
    @apple_tex = Gosu::Image.new("#{__dir__}/images/apple.png")
    @width = 20
    @height = 20
    @snake = Snake.new
    @time = -1.0
    @apple = []

  end

  def draw
    for i in 0..@width
      for j in 0..@height
        # I add i and j here to add a 1 pixel gap between each tile
        x, y = get_screen_pos(i, j)
        @background.draw(x, y, 0, SCALE, SCALE)
      end
    end
    if @apple != nil
      apos = get_screen_pos(@apple[0], @apple[1])
      @apple_tex.draw(apos[0], apos[1], 0, SCALE, SCALE)
      gp = get_grid_pos(apos[0], apos[1])
      sp = get_screen_pos(gp[0], gp[1])
      @apple_tex.draw(sp[0], sp[1], 0, SCALE, SCALE)
    end

    @snake.draw()

  end

  def update
    if @time == -1
      @time = Gosu.milliseconds
      @apple = viable_apple_pos
      return
    end

    dt = (Gosu.milliseconds - @time) / 1000.0
    @time = Gosu.milliseconds

    spawn_apple = @snake.update(dt, @apple)
    if spawn_apple
      @apple = viable_apple_pos
      p "Apple(#{@apple}"
    end
  end

  def button_down(id)
    if id == Gosu::KB_W
      @snake.key_press(false, false, true, false)
    elsif id == Gosu::KB_A
      @snake.key_press(true, false, false, false)
    elsif id == Gosu::KB_S
      @snake.key_press(false, false, false, true)
    elsif id == Gosu::KB_D
      @snake.key_press(false, true, false, false)
    else
      puts "Hello world!"
    end
  end

  def viable_apple_pos
    pos = [(Random.rand() * @width).floor, (Random.rand() * @height).floor]
    while @snake.intersects(pos[0], pos[1])
      pos = [(Random.rand() * @width).floor, (Random.rand() * @height).floor]
    end
    pos
  end
end

Window.new.show