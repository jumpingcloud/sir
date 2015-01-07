# world builder

# requirements:
#   Needs to make a 25x55 character grid
# => be solvable
# => have randomly drawn map
# => Make a solid connected path from start point to end point
# => add randomness everywhere else.
# Boo-ya


class World

  def initialize
    #makes a blank 25x55 template
    File.open("maze.txt", 'w')
    @map = []
    @array = [] 
    @height = 25
    @width = 55
    @blank = "."
    @line = ""

    @width.times { @line += @blank }
    #@array.join!
   
    @height.times do
      File.open('maze.txt', 'a') { |file| file.write( @line + "\n" ) }
    end

    File.open("maze.txt", "r").each_line do |line|
      line.split
      @map << line
    end  
  end

  def points
    # make random start and end points
    puts "this is the solution"
    # puts @map
    # puts @map[1][1]
    @endy = rand(25) 
    @endx = rand(55)
    @map[@endy][@endx] = "#"
    @starty = rand(25)
    @startx = rand(55)
    @map[@starty][@startx] = '"'

    @end_point = @map[@endy][@endx]
    @start_point = @map[@starty][@startx]

      # puts @map
  end

  def solution
    # @map[starty][startx]

    endofgemsx = @endx + 1
    endofgemsy = @endy + 1
    endofgemsplusy = @endy - 1
    endofgemsplusx = @endx
    #start = '"'
    if @starty < @endy
      puts "gems   #{endofgemsplusy}"
      puts "start   #{@starty}"

      until @starty == endofgemsplusy do
        puts "going down"
        @starty += 1
        @map[@starty][@startx] = "x"
      end
    
    elsif @starty > @endy
      until @starty == endofgemsy do
        puts "going up"
        @starty -= 1
        @map[@starty][@startx] = "x"
      end
      
    end

    if @startx < @endx
      puts "gems   #{endofgemsplusy}"
      puts "start   #{@starty}"

      until @startx == endofgemsplusx do
        puts "going right"
        @startx += 1
        @map[@starty][@startx] = "x"
      end
    
    elsif @starty > @endy
      until @startx == endofgemsx do
        puts "going left"
        @startx -= 1
        @map[@starty][@startx] = "x"
      end
      
    end
      
    puts @map
  end 

  def mazeify
    #create a maze in the field of dots

  end
  def write
    puts @map
    puts "maps is putted"
    File.open("maze.txt", "w") do |f|
  f.puts(@map)
    end
  end

end


trink = World.new
trink.points
trink.solution
trink.write