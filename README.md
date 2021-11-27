# Minesweeper in MIPS

## Prerequisites
- [Download MARS](http://courses.missouristate.edu/kenvollmar/mars/) to run MIPS code

## Setup and Running
- Open MARS
- Tools > Bitmap Display 
  - Set Unit Width and Height to 4 pixels
  - Set Display Width and Height to 256
  - Set base address to `$gp`
  - "Connect to MIPS" in bottom left
- Tools > Keyboard and Display MMIO Simulator
  - "Connect to MIPS" in bottom left
- File > Open > Open the project file (.asm)
- Run > Assemble
- Run > Go
- Click in the Keyboard box within the Keyboard and Display simulator (bottom text box)
- Follow gameplay from the bitmap display

## Gameplay and Controls
- Press `enter` to start the game from the start screen
  - ![image](https://user-images.githubusercontent.com/93103123/143671801-05ee3680-3067-4c10-82e3-22fbd5677c4d.png)
- Wait until the blue indicator appears when the game starts
  - ![image](https://user-images.githubusercontent.com/93103123/143671589-cedeaf1d-90c4-491a-8e31-85369b05c288.png)
- The blue indicator can be moved with the `WASD` keys to select a cell
- Use the `space` key to reveal a cell
  - Revealing a cell with a bomb results in a loss
  - Revealing all 35 clear cells without revealing a bomb results in a win
  - The number in each cell indicates the number of bombs within a one-square radius (including diagonals)
- Use the `f` key to mark a cell (for your tracking)
  - ![image](https://user-images.githubusercontent.com/93103123/143671833-6d7027ad-c3fe-4e65-923b-8f0a2f80c322.png)
