# 🏰 Zenith, the Endless Tower

**Ascend, fight, and survive to the top!**

Zenith is a top-down indie action game focused on survival and combat. Natively developed for the Apple ecosystem using **SpriteKit** and **GameplayKit**, the project adopts the **ECS (Entity-Component-System)** architecture to ensure a modular, scalable, and high-performance codebase.

Heavily inspired by the room structure and progression of the classic *The Binding of Isaac*, Zenith brings a twist by focusing intensely on close-range combat with physical attacks and dynamic collision mechanics. All assets used in the project are *open source*.

## 🎮 Gameplay & Mechanics

* **Objective:** Survive the enemy hordes, clear the floor, and find the exit to ascend the tower. Try to reach the highest floor you can!
* **Dynamic Combat:** Master the space around you using brutal physical melee attacks, managing cooldowns and positioning to avoid taking damage.
* **Infinite Progression:** The difficulty gradually increases with each new floor of the tower. Stronger, faster, and more numerous enemies will try to stop your ascent.
* **ECS Architecture:** Everything in the game — from players to enemies and projectiles — is an Entity. Abilities, health, and movement are modular Components, processed by GameplayKit Systems.

## ⚒️ Developer Guide

This repository follows collaborative development best practices. Before contributing, please pay attention to the guidelines below.

### 0. Language

The language for commit messages or branch names MUST **ALWAYS** be in **English**.

### 1. Branch Organization

* `main`: Stable branch, always ready for deployment.
* `dev`: Integration branch, where features are tested before going to `main`.
* `feat-TK<task-number>/<feature-name>`: New features and new ECS components.
* `fix/<bug-name>`: Bug fixes.
* `hotfix/<hotfix-name>`: Urgent fixes that must go straight to production.
* `test/<test-name>`: Experiments or proofs of concept.

⚠️ **Never** commit directly to `main` or `dev`.

### 2. Commit Messages

Commit messages must be clear, concise, and in the **present imperative** (as if they were commands).

**Recommended format:** `<type>: <short description>`

**Most common types:**
* `feat`: New feature (e.g., new enemies, GameplayKit systems).
* `fix`: Bug fix.
* `docs`: Changes to documentation.
* `style`: Formatting (no code changes).
* `refactor`: Code refactoring (without changing behavior, e.g., optimizing a Component).
* `test`: Adding or modifying tests.
* `chore`: Maintenance, dependencies, asset configs, etc.

✅ **Examples:**
* `feat: add melee attack component to player entity`
* `fix: collision detection on enemy spawn`
* `docs: update README with ECS architecture`

❌ **Avoid vague commits like:**
* `combat adjustments`
* `update enemies`
* `tower tests`

### 3. Tests

Tests are a fundamental part of ensuring the quality and stability of the game's architecture. Before opening a PR, **run all local tests** and make sure they pass.

Use Apple's default **Testing** framework to write test cases.

**Tests must cover:**
* Damage calculation logic, health (`HealthComponent`), and entity death.
* Critical ECS integrations (ensure Systems process Components correctly every *update frame*).
* Floor generation and enemy spawn logic.

📌 *Pull requests without minimum logical test coverage will be rejected.*

### 4. Pull Requests (PRs)

PRs should be small, objective, and have a clear description of what is being changed.

**Before opening a PR:**
* Make sure your branch is up to date with `dev`.
* Review your code locally (check for memory leaks with SpriteKit textures!).
* Run the tests and ensure they all pass.
* Describe what was done and the reason for the change.

**PR Checklist:**

- [ ] Code tested locally
- [ ] Tests created/updated
- [ ] Open source assets properly credited (if applicable)
- [ ] Documentation adjusted (if necessary)
- [ ] No conflicts with `dev`
