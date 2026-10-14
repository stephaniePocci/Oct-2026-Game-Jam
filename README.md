# Oct 2026 Game Jam

Game for Karni's October Game Jam 2026.

A 2D thriller-themed board game in development, with room-by-room exploration
inspired by *Betrayal at House on the Hill*. The current prototype focuses on
room exploration and token movement; multiple floors are planned.

## Development

Use Godot **4.7.2**, the regular (non-.NET) build. The project uses GDScript
and the Compatibility renderer.

1. Open Godot and import `board-game/project.godot`.
2. Open `board-game/scenes/game.tscn`.
3. Press **F6** to run the current scene or **F5** to run the project.

## Try the prototype

The game starts with one room and a crimson character token. Left-click a gold
circle on the room's north, east, south, or west side to spawn a neighboring
room in that direction. New rooms have the same clickable circles, so you can
continue expanding the board.

Each room draws a 256 x 192 background and border. Clicking a side sets that
room's corresponding exit flag to `true`; further clicks on that same side are
ignored. Rooms start with all four exit flags set to `false`.

Click the crimson token to select it; a gold outline appears. Then click an
existing room directly north, east, south, or west to glide there. Diagonal and
more distant rooms cannot be reached in one move. Click the token again to
deselect it.

## Project structure

```text
board-game/
├── scenes/
│   ├── game.tscn       # Main scene with Board, Room, and CharacterToken
│   └── Room.tscn       # Reusable room scene
├── scripts/
│   ├── board.gd        # Places rooms and moves the token
│   ├── room.gd         # Draws rooms and detects clicks
│   └── character_token.gd # Draws and selects the token
├── project.godot
└── icon.svg
```

Rooms describe themselves and report clicks through the `side_clicked` and
`room_clicked` signals. The Board controls spawning, placement, and token
movement in response to clicks, rather than every frame.

The exit flags are exported in the Room Inspector. Keep them unchecked in the
reusable `Room.tscn` scene so newly spawned rooms can explore every direction.
A checked flag means that side is already explored in this prototype.

## Current limitations

- Occupied positions are not tracked yet. Exploring back toward an existing
  room or around a loop can spawn overlapping rooms.
- The circles are temporary visuals and remain visible after a side is explored.
- The prototype has no multiple floors or fall/stair transitions yet.
