class LineEnumerator(T)
  include Enumerable(T)

  def initialize(filename : Path | String)
    @filename = filename
  end

  def each
    File.each_line(@filename) {|str| yield(line(str)) }
  end

  protected def line(line_string : String) : T
    line_string
  end
end
