defmodule CheckersWeb.GameLive do
  use Phoenix.LiveView
  alias Checkers.Game
  alias Checkers.Validater

  def mount(_params, _session, socket) do
    {:ok, assign(socket, game: Game.new_game(), from: nil)}
  end

  def handle_event("select", %{"from" => from}, socket) do
    case parse_position(from) do
      {:error, _message} ->
        {:noreply, socket}  

      {row, col} -> 
        game = socket.assigns.game
        from_cord = socket.assigns.from
        cond do
          from_cord != nil and Validater.valid_move?(game, from_cord, {row, col}) ->
            new_game_board = Game.move_piece(game, from_cord, {row, col})
            {:noreply, assign(socket, game: new_game_board, from: nil)}

          Validater.valid_selection?(game.board, {row, col}, game.current_turn) ->
            {:noreply, assign(socket, from: {row, col})}

          true ->
            {:noreply, socket}
        end
    end
  end

  def handle_event("deselect", _params, socket) do
    # Clear the selected piece (deselect)
    {:noreply, assign(socket, from: nil)}
  end

  def render(assigns) do
    ~H"""
    <div class="game-container">
      <div class="turn-indicator left">
        <%= if @game.current_turn == :player1 do %>
          <span class="turn-text">Player 1's Turn</span>
        <% else %>
          <span class="turn-text">Player 2's Turn</span>
        <% end %>
      </div>

      <div class="board-container">
        <div class="board">
          <%= for {row, row_index} <- Enum.with_index(@game.board) do %>
            <div class="row">
              <%= for {cell, col_index} <- Enum.with_index(row) do %>
                <div
                  class={"cell " <> get_class(cell) <> if @from == {row_index, col_index}, do: " selected", else: ""}
                  phx-click={if @from == {row_index, col_index}, do: "deselect", else: "select"}
                  phx-value-from={"{#{row_index},#{col_index}}"} >
                  <%= if @from != nil && can_move?(@from, {row_index, col_index}) do %>
                    <div class="valid-move"></div>
                  <% end %>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>

      <div class="turn-indicator right">
        <%= if @game.current_turn == :player1 do %>
          <span class="turn-text">Player 1's Turn</span>
        <% else %>
          <span class="turn-text">Player 2's Turn</span>
        <% end %>
      </div>

      <!-- Game Over Screen -->
      <%= if @game.game_over do %>
        <div class="game-over-screen">
          <h2>Game Over!</h2>
          <p><%= if @game.current_turn == :player1, do: "Player 1 Wins!", else: "Player 2 Wins!" %></p>
          <button phx-click="reset_game">Restart Game</button>
        </div>
      <% end %>
    </div>
    """
  end


  defp parse_position(position) do
    case Regex.run(~r/^\{(\d+),(\d+)\}$/, position) do
      nil -> 
        {:error, "Invalid position format"}  
      [_, row_str, col_str] -> 
      {String.to_integer(row_str), String.to_integer(col_str)}
    end
  end

  defp get_class({:player1, false}), do: "player1"
  defp get_class({:player2, false}), do: "player2"
  defp get_class({:player1, _}), do: "king1"
  defp get_class({:player2, _}), do: "king2"
  defp get_class(:empty), do: "empty"

  defp can_move?({from_row, from_col}, {to_row, to_col}) do
    abs(from_row - to_row) == 1 && abs(from_col - to_col) == 1
  end
end
