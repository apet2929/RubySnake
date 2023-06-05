#!/usr/bin/env ruby

require 'gosu'

SCALE = 1

module Direction
  LEFT = [-1, 0]
  RIGHT = [1, 0]
  UP = [0, -1]
  DOWN = [0, 1]
end

class Snake
  def initialize
    @image = Gosu::Image.new("#{__dir__}/images/head.png")
    @x = @y = 0.0
    @history = []
    @speed = 100
    @length = 1
    @direction = Direction::RIGHT
    p @direction
  end

  def key_press(left = false, right = false, up = false, down = false)
    if left
      @direction = Direction::LEFT
    elsif right
      @direction = Direction::RIGHT
    elsif up
      @direction = Direction::UP
    elsif down
      @direction = Direction::DOWN
    end
  end

  def update(dt)
    @history.pop
    @history.append([@x, @y])

    oldx = @x.round
    oldy = @y.round

    @x += @direction[0] * @speed * dt
    @y += @direction[1] * @speed * dt
    newx = @x.round
    newy = @y.round


    if oldx != newx || oldy != newy
    #   entered new square
    end

  end

  def draw()
    @image.draw(@x, @y, 0, SCALE, SCALE)
  end
end

class Window < Gosu::Window
  def initialize
    super 800, 800

    self.caption = 'Sample Example'

    @keyboard = Gosu::Image.new("#{__dir__}/images/keyboard.png")
    @background = Gosu::Image.new("#{__dir__}/images/grass.png")
    @width = 20
    @height = 20
    @bg_size = 32
    @margin = 50
    @snake = Snake.new
    @time = -1.0

  end

  def draw
    for i in 0..@width
      for j in 0..@height
        # I add i and j here to add a 1 pixel gap between each tile
        x = (i * @bg_size * SCALE) + @margin + i
        y = (j * @bg_size * SCALE) + @margin + j
        @background.draw(x, y, 0, SCALE, SCALE)
      end
    end
    @snake.draw()


  end

  def update
    if @time == -1
      @time = Gosu.milliseconds
      return
    end
    dt = (Gosu.milliseconds - @time) / 1000.0
    @time = Gosu.milliseconds

    @snake.update(dt)

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
end

Window.new.show