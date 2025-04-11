# Connect Four Game

A classic Connect Four game built using **MIPS assembly language** that features a graphical user interface with bitmap display for an immersive gaming experience.

## 🎮 Game Overview
This application recreates the classic Connect Four game where players take turns dropping colored discs into a vertically suspended grid. The objective is to be the first to form a horizontal, vertical, or diagonal line of four discs.

---

## 🚀 Features
- 🎨 **Graphical User Interface**: Uses the MARS simulator's bitmap display to create a visual game board.
- 🤖 **Computer Opponent**: Play against an AI opponent with strategic move capabilities.
- 🎮 **Simple Controls**: Easy-to-use keyboard controls for gameplay (A, S, D keys).
- 🔊 **Sound Effects**: Includes audio feedback for game actions and outcomes.
- 🏆 **Win Detection**: Automatically detects winning combinations in all directions.
- 🎯 **Column Selection**: Visual indication of which column is currently selected.

---

## 🛠️ Tech Stack
- **Language**: MIPS Assembly
- **Environment**: MARS (MIPS Assembler and Runtime Simulator)
- **Graphics**: Bitmap Display tool in MARS
- **Audio**: MIDI Sound tool in MARS

---

## 📁 File Structure
<pre lang="markdown">
├── main.asm                # Main game logic and display handling
├── checkWin.asm            # Win detection algorithms
├── computerMove.asm        # AI opponent logic
└── README.md               # Project documentation
</pre>

---

## 🚀 Getting Started

### Prerequisites
* MARS MIPS simulator (v4.5 or later recommended)

### Setup and Running

1. Download the MARS simulator from [Missouri State University](http://courses.missouristate.edu/kenvollmar/mars/)

2. Open MARS and load all .asm files
   `File -> Open -> Select all .asm files`

3. Assemble the program
   `Run -> Assemble`

4. Configure the bitmap display:
- Open Tools -> Bitmap Display
- Set unit width and height to 1
- Set display width and height to 512
- Set base address to static data
- Click "Connect to MIPS"

5. Open the console:
- Tools -> MARS Messages
- Click "Connect to MIPS"

6. Run the program:
   `Run -> Go`

7. Use the following controls to play:
- 'A': Move selection left
- 'D': Move selection right
- 'S': Drop a disc in the selected column

---

## 🎯 Gameplay Instructions

1. The game starts with an empty board and the first column selected.
2. Use 'A' and 'D' keys to select a column.
3. Press 'S' to drop your disc (red) into the selected column.
4. The computer (yellow discs) will automatically make its move.
5. Continue taking turns until someone connects four discs in a row or the board is full.
6. The game will display a win/lose message and end when a player wins.

---

## 🧠 Implementation Details

### Graphics Rendering
- The bitmap display is used to render the game board, discs, and UI elements.
- Custom circle drawing algorithms create the game pieces and board slots.
- Text rendering functions display game status and results.

### Game Logic
- The board is represented as a 7x6 grid (7 columns, 6 rows).
- Win detection checks for four consecutive same-colored discs horizontally, vertically, and diagonally.
- The computer AI makes strategic moves based on board analysis.

### Sound System
- Different sounds are played for disc dropping, invalid moves, winning, and losing.
- MIDI interface is used to generate sound through the MARS simulator.

---

## 👥 Contributors

This application was developed by a team of four:
- [Your Name](https://github.com/yourusername)
- [Team Member 2](https://github.com/teammember2)
- [Team Member 3](https://github.com/teammember3)
- [Team Member 4](https://github.com/teammember4)

---

## 🤝 Acknowledgements

* MARS MIPS Simulator team for providing the development environment
* Missouri State University for hosting the MARS simulator
* Original Connect Four game by Milton Bradley/Hasbro
