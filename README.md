# Nomads CCG

A simple Collectible Card Game (CCG) framework built with Flutter. This project serves as a foundation for creating a CCG with customizable cards and animations.

## Features

*   **Customizable Cards:** The `CardData` model allows for easy creation of new cards with different stats, types, and effects.
*   **Game Board:** A two-player game board with areas for each player's hand, deck, and board.
*   **Animations:** The game includes animations for:
    *   Drawing cards
    *   Playing cards
    *   Flipping cards
    *   Attacking minions
    *   Shaking the attacked minion

## Getting Started

To run the project, you'll need to have Flutter installed.

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/nomads.git
    cd nomads
    ```
2.  **Get dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Run the app:**
    ```bash
    flutter run
    ```

## Project Structure

*   `lib/main.dart`: The entry point of the application.
*   `lib/models`: Contains the data models for the game (`CardData`, `PlayerData`, `GameState`).
*   `lib/screens`: Contains the main game screen.
*   `lib/widgets`: Contains the UI widgets for the game (`CardWidget`, `PlayerBoard`, etc.).

## Future Improvements

*   **More robust effect system:** Implement a more flexible effect system for cards.
*   **More card types:** Add new card types like weapons and secrets.
*   **Player abilities:** Add hero powers for each player.
*   **Improved UI and animations:** Enhance the UI and add more polished animations.
*   **Sound effects:** Add sound effects for game actions.
*   **Multiplayer:** Implement online multiplayer functionality.