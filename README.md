# sokoban-riscv
This project is an implementation of the **Sokoban puzzle game**, written in **RISC-V assembly**. The game runs in an RV32 simulator and demonstrates low-level systems programming concepts.

Players navigate a grid based board to push a box onto a target while minimizing the number of moves. The implementation extends the classic game with **multiplayer support**, **move tracking**, a **ranked scoreboard**, and an **infinite replay system**.

---

## Features
- Configurable board size (minimum 3×3, up to 255×255)  
- Multiplayer mode with turn based gameplay  
- Ranked scoreboard 
- Infinite replay system that replays each player’s moves step by step  

---

## How to Run
1. Download the `sokoban.s` file.
2. Open the RISC-V simulator:  
   https://cpulator.01xz.net/?sys=rv32-spim
3. Click **File → Open** and load `sokoban.s`.
4. Click **Compile and Load**, then **Continue**.
5. Enter the number of players when prompted and follow the on-screen instructions.
6. More details in the **user guide**.

---

## Controls
- **Move Up:** `w`  
- **Move Down:** `s`  
- **Move Left:** `a`  
- **Move Right:** `d`  
- **Restart Game:** `r`  

Invalid moves (blocked by walls or boxes) are detected and reported.

---

## Game Rules
- Push the box (`X`) onto the target (`*`) using the player (`i`)
- Walls (`#`) cannot be crossed
- Complete the puzzle in the fewest number of moves
- In multiplayer mode, players are ranked by move count

---

## Replay System
After a round completes, players may replay any player’s moves.  
The game reconstructs each move by restoring saved board states directly from memory.

---
