# Basically, the tutorial game taken to a jump'n'run perspective.

# Shows how to
#  * implement jumping/gravity
#  * implement scrolling using Window#translate
#  * implement a simple tile-based map
#  * load levels from primitive text files

# Some exercises, starting at the real basics:
#  0) understand the existing code!
# As shown in the tutorial:
#  1) change it use Gosu's Z-ordering
#  2) add gamepad support
#  3) add a score as in the tutorial game
#  4) similarly, add sound effects for various events
# Exploring this game's code and Gosu:
#  5) make the player wider, so he doesn't fall off edges as easily
#  6) add background music (check if playing in Window#update to implement 
#     looping)
#  7) implement parallax scrolling for the star background!
# Getting tricky:
#  8) optimize Map#draw so only tiles on screen are drawn (needs modulo, a pen
#     and paper to figure out)
#  9) add loading of next level when all gems are collected
# ...Enemies, a more sophisticated object system, weapons, title and credits
# screens...

require 'rubygems'
require 'gosu'
include Gosu

module ZOrder
  Background, Player, Map, Gem, Score = *0..5
end

module Tiles
  Grass = 0
  Earth = 1
end

class CollectibleGem
  attr_reader :x, :y

  def initialize(image, x, y)
    @image = image
    @x, @y = x, y
  end
  
  def draw
    # Draw, slowly rotating
    @image.draw_rot(@x, @y, 0, 25 * Math.sin(milliseconds / 133.7))
  end
end

# Player class.
class CptnRuby
  attr_reader :x, :y

  def initialize(window, x, y)
    @x, @y = x, y
    @dir = :down
    @vy = 0 # Vertical velocity
    @map = window.map
    # Load all animation frames
    @down, @up, @right, @left =
      *Image.load_tiles(window, "media/sir.png", 50, 50, false)
    # This always points to the frame that is currently drawn.
    # This is set in update, and used in draw.
    @cur_image = @standing    
  end
  
  def draw
    # Change image based on which direction player moves
    if @dir == :down then
      @cur_image = @down
      offs_y = -25
      offs_x = -25
      factor = 1.0
    
    elsif @dir == :up then
      @cur_image = @up
      offs_x = 25
      offs_y = 25
      factor = -1.0
    
    elsif @dir == :left then
      @cur_image = @left
      offs_x = 25
      offs_y = -25
      factor = -1.0

    elsif @dir == :right then
      @cur_image = @right
      offs_x = 25
      offs_y = 25
      factor = -1.0
    end
    @cur_image.draw(@x + offs_x, @y - 49, 0, factor, 1.0)
  end
  
  # Could the object be placed at x + offs_x/y + offs_y without being stuck?
  def would_fit(offs_x, offs_y)
    # Check at the center/top and center/bottom for map collisions
    not @map.solid?(@x + offs_x, @y + offs_y) and
      not @map.solid?(@x + offs_x, @y + offs_y - 45)
  end
  
  def update(move_x, move_y)
    # Select image depending on action
    if (move_x == 0)
      @cur_image = @down
    else
      #@cur_image = (milliseconds / 175 % 2 == 0) ? @walk1 : @walk2
    end
    if (@vy < 0)
      @cur_image = @jump
    end
    
    # Directional walking, horizontal movement
    if move_x > 0 then
      @dir = :right
      move_x.times { if would_fit(2, 0) then @x += 1 end }
    end
    if move_x < 0 then
      @dir = :left
      (-move_x).times { if would_fit(-2, 0) then @x -= 1 end }
    end
    if move_y > 0 then
      @dir = :down
      move_y.times { if would_fit(1, 1) then @y += 1 end }
    end
    if move_y < 0 then
      @dir = :up
      (-move_y).times { if would_fit(-1, -1) then @y -= 1 end }
    end
  end
  
  
  def collect_gems(gems)
    # Same as in the tutorial game.
    gems.reject! do |c|
      (c.x - @x).abs < 50 and (c.y - @y).abs < 50
    end
  end
end


# Enemy class.
class Enemy
  attr_reader :x, :y

  def initialize(window, x, y)
    @x, @y = x, y
    @dir = :down
    @vy = 0 # Vertical velocity
    @map = window.map
    # Load all animation frames
    @down, @up, @right, @left =
      *Image.load_tiles(window, "media/red.png", 50, 50, false)
    # This always points to the frame that is currently drawn.
    # This is set in update, and used in draw.
    @cur_image = @down   
  end
  
  def draw
    # Flip vertically when facing to the left.
    if @dir == :down then
      @cur_image = @down
      offs_y = -25
      offs_x = -25
      factor = 1.0
    
    elsif @dir == :up then
      @cur_image = @up
      offs_x = 25
      offs_y = 25
      factor = -1.0
    
    elsif @dir == :left then
      @cur_image = @left
      offs_x = 25
      offs_y = -25
      factor = -1.0

    elsif @dir == :right then
      @cur_image = @right
      offs_x = 25
      offs_y = 25
      factor = -1.0
    end
    @cur_image.draw(@x + offs_x, @y - 49, 0, factor, 1.0)
  end
  
  # Could the object be placed at x + offs_x/y + offs_y without being stuck?
  def would_fit(offs_x, offs_y)
    # Check at the center/top and center/bottom for map collisions
    not @map.solid?(@x + offs_x, @y + offs_y) and
      not @map.solid?(@x + offs_x, @y + offs_y - 45)
  end
  
  def update(move_x, move_y)
    # Select image depending on action
    if (move_x == 0)
      @cur_image = @down
    else
      #@cur_image = (milliseconds / 175 % 2 == 0) ? @walk1 : @walk2
    end
    if (@vy < 0)
      @cur_image = @jump
    end
    
    # Directional walking, horizontal movement
    if move_x > 0 then
      @dir = :right
      move_x.times { if would_fit(1, 0) then @x += 1 end }
    end
    if move_x < 0 then
      @dir = :left
      (-move_x).times { if would_fit(-1, 0) then @x -= 1 end }
    end
    if move_y > 0 then
      @dir = :down
      move_y.times { if would_fit(1, 1) then @y += 1 end }
    end
    if move_y < 0 then
      @dir = :up
      (-move_y).times { if would_fit(-1, -1) then @y -= 1 end }
    end
  end
  
  
  def collect_gems(gems)
    # Same as in the tutorial game.
    gems.reject! do |c|
      (c.x - @x).abs < 50 and (c.y - @y).abs < 50
    end
  end
end

# Map class holds and draws tiles and gems.
class Map
  attr_reader :width, :height, :gems
  
  def initialize(window, filename)
    # Load 60x60 tiles, 5px overlap in all four directions.
    @tileset = Image.load_tiles(window, "media/CptnRuby Tileset.png", 60, 60, true)

    gem_img = Image.new(window, "media/CptnRuby Gem.png", false)
    @gems = []

    lines = File.readlines(filename).map { |line| line.chomp }
    @height = lines.size
    @width = lines[0].size
    @tiles = Array.new(@width) do |x|
      Array.new(@height) do |y|
        case lines[y][x, 1]
        when '"'
          Tiles::Grass
        when '#'
          Tiles::Earth
        when 'x'
          @gems.push(CollectibleGem.new(gem_img, x * 50 + 25, y * 50 + 25))
          nil
        else
          nil
        end
      end
    end
  end
  
  def draw
    # Very primitive drawing function:
    # Draws all the tiles, some off-screen, some on-screen.
    @height.times do |y|
      @width.times do |x|
        tile = @tiles[x][y]
        if tile
          # Draw the tile with an offset (tile images have some overlap)
          # Scrolling is implemented here just as in the game objects.
          @tileset[tile].draw(x * 50 - 5, y * 50 - 5, 0)
        end
      end
    end
    @gems.each { |c| c.draw }
  end
  
  # Solid at a given pixel position?
  def solid?(x, y)
    y < 0 || @tiles[x / 50][y / 50]
  end
end

class Game < Window
  attr_reader :map

  def initialize
    super(640, 480, false)
    self.caption = "Cptn. Ruby"
    @sky = Image.new(self, "media/crackedearth.png", true)
    @map = Map.new(self, "maze.txt")
    @cptn = CptnRuby.new(self, 400, 100)
    @red = Enemy.new(self, 400, 150)
    # The scrolling position is stored as top left corner of the screen.
    @camera_x = @camera_y = 0
    song = Gosu::Sample.new("media/background.wav")
    song.play
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20) 
  end

  def update
    move_x = 0
    move_y = 0
    # move_x -= 5 if button_down? KbLeft or button_down? GpLeft 
    # move_x += 5 if button_down? KbRight or button_down? GpRight
    # move_y -= 5 if button_down? KbUp or button_down? Gosu::GpUp
    # move_y += 5 if button_down? KbDown or button_down? Gosu::GpDown
    move_x -= 5 if button_down? KbLeft
    move_x += 5 if button_down? KbRight
    move_y -= 5 if button_down? KbUp
    move_y += 5 if button_down? KbDown
    @cptn.update(move_x, move_y)
    @cptn.collect_gems(@map.gems)
    # Scrolling follows player
    @camera_x = [[@cptn.x - 320, 0].max, @map.width * 50 - 640].min
    @camera_y = [[@cptn.y - 240, 0].max, @map.height * 50 - 480].min
  end

  def draw
    @sky.draw 0, 0, 0
    translate(-@camera_x, -@camera_y) do
      @map.draw
      @cptn.draw
      @red.draw
    end
  @font.draw("Drink wine", 185, 230, ZOrder::Score, 1.0, 1.0, 0xffffff00)
  end
  def button_down(id)
    if id == KbQ then close end
  end
end

Game.new.show
