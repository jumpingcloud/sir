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

  def solution
    # make random start and end points
    puts "this is the solution"
    # puts @map
    # puts @map[1][1]
    endy = rand(25) 
    endx = rand(55)
    @map[endy][endx] = "x"
    puts @map
  end


  def mazeify
    #create a maze in the field of dots

  end

end


trink = World.new
trink.solution
