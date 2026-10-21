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

The game starts with one room and a circular character portrait token. Each room has a
random 1-4 entrances, marked by gold circles at its north, east, south, or
west sides. Left-click an unconnected entrance in the character's current room
to spawn a neighboring room. Wait for the character to finish moving before
opening another entrance.
The new room always has a facing entrance, and matching entrances on any other
adjacent rooms connect automatically. Rooms never spawn over occupied spaces.

Each room draws a 256 x 192 background and border. Its directional exit flags
now represent entrances; connected entrances stay visible but cannot spawn
another room.

Click the character token to select it; a gold outline appears. Then click a
connected room directly north, east, south, or west to glide there. Adjacent
rooms without a connecting entrance, diagonal rooms, and more distant rooms
cannot be reached in one move. Click the token again to deselect it.

Left-drag anywhere to move the view across the board as rooms appear. A short
click still selects the token, moves it, or spawns a room. Scroll up to zoom in
and down to zoom out; zoom stays centered on the point under the mouse.

## Room types and artwork

The Board node's `Room Definitions` array contains two sample types, Room A and
Room B, each with a 50% chance and a different placeholder color. To add a type,
create a `RoomDefinition` resource in Godot, give it a name and spawn chance,
then add it to the array. Import your image into the Godot project and assign
it to that resource's `Room Art` field. Artwork fills the room's 256 x 192 area;
use a 4:3 image to avoid stretching. Entrances, borders, and items draw above
the artwork.

Room type chances must total at most 100%. Any unused percentage gives a plain
room, and an empty definitions array produces only plain rooms. The starting
room follows the same selection rules as newly spawned rooms. Entrance count
and placement are rolled separately from room type, while the entrance facing
the clicked room is always included.

## Room items

Each room has up to four item spots, filled in this order: upper right, lower
right, upper left, lower left. A room can spawn at most one item when it first
appears. Items are green cards. Move the character into a room, then click an
item to collect it. The item disappears from the room and appears in the
bottom-left inventory. Collecting does not deselect the character token.

To add an item type, create a new `ItemDefinition` resource in Godot's FileSystem
dock, set its name, spawn chance, and optional item art, then add it to the Board
node's `Item Definitions` array in `game.tscn`. The included Brass Key has a 50%
chance. Chances across the array must total at most 100%; the unused percentage
is the chance that a room starts empty. Items remain in inventory for the
current play session; dropping and saving are not available yet.

The character portrait and Brass Key art are cropped at display time from the
unchanged mood board in `board-game/assets/references`. The circular mask only
softens the portrait's edge; the reference art itself is unchanged. The Health
bar in the bottom-left Character view is visual only for now.

## Project structure

```text
board-game/
├── rooms/               # Room type resources and spawn chances
├── scenes/
│   ├── game.tscn       # Main scene with Board, Room, and CharacterToken
│   └── Room.tscn       # Reusable room scene
├── scripts/
│   ├── board.gd        # Places rooms and moves the token
│   ├── room.gd         # Draws rooms and detects clicks
│   ├── room_definition.gd # Artwork and room type settings
│   └── character_token.gd # Draws and selects the token
├── project.godot
└── icon.svg
```

Rooms describe themselves and report clicks through the `side_clicked` and
`room_clicked` signals. The Board distinguishes clicks from drags, tracks
occupied spaces and connected entrances, and controls spawning, placement,
token movement, and the camera.

The exit flags are exported in the Room Inspector, but the Board rolls their
values when play begins and whenever it creates a room. Keep them unchecked in
the reusable `Room.tscn` scene.

## Current limitations

- The circles are temporary entrance visuals; artwork can be assigned later.
- The prototype has no multiple floors or fall/stair transitions yet.
