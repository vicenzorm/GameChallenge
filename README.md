# 🗡️ SwordWaves

A **2D survival arena game** built with **SpriteKit** using a **pure
Entity-Component-System (ECS) architecture**.

The player controls a sword-wielding hero trapped inside an arena where
**endless waves of enemies spawn**.\
Survive as long as possible, collect coins, charge your **special
attack**, and defeat increasingly difficult waves.

This project also serves as a **clean reference implementation of ECS
architecture in SpriteKit using Swift**, focusing on modular systems and
scalable game logic.

------------------------------------------------------------------------

# 🎮 Gameplay

SwordWaves is inspired by **survival arena games** where the player
fights waves of enemies while managing positioning, timing attacks, and
using special abilities strategically.

### Core Gameplay Loop

1.  Player spawns in the arena
2.  Enemy wave begins
3.  Player defeats enemies
4.  Enemies drop coins and special points
5.  Special attack becomes available
6.  Wave ends
7.  Short pause
8.  Next wave begins with higher difficulty

The game continues indefinitely until the player dies.

------------------------------------------------------------------------

# 🧠 Architecture

The game follows a **pure ECS (Entity-Component-System)** architecture.

This design separates **data**, **logic**, and **composition**, allowing
the game to scale without creating complex inheritance hierarchies.

------------------------------------------------------------------------

# 🧱 ECS Overview

## Entity

An **Entity** is simply a container of components.

Entities contain **no behavior or logic**.

Example entity composition:

    Entity
     ├── TransformComponent
     ├── MovementComponent
     ├── HealthComponent
     └── AttackComponent

Examples of entities in the game:

-   Player
-   Enemy
-   Coin

------------------------------------------------------------------------

## Component

Components store **data only**.

They represent attributes of entities.

  Component            Responsibility
  -------------------- -----------------------------
  TransformComponent   position and SpriteKit node
  MovementComponent    velocity and speed
  HealthComponent      health value and health bar
  AttackComponent      damage, range and cooldown
  EnemyComponent       enemy type data
  PlayerComponent      player state
  InputComponent       player inputs

Example component:

``` swift
class MovementComponent {
    var velocity: CGVector = .zero
    let speed: CGFloat
}
```

------------------------------------------------------------------------

## System

Systems contain **gameplay logic**.

A system iterates through entities that contain specific components.

Example:

### MovementSystem

Processes entities that contain:

    TransformComponent
    MovementComponent

It updates their position every frame.

------------------------------------------------------------------------

# 📁 Project Structure

    SwordWaves
    │
    ├── App
    │   ├── POC_2DGameApp.swift
    │   └── AppDelegate.swift
    │
    ├── Core
    │   └── Entity.swift
    │
    ├── Components
    │   ├── TransformComponent.swift
    │   ├── MovementComponent.swift
    │   ├── HealthComponent.swift
    │   ├── AttackComponent.swift
    │   ├── PlayerComponent.swift
    │   ├── EnemyComponent.swift
    │   └── InputComponent.swift
    │
    ├── Systems
    │   ├── MovementSystem.swift
    │   ├── MotionInputSystem.swift
    │   ├── InputSystem.swift
    │   ├── PlayerSystem.swift
    │   ├── AttackSystem.swift
    │   ├── EnemyAISystem.swift
    │   ├── HealthSystem.swift
    │   ├── CollisionSystem.swift
    │   ├── WaveSystem.swift
    │   └── CoinSpawnSystem.swift
    │
    ├── Entities
    │   └── EntityFactory.swift
    │
    ├── Scenes
    │   ├── GameScene.swift
    │   ├── MenuScene.swift
    │   └── ShopScene.swift
    │
    ├── UI
    │   └── Joystick.swift
    │
    └── Utilities
        └── CGPoint+Distance.swift

------------------------------------------------------------------------

# 🎮 Game Systems

## MovementSystem

Moves entities based on their velocity.

    position += velocity * deltaTime

Used by:

-   Player
-   Enemies

------------------------------------------------------------------------

## MotionInputSystem

Reads device motion using **CoreMotion**.

The player moves by **tilting the device**.

Features:

-   adjustable sensitivity
-   deadzone filtering
-   normalized directional vector

------------------------------------------------------------------------

## EnemyAISystem

Controls enemy movement behavior.

Enemies constantly chase the player.

Algorithm:

    direction = playerPosition - enemyPosition
    velocity = normalize(direction) * speed

------------------------------------------------------------------------

# 🌊 Wave System

Controls enemy spawning and wave progression.

Enemy difficulty increases every wave.

Example wave scaling:

  Wave   Weak   Normal   Strong
  ------ ------ -------- --------
  1      5      0        0
  5      10     4        0
  10     18     8        2
  15     25     15       5

Between waves there is a **5 second pause**.

------------------------------------------------------------------------

# 🪙 Coin System

Coins are the main currency in the game.

Players earn coins by:

-   collecting coin pickups
-   enemy drops

Coins are stored persistently using:

``` swift
UserDefaults.standard.integer(forKey: "totalCoins")
```

------------------------------------------------------------------------

# 👾 Enemy Types

  Type     Health   Speed   Damage   Special Points
  -------- -------- ------- -------- ----------------
  Weak     30       90      5        1
  Normal   80       65      12       2
  Strong   200      45      25       5

------------------------------------------------------------------------

# ✨ Special Attack

The special attack is charged by defeating enemies.

Each enemy grants points:

  Enemy    Points
  -------- --------
  Weak     1
  Normal   2
  Strong   5

The special becomes available when:

    points >= 5

Effects:

-   damage ×3
-   attack range ×2.5

------------------------------------------------------------------------

# 🎨 Graphics

Current graphics are placeholders.

  Entity   Representation
  -------- ----------------
  Player   square
  Enemy    circle
  Coin     yellow circle

Sprites and animations can easily replace them later.

------------------------------------------------------------------------

# 🚀 Running the Project

1.  Open the project in **Xcode**
2.  Select an **iOS device or simulator**
3.  Run the project

The game launches into the **MenuScene**.

------------------------------------------------------------------------

# 👨‍💻 Author

**Bernardo Garcia Fensterseifer**

------------------------------------------------------------------------

# 📜 License

This project is intended for **educational purposes and experimentation
with ECS architecture in SpriteKit**.
