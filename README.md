# Square Kingdom

A mobile-first multiplayer medieval RTS built with **Godot 3.6** using **semi-voxel low-poly visuals**, tile-based navigation, modular squad combat, and siege warfare focused on readability and simplicity.

---

## Overview

**Square Kingdom** is a real-time strategy game designed specifically for mobile devices.

The game emphasizes:

* Fast and readable squad-based combat
* Tile-based tactical movement
* Wall sieges and vertical battlefield interaction
* Custom unit composition
* Multiplayer-focused deterministic gameplay
* Simple systems that scale into strategic depth

The design philosophy is:

> **"It just works."**

No unnecessary complexity.
Everything is built for clarity, responsiveness, and performance.

---

## Core Features

## Tile-Based Strategy

The battlefield is built on a square tile grid.

This allows:

* Deterministic movement
* Reliable pathfinding
* Predictable combat range
* Efficient multiplayer synchronization

Navigation uses multiple A* layers:

* Ground navigation
* Water navigation
* Wall navigation

Units dynamically transition between navigation layers when conditions allow.

---

## Squad-Based Combat

Units are controlled as squads rather than individual soldiers.

Each squad has:

* A single shared HP pool
* Visual member loss as health decreases
* Flee / collapse behavior on defeat

Combat behavior:

### Ground Combat

When a squad is defeated:

* Some random members die
* Remaining members flee

### Wall Combat

When a squad is defeated on walls:

* Some members die
* Remaining members panic and fall from the wall

This system prioritizes:

* Performance
* Visual clarity
* Simple combat resolution

---

## Modular Unit Creation

Players create custom squads by combining weapon types.

Each unit can carry:

### Primary Weapon (Ranged)

* Bow
* Javelin
* Throwing Axe

### Secondary Weapon (Melee)

* Spear
* Sword
* Mace
* Axe

Melee categories:

* One-Handed
* One-Handed + Shield
* Two-Handed

---

### Example Unit Combinations

**Spearman**

* Barracks

**Hybrid Spear Archer**

* Barracks + Archery Range

**Heavy Maceman**

* Barracks + Blacksmith

This creates a flexible composition-based unit system.

---

## Cavalry System

Three cavalry archetypes exist.

### Shock Cavalry

Weapon: Spear

Mechanic:

* Builds momentum by moving in the same direction for 3 consecutive tiles
* Gains speed
* Lowers spear
* Delivers impact damage on contact

---

### Melee Cavalry

Weapon: Sword

* Mobile melee attacks
* Can strike while moving

---

### Mounted Archer

* Mobile ranged harassment
* High mobility
* Continuous ranged pressure

---

## Siege Warfare

Sieges are a major gameplay pillar.

Features include:

* Wall traversal
* Wall-top combat
* Gate assault
* Siege towers
* Battering rams
* Vertical engagement

Special wall interactions:

* Infantry can climb walls
* Siege towers enable instant wall access
* Defeated wall defenders may fall from battlements

---

## Resource Economy

Resources:

### Food

Used for training units

### Wood

Used for construction

### Iron

Used for advanced / expensive military units

### Stone

Used for walls and fortifications

---

## Buildings

### Core

* Town Center / Keep

---

### Economy

* Farm
* Wood Camp
* Mine
* Quarry

---

### Population

* House

---

### Military

* Barracks
* Archery Range
* Stable
* Workshop

---

### Technology

* Market (Economy Tech)
* Blacksmith (Military Tech)

---

### Defense

* Wall
* Gatehouse

---

## Technology Tree

Three branches:

### Economy

Improves resource production

### Military

Improves unit effectiveness

### Administration

Unlocks more structures and increases strategic flexibility

---

## Multiplayer

Designed for multiplayer-first gameplay.

Planned match formats:

* 1v1
* 2v2
* 4v4

The deterministic tile-based system helps maintain synchronization across clients.

---

## Visual Style

The project uses:

* Semi-voxel low-poly art
* Hard edges
* Readable silhouettes
* Simple geometry
* Mobile-friendly rendering

All assets are designed to be:

* Easy to model
* Lightweight
* Consistent

---

## Technical Stack

**Engine**
Godot 3.6

**Modeling**
Blender

**Target Platform**
Mobile (Landscape)

---

## Development Roadmap

### Stage 1

Map editor + navigation

* Tile placement
* Terrain editing
* Navigation layers
* Pathfinding transitions

---

### Stage 2

Core squad movement

* Selection
* Movement commands
* Unit states

---

### Stage 3

Combat system

* Squad HP
* Casualty visuals
* Flee logic

---

### Stage 4

Siege mechanics

* Wall traversal
* Gate assault
* Siege equipment

---

### Stage 5

Custom unit builder

* Weapon combinations
* Building requirements

---

### Stage 6

Multiplayer integration

---

## Project Philosophy

Square Kingdom is built around a simple principle:

**Readable systems > simulated realism**

The goal is not perfect realism.

The goal is strategic gameplay that feels immediate, intuitive, and satisfying.

---

## Status

Currently in early development.

Primary focus:

**Map editor and tile navigation system**

---

## License

TBD

---

## Author

Reno Syahputra
