use Bitwise

defmodule BingoBoard do
  defstruct board: <<>>, marked: 0

  def mark(board, number) do
    case :binary.match(board.board, <<number>>) do
    :nomatch -> board
    {index,_} -> %{board | :marked => (board.marked ||| (1 <<< index))}
    end
  end

  @win_patterns [
    0b11111,
    0b11111 <<< 5,
    0b11111 <<< 10,
    0b11111 <<< 15,
    0b11111 <<< 20,
    0b100001000010000100001,
    0b100001000010000100001 <<< 1,
    0b100001000010000100001 <<< 2,
    0b100001000010000100001 <<< 3,
    0b100001000010000100001 <<< 4
  ]

  def bingo?(board) do
    !! Enum.find(@win_patterns, fn pat -> (pat &&& board.marked) == pat end)
  end

  def score(board, number) do
    unmarked_sum = 0..24 |> Enum.reduce(0, fn i, total ->
      if 0 == (board.marked &&& (1 <<< i)), do: total + :binary.at(board.board, i), else: total
    end)
    unmarked_sum * number
  end

  def parse(board_string) do
    %BingoBoard{ board: (String.trim(board_string) |> String.split(~r/\s+/) |> Enum.map(&String.to_integer/1) |> :binary.list_to_bin) }
  end
end

[calls|boards] = File.read!("input/day4") |> String.split("\n\n")
calls = calls |> String.split(",") |> Enum.map(&String.to_integer/1)
boards = boards |> Enum.map(&BingoBoard.parse/1)

calls |> Enum.reduce_while(boards, fn number, boards ->
  {marked_boards, score} = Enum.map_reduce(boards, nil, fn (board, score) ->
    if is_number(score) do
      {board,score}
    else
      marked = BingoBoard.mark(board, number)
      case BingoBoard.bingo?(marked) do
        true -> {marked,BingoBoard.score(marked, number)}
        _ -> {marked,nil}
      end
    end
  end)
  if is_number(score), do: {:halt, score}, else: {:cont, marked_boards}
end) |> then(fn score -> IO.puts "#{score} is the score of the first winning board" end)

calls |> Enum.reduce_while({boards, 0}, fn
  (_number, {[], last_score}) -> {:halt, last_score}
  (number, {boards, last_score}) -> {:cont, Enum.flat_map_reduce(boards, last_score, fn board, prev_score ->
    marked = BingoBoard.mark(board, number)
    if BingoBoard.bingo?(marked), do: {[], BingoBoard.score(marked, number)}, else: {[marked], prev_score}
  end)}
end) |> then(fn score -> IO.puts "#{score} is the score of the last winning board" end)