 defmodule Checkers.Validater do
  def valid_move?(%Checkers.Game{board: board, current_turn: turn}, {from_row, from_col} = from_cords, {to_row, to_col} = to_cords) do
    {player, false} = piece = Enum.at(board, from_row) |> Enum.at(from_col)
    target_cell = Enum.at(board, to_row) |> Enum.at(to_col)
    row_diff = from_row - to_row

    cond do
      turn != player -> false
      target_cell != :empty -> false  # Target cell must be empty
      abs(row_diff) != abs(from_col - to_col) -> false  # Must be diagonal
      valid_basic_move_for_player(row_diff, piece) -> true  
      valid_jump_move_for_player(row_diff, piece, from_cords, to_cords, board) -> true
      true -> false  
    end
  end

    # Selection validation
  def valid_selection?(board, {row, col}, :player1) do
    piece = Enum.at(board, row) |> Enum.at(col)
    case piece do
      {:player1, _} -> true
      _ -> false
    end
  end

  def valid_selection?(board, {row, col}, :player2) do
    piece = Enum.at(board, row) |> Enum.at(col)
    case piece do
      {:player2, _} -> true
      _ -> false
    end
  end

  def valid_selection?(_board, _from_cord, _turn), do: false

  # Basic move validation
  defp valid_basic_move_for_player(1, {:player1, false}), do: true
  defp valid_basic_move_for_player(-1, {:player2, false}), do: true
  defp valid_basic_move_for_player(row_diff, {_player, true}) when abs(row_diff)== 1, do: true
  defp valid_basic_move_for_player(_row_diff, _piece), do: false

  # king case
defp valid_jump_move_for_player(distance, {player, true}, from_cords, to_cords, board) when abs(distance) == 2 do
  validate_jumped_piece(player, from_cords, to_cords, board)
end
# player1 case
  defp valid_jump_move_for_player(2, {:player1, _false}, from_cords, to_cords, board) do
    validate_jumped_piece(:player1, from_cords, to_cords, board)
  end

# player2 case
  defp valid_jump_move_for_player(-2, {:player2, _false}, from_cords, to_cords, board) do
    validate_jumped_piece(:player2, from_cords, to_cords, board)
  end

  defp valid_jump_move_for_player(_row_diff, _piece, _from_cords, _to_cords, _board), do: false

defp validate_jumped_piece(player, {from_row, from_col}, {to_row, to_col}, board) do
    middle_row = div(from_row + to_row, 2)
    middle_col = div(from_col + to_col, 2)
    {middle_piece, _} = Enum.at(board, middle_row) |> Enum.at(middle_col)

    middle_piece != :empty and middle_piece != player
  end

end