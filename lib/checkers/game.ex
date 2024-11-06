defmodule Checkers.Game do
    defstruct board: [], current_turn: :player1, game_over: false

  # Initialize a new game with the starting positions
    def new_game do
        board = [
        [:empty, {:player2, false}, :empty, {:player2, false}, :empty, {:player2, false}, :empty, {:player2, false}],
        [{:player2, false}, :empty, {:player2, false}, :empty, {:player2, false}, :empty, {:player2, false}, :empty],
        [:empty, {:player2, false}, :empty, {:player2, false}, :empty, {:player2, false}, :empty, {:player2, false}],
        [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
        [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
        [{:player1, false}, :empty, {:player1, false}, :empty, {:player1, false}, :empty, {:player1, false}, :empty],
        [:empty, {:player1, false}, :empty, {:player1, false}, :empty, {:player1, false}, :empty, {:player1, false}],
        [{:player1, false}, :empty, {:player1, false}, :empty, {:player1, false}, :empty, {:player1, false}, :empty]
        ]

        %Checkers.Game{board: board, current_turn: :player1, game_over: false}
    end

    def move_piece(game, {from_x, from_y}, {to_x, to_y} = to) do
        piece = Enum.at(game.board, from_x) |> Enum.at(from_y)

        new_board = 
        if abs(from_x - to_x) == 2 do
            middle_x = div(from_x + to_x, 2)
            middle_y = div(from_y + to_y, 2)
            updated_board = remove_piece(game.board, {middle_x, middle_y})
            updated_board
        else
            game.board
        end
        |> List.update_at(from_x, fn row ->
            List.update_at(row, from_y, fn _ -> :empty end)
        end)
        |> List.update_at(to_x, fn row ->
            List.update_at(row, to_y, fn _ -> piece end)
        end)
        |> king_piece?(to, game.current_turn)

    
        if check_game_over(new_board, next_turn(game.current_turn)) do
            %Checkers.Game{game | board: new_board, game_over: true}
        else
            %Checkers.Game{game | board: new_board, current_turn: next_turn(game.current_turn)}
        end
    end

    defp next_turn(:player1), do: :player2
    defp next_turn(:player2), do: :player1

    defp check_game_over(board, player) do
        not(board
        |>List.flatten()
        |> Enum.any?(fn piece -> piece == {player, true} or piece == {player, false}  end))
    end


  # King the piece when it reaches the opposite back row
    defp king_piece?(board, {row, col}, player) do
        if (player == :player1 and row == 0) or (player == :player2 and row == 7) do
            List.update_at(board, row, fn row ->
                List.update_at(row, col, fn _ -> if player == :player1, do: {:player1, true}, else: {:player2, true} end)
            end)
        else
            board
        end
    end

    defp remove_piece(board, {row, col}) do
        List.update_at(board, row, fn row ->
        List.update_at(row, col, fn _ -> :empty end)
        end)
    end
end

