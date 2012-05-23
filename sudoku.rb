class Sudoku
  def initialize(array = Array.new(81))
    @value   = array
    @solving = Thread.new{}
    @solved  = true
  end

  def change(field, n)
    @value[field[0] + field[1]*9] = n
  end

  def ok?(index, n)
    not vert_row(index).include?(n) and not hor_row(index).include?(n) and not quad(index).include?(n)
  end

  def hor_row(index)
    @value[index/9*9..index/9*9+8]
  end

  def vert_row(index)
    row = Array.new
    9.times{|i| row << @value[i*9 + index%9]}
    row
  end

  def quad(index)
    quad = []
    qx = index%9/3*3; qy = index/9/3*3 #x = index%9; y = index/9
    qy.upto(qy+2){|i| quad = quad + @value[i*9+qx..i*9+qx+2]}
    quad
  end
 
  def solve
    @solved = false
    @old = @value.dup
    @solving = Thread.new{ solve_process }
  end

  def calculating?
    @solving.alive?
  end

  def solved?
    @solved ? true : (@solved = true; false)
  end

  def kill_calculation
    @solving.kill
    @value = @old
    @solved = true
  end
  
  def clear
    @value = Array.new(81, nil)
  end

  def to_a
    @value
  end

  private
  def solve_process(akt_pos = 0)
    if akt_pos >= 81
      @solved = true
      return true
    elsif @value[akt_pos]
      v = @value[akt_pos]; @value[akt_pos] = nil
      valid = ok?(akt_pos, v)
      @value[akt_pos] = v
      valid ? solve_process(akt_pos + 1) : false
    else
      1.upto(9) do |i|
        if ok?(akt_pos, i)
          @value[akt_pos] = i
          return true if solve_process(akt_pos + 1)
        end
      end
      @value[akt_pos] = nil
      return false
    end
  end
end