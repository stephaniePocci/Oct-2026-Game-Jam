# Oct 2026 Game Jam

Game for Karni's October Game Jam 2026.

## Development

The game is built with Godot 4.7.

1. Open Godot and import `board-game/project.godot`.
2. Open `board-game/scenes/game.tscn`.
3. Press **F6** to run the current scene or **F5** to run the project.

The project currently contains an early board-game scaffold. `game.tscn` is the
main scene and contains a `Board` with one reusable `Room` instance. Rooms draw
a 256 x 192 background and border and expose north, east, south, and west exit
settings in the Godot inspector; the first room starts with its north exit
enabled.
