# Square Kingdom

A multiplayer medieval RTS built with **Godot 3.6**, featuring tile-based combat, custom army composition, siege warfare, and large-scale squad battles.

---

## Screenshots

### Battle Overview
![Battle Screenshot 1](https://raw.githubusercontent.com/renosyah/square-kingdom-2/refs/heads/master/ss/3.png)

![Battle Screenshot 2](https://raw.githubusercontent.com/renosyah/square-kingdom-2/refs/heads/master/ss/1.png)

![Battle Screenshot 3](https://raw.githubusercontent.com/renosyah/square-kingdom-2/refs/heads/master/ss/2.png)

![Battle Screenshot 4](https://raw.githubusercontent.com/renosyah/square-kingdom-2/refs/heads/master/ss/4.png)

![Battle Screenshot 5](https://raw.githubusercontent.com/renosyah/square-kingdom-2/refs/heads/master/ss/gameplay.png)

![Battle Screenshot 6](https://raw.githubusercontent.com/renosyah/square-kingdom-2/refs/heads/master/ss/gameplay_1.png)

![Battle Screenshot 7](https://raw.githubusercontent.com/renosyah/square-kingdom-2/refs/heads/master/ss/gameplay_2.png)

![Battle Screenshot 8](https://raw.githubusercontent.com/renosyah/square-kingdom-2/refs/heads/master/ss/gameplay_3.png)

### Custom Army System

![Army Screenshot](https://raw.githubusercontent.com/renosyah/square-kingdom-2/refs/heads/master/ss/custom_army.png)

### End Match Results

![Results Screenshot](https://raw.githubusercontent.com/renosyah/square-kingdom-2/refs/heads/master/ss/end_match.png)

---

## Overview

**Square Kingdom** is a tile-based real-time strategy game where players command medieval armies in fast-paced multiplayer battles.

The game focuses on:

* Squad-based warfare
* Tile-based movement and combat
* Custom army composition
* Siege weapons and fort assaults
* Multiplayer battles
* Simple mechanics with strategic depth

---

## Core Gameplay

Each player commands an army composed of multiple squads.

Battles are fought on a tile-based battlefield where positioning, timing, and army composition determine victory.

Players must:

* Defeat enemy armies
* Protect their own forces
* Capture battlefield advantages
* Survive bandit raids
* Manage reinforcements

The last team standing wins.

---

## Multiplayer Battles

Current battle format:

* Up to 4 players
* 1 AI-controlled bandit faction
* Free-for-all combat
* Reinforcement-based army deployment

Each player begins inside a fortified wooden camp.

---

## Fortifications

Every player starts with:

* Wooden palisade fort
* Main gate
* Four defensive towers

Fortifications provide protection and serve as the army's reinforcement area.

Damaged squads can return to the fort to replenish losses.

---

## Squad-Based Combat

Units are organized into squads.

Features include:

* Shared squad health
* Casualty visualization
* Melee combat
* Ranged combat
* Morale-style collapse through squad destruction

Squads can consist of:

* Infantry
* Missile troops
* Cavalry
* Siege crews

---

## Custom Army System

Players build armies before battle.

Army composition is fully customizable.

Examples:

* Spearmen
* Archers
* Crossbowmen
* Heavy Infantry
* Cavalry
* Hybrid Units

Hybrid units can carry both:

* Melee weapons
* Ranged weapons

allowing combinations such as:

* Pike + Crossbow Cavalry
* Sword + Javelin Infantry
* Spear + Bow Infantry

---

## Equipment System

Unit statistics are determined by equipment.

Equipment affects:

* Health
* Movement speed
* Range
* Attack rate
* Combat effectiveness

Example:

* Plate Armor

  * +Health
  * -Movement Speed

This creates meaningful tradeoffs when designing armies.

---

## Cavalry

Cavalry units specialize in mobility and shock attacks.

Features include:

* Charge mechanics
* Momentum-based impact damage
* Mounted ranged combat
* Mobile melee combat

Heavy cavalry can deliver devastating charges if allowed to build momentum.

---

## Siege Warfare

Siege weapons are fully integrated into battles.

Current siege engines:

### Catapult

* Area damage
* Long range

### Ballista

* Direct fire
* High accuracy

### Trebuchet

* Extreme range
* Powerful siege bombardment

Siege weapons are capable of destroying tightly packed formations.

---

## Bandit Threat

Battles include an independent AI-controlled bandit faction.

Bandits:

* Attack all players
* Scale in strength over time
* Spawn increasingly dangerous units
* Create battlefield chaos

Ignoring the bandits can be just as dangerous as fighting enemy players.

---

## Technical Features

* Godot 3.6
* Tile-based navigation
* Multiplayer support
* Object pooling
* Low-poly semi-voxel visuals
* Mobile-friendly design

---

## Current Status

Active Development

Implemented:

* Tile-based combat
* Multiplayer battles
* Squad combat
* Cavalry
* Archers
* Crossbows
* Siege engines
* Fortifications
* Reinforcement system
* Bandit faction
* Custom army creation
* Equipment-based unit stats
* End-match statistics

In Development:

* Campaign mode
* Crusade campaign
* Strategic world map
* City conquest
* Army recruitment

---

## License

TBD

---

## Author

Reno Syahputra
