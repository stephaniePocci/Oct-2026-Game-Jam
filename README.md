# Oct 2026 Game Jam

Game for Karni's October Game Jam 2026.

## Development

The game is built with Godot 4.7.

1. Open Godot and import `board-game/project.godot`.
2. Open `board-game/scenes/game.tscn`.
3. Press **F6** to run the current scene or **F5** to run the project.

The project currently contains an early board-game prototype. `game.tscn` is
the main scene, with a `Board`, one 256 x 192 starting room, and a crimson
character token. Rooms expose north, east, south, and west exit settings in the
Godot inspector; no exits are enabled in the starting scene.

Click a gold marker on a room's edge to spawn a room on that side. Click the
crimson token to select it (a gold outline appears), then click an existing
room directly north, east, south, or west to glide there. Diagonal and more
distant rooms cannot be reached in one move. Click the token again to deselect
it.
