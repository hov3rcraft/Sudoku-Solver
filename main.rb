require 'rubygems'
require 'gosu'
require_relative 'sudoku'
include Gosu

class Solver_Window < Window
  def initialize
    super(570, 700, false)
	self.caption = "Sudoku Solver"
	#s_array		 = [nil, nil, nil, nil, nil, nil, 2  , 6  , 8  ,
    #         			5  , nil, 6  , nil, nil, nil, nil, nil, nil,
	# For  			    nil, nil, nil, 3  , 6  , 4  , nil, nil, nil,
	# Development	    nil, 5  , nil, 4  , nil, 7  , nil, 2  , nil,
	#   			    2  , 1  , nil, 6  , nil, nil, nil, nil, 4  ,
	#   			    nil, 4  , nil, nil, nil, 5  , nil, nil, 3  ,
	#   			    nil, nil, nil, nil, nil, nil, 8  , 7  , 6  ,
	#   			    nil, nil, nil, 7  , 1  , nil, nil, nil, nil,
	#   			    4  , nil, 9  , nil, nil, nil, nil, nil, nil]
	@sudoku      = Sudoku.new
    @background  = Image.new(self, "background.png", false)
    @menu_bar1   = Image.new(self, "menu_bar1.png", false)
    @menu_bar2   = Image.new(self, "menu_bar2.png", false)
    @sx          = 14
    @sy	         = 80
    @fw = @fh	 = 60
    @menu_y 	 = height - 68
    @font        = Font.new(self, "Arial", 50)
    @font75 	 = Font.new(self, "Arial", 75)
    @active      = [nil, nil]
    @ns          = 0
  end

  def needs_cursor?
  	true
  end

  def button_down(id)
  	x = mouse_x; y = mouse_y
  	if id == MsLeft
  	  if (635..690).cover?(y)
  	    case x
	      when 20..70   then close
	      when 210..360
	      	unless @sudoku.calculating?
	      	  @sudoku.solve
	      	  @active = [nil, nil]
	      	end
	      when 500..550
	      	if @sudoku.calculating?
	      	  @sudoku.kill_calculation
	        else
	          @sudoku.clear
	          @active = [nil, nil]
	        end
	    end
	  elsif (@sx..@sx+9*@fw).cover?(x) and (@sy..@sy+9*@fw).cover?(y)
	   	@active = [(x.to_i-@sx)/60, (y.to_i-@sy)/60]
	  else
	  	@active = [nil, nil]
	  end
	elsif @active != [nil, nil] and not @sudoku.calculating?
		case id.to_i
			when 200    then @active[1] = (@active[1] - 1) % 9             #KbUp
			when 203    then @active[0] = (@active[0] - 1) % 9             #KbLeft
			when 205    then @active[0] = (@active[0] + 1) % 9             #KbRight
			when 208    then @active[1] = (@active[1] + 1) % 9             #KbDown
			when 2..10  then @sudoku.change(@active, id.to_i-1)            #Kb1 - Kb9
			when 79..81 then @sudoku.change(@active, id.to_i-78)           #KbNum1 - KbNum3
			when 75..77 then @sudoku.change(@active, id.to_i-71)           #KbNum4 - KbNum6
			when 71..73 then @sudoku.change(@active, id.to_i-64)           #KbNum7 - KbNum9
		    when 11, 14, 57, 82, 83, 211 then @sudoku.change(@active, nil) #0, Backspace, Space, Num0, NumDelete, Delete
		end
	end
  end
  
  def draw
    @background.draw(0, 0, 0)
	@sudoku.to_a.each_with_index{|e, i| @font.draw(e.to_s, @sx + 21 + i%9*@fw, @sy + 8 + i/9*@fw, 2, 1.0, 1.0,  0xff000000)}
	if  @sudoku.calculating?
	  @menu_bar2.draw(0, @menu_y, 1)
	else
	  @ns = 120 unless @sudoku.solved?
	  @menu_bar1.draw(0, @menu_y, 1)
      if @active != [nil, nil]
	    x1 = @active[0]*@fw + @sx + @active[0]/3 + 2; x2 = x1 + @fw
	    y1 = @active[1]*@fh + @sy + @active[1]/3 + 2; y2 = y1 + @fh
	    c  = 0xffff0000
	    draw_quad(x1-4, y1-3, c, x1-4, y2, c, x1, y2, c, x1, y1-3, c, 3)
	    draw_quad(x1-3, y1-4, c, x2, y1-4, c, x2, y1, c, x1-3, y1, c, 3)
	    draw_quad(x2-4, y1, c, x2-4, y2, c, x2, y2, c, x2, y1, c, 3)
	    draw_quad(x1, y2-4, c, x2, y2-4, c, x2, y2, c, x1, y2, c, 3)
	  end
	end
	if @ns > 0
	  tw = @font75.text_width("No Solution :(")
	  @font75.draw("No Solution :(", (width-tw)/2, (height-75)/2, 4, 1.0, 1.0, 0xffff0000)
	  @ns -= 1
	end
  end
end

Solver_Window.new.show