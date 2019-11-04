require 'gosu'

module ZOrder
    BACKGROUND, DOLLAR, BOMB, PLAYER, UI = *0..4
end

class Player
    attr_reader :score, :bombs_hit
    def initialize
        @image = Gosu::Image.new("pictures/char.png")
        @x = @vel_x = @score = @bombs_hit = 0
    end

    def warp(x, y)
        @x, @y = x, y
    end

    def accelerate_left
        @vel_x += -1
    end

    def accelerate_right
        @vel_x += 1
    end

    def move
        @x += @vel_x
        @x %= 640
        @vel_x *= 0.95
    end

    def draw
        @image.draw(@x, 380, ZOrder::PLAYER, 0.5, 0.5)
    end

    def score
        @score
    end

    def bombs_hit
        @bombs_hit
    end

    def collect_money5(dollars)
        dollars.reject! do |dollar|
            if Gosu.distance(@x, 380, dollar.x, dollar.y) < 42
                if @bombs_hit == 0
                    @score += 5
                    true
                end
            else
                false
            end
        end
    end

    def collect_money10(dollars)
        dollars.reject! do |dollar|
            if Gosu.distance(@x, 380, dollar.x, dollar.y) < 42
                if @bombs_hit == 0
                    @score += 10
                    true
                end
            else
                false
            end
        end
    end

    def collect_money20(dollars)
        dollars.reject! do |dollar|
            if Gosu.distance(@x, 380, dollar.x, dollar.y) < 42
                if @bombs_hit == 0
                    @score += 20
                    true
                end
            else
                false
            end
        end
    end

    def hit_bomb(bombs)
        bombs.reject! do |bomb|
            if Gosu.distance(@x, 380, bomb.x, bomb.y) < 42
                @bombs_hit += 1
                true
            else
                false
            end
        end
    end
end

class Dollar5
    attr_reader :x, :y
    def initialize
        @x = rand * 640
        @y = 0
    end

    def draw
        @image = Gosu::Image.new("pictures/coin.png")
        @image.draw(@x, @y, ZOrder::DOLLAR)
    end

    def move
        @y += 1
        if @y > 480 
            @x = rand * 640
            @y %= 480
        end
    end
end

class Dollar10
    attr_reader :x, :y
    def initialize
        @x = rand * 640
        @y = 0
    end

    def draw
        @image = Gosu::Image.new("pictures/dollar.png")
        @image.draw(@x, @y, ZOrder::DOLLAR)
    end

    def move
        @y += 3
        if @y > 480 
            @x = rand * 640
            @y %= 480
        end
    end
end

class Dollar20
    attr_reader :x, :y
    def initialize
        @x = rand * 640
        @y = 0
    end

    def draw
        @image = Gosu::Image.new("pictures/card.png")
        @image.draw(@x, @y, ZOrder::DOLLAR, 0.3, 0.3)
    end

    def move
        @y += 5
        if @y > 480 
            @x = rand * 640
            @y %= 480
        end
    end
end

class Bomb
    attr_reader :x, :y
    def initialize
        @x = rand * 640
        @y = 0
        @bomb_acceleration = rand(2)
    end

    def draw
        @image = Gosu::Image.new("pictures/bomb.png")
        @image.draw(@x, @y, ZOrder::BOMB, 0.3, 0.3)
    end

    def move
        @y += (2 + @bomb_acceleration)
        if @y > 480 
            @x = rand * 640
            @y %= 480
            @bomb_acceleration = 0
        end
        @bomb_acceleration += 0.03
    end
end

class Menu
    def draw
        @menu_image = Gosu::Image.new("pictures/space.png")
        @menu_image.draw(0, 0, ZOrder::UI)
    end
end

class Tutorial < Gosu::Window
    def initialize
        super 640, 480 
        self.caption = "L"
        @background_image = Gosu::Image.new("pictures/towers.jpg")
        @player = Player.new
        @player.warp(320, 380)
        @menu = Menu.new

        @dollars5 = Array.new
        @dollars10 = Array.new
        @dollars20 = Array.new
        @bombs = Array.new

        @font = Gosu::Font.new(20)
    end

    def update 
        if Gosu.button_down? Gosu::KB_LEFT
            @player.accelerate_left
        end
        if Gosu.button_down? Gosu::KB_RIGHT
            @player.accelerate_right
        end

        @player.move
        @dollars5.each { |dollar| dollar.move }
        @dollars10.each { |dollar| dollar.move }
        @dollars20.each { |dollar| dollar.move }
        @bombs.each { |bomb| bomb.move }
        @player.collect_money5(@dollars5)
        @player.collect_money10(@dollars10)
        @player.collect_money20(@dollars20)
        @player.hit_bomb(@bombs)

        if rand(100) < 1 and @bombs.size < 2
            @bombs.push(Bomb.new)
        end

        if rand(100) < 1 and @dollars5.size < 4
            @dollars5.push(Dollar5.new)
        end

        if rand(300) < 1 and @dollars10.size < 2
            @dollars10.push(Dollar10.new)
        end

        if rand(1000) < 1 and @dollars20.size < 1
            @dollars20.push(Dollar20.new)
        end
    end

    def draw
        @player.draw
        @background_image.draw(0, 0, ZOrder::BACKGROUND, 0.7, 0.7)
        @bombs.each { |bomb| bomb.draw }
        @dollars5.each { |dollar| dollar.draw }
        @dollars10.each { |dollar| dollar.draw }
        @dollars20.each { |dollar| dollar.draw }
        @font.draw_text("Score: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
        if @player.bombs_hit > 0
            @menu.draw
            @font.draw_text("Game Over, your score was #{@player.score}, press r to restart", 180, 240, ZOrder::UI, 1.0, 1.0, Gosu::Color::RED)
        end
    end

    def button_down(id)
        if id == Gosu::KB_R
            close
            Tutorial.new.show
        elsif id == Gosu::KB_ESCAPE
            close
        else
            super
        end
    end
end

Tutorial.new.show
        