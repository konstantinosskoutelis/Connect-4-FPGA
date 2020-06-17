# Connect 4

## Modern implementation of a classical retro game

Project created, as a lab assignment for VLSI course, by: <br>

- **Margomenos Nikos**
- **Skoutelis Konstantinos**

## Connected FPGAs

The game was designed in such a way so that it is possible to connect 2 boards each assigned to a single player, where the logic is that oinput will be received from only one, at a time. Note that:

1. Using the same instance of our hardware, loaded on our boards, we achieve to make them synchronize on their own
   1. Once we load our code one will be assigned as the main board - _player A / active player_, the other will be player B, and its input it will not be considered
   2. We are using 4 wires to establish the communication between the boards:
      1. **master** (_slave_)
      2. **slave** (_master_)
      3. **left** signal
      4. **right** signal
   3. the first two wires are depending on which board is assigned which role, since their functionality only depends on that and the name is _tis but a formality_

## Final Result

### The following gifs show 2 possible game scenarios frame-by-frame. Noteworthy _but little_ details:

1.  Winner Sprite - Changes colour to the winners' when a win is detected
2.  Winners' position marked - Changing the tokens that win each round

#### Scenario 1: Player A Wins vertically

![Vertical Win A Frames](/media/frame_V_win_a.gif)

#### Scenario 2: Player B Wins diagonally

![Diagonal Win B Frames](/media/frame_D_win_b.gif)
