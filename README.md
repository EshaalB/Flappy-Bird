# Flappy Bird in Assembly Language

Welcome to Flappy Bird in Assembly! 🎮 This project is a fun recreation of the classic Flappy Bird game, developed using x86 assembly language and designed to run on a 25x80 text-mode display.

## Features
- **Smooth gameplay**: Fly the bird through moving pillars.
- **Scrolling ground**: Realistic movement for an immersive experience.
- **Assembly magic**: Built entirely with x86 assembly in real mode.
- **Text-mode graphics**: Creative use of the 25x80 screen for retro visuals.

## Why This Project?
This project is a blend of nostalgia and technical challenge. It demonstrates how low-level programming and direct hardware interaction can create something fun and engaging.

## How It Works
- **Game Loop**: The game continuously updates the bird’s position, moves the pillars, and scrolls the ground.
- **Collision Detection**: Detects when the bird hits a pillar or the ground.
- **Score Keeping**: Tracks your progress as you navigate through the obstacles.
- **Text Display**: Uses text-mode video memory to draw the game.

## Getting Started
### Requirements
- An x86 emulator (e.g., DOSBox, QEMU) or a real x86 system.
- A basic understanding of assembly language (optional, but helpful).

### How to Play
1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/flappy-bird-asm.git
   ```
2. Assemble the code with an assembler like NASM:
   ```bash
   nasm -f bin flappy.asm -o flappy.com
   ```
3. Run the game in an emulator or on real hardware:
   ```bash
   dosbox flappy.com
   ```
4. Use the spacebar to flap the bird and avoid obstacles!

## Contributing
Feel free to contribute by improving the code, adding new features, or optimizing the gameplay. Fork the repo, make your changes, and submit a pull request.

## Acknowledgments
This project is inspired by the original Flappy Bird and fueled by a passion for retro computing and low-level programming. Thanks to the online assembly language community for their support!

---

Enjoy playing, and happy coding! 😊
