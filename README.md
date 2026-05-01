# Tetris on ATmega128

A Tetris game running on an ATmega128 microcontroller, displayed on an 8×8 RGB LED matrix.

**Authors:** Noam Levy & Axel Fouet — May 2025

---

## Hardware

| Component | Port |
|---|---|
| WS2812B LED panel (8×8) | Port B, pin PB1 |
| Rotary encoder + button | Port E |
| LCD screen | Port A + C |
| Push buttons | Port D |

---

## How to play

Flash the program at **4 MHz**.

1. **Enter your name** using buttons 1–4 at startup
2. **Press the encoder button** to start the game
3. **Rotate the encoder** left/right to move pieces
4. **Press button 0** to pause/resume
5. When the game ends, your score is saved and displayed for 3 seconds

---

## Project structure

| File | Description |
|---|---|
| `main.asm` | Entry point, main loop, interrupts |
| `tetris.asm` | Game logic (movement, collision, score) |
| `lcd_routine.asm` | LCD display routines |
| `angular_encoder.asm` | Encoder input handling |
| `memory_utils.asm` | Memory manipulation macros |
| `eeprom.asm` | Save/load name and score |
| `random.asm` | Pseudo-random piece selection |
| `led_64.asm` | WS2812B low-level driver |
