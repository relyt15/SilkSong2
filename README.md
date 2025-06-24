# SilkSong2

SilkSong2 is a short metroidvania style platformer created as a class project for Oakland University's CSI-2999 course as a collaboration with relyt15, TSN222, LucChapman, and Nick040404. This project takes its name and inspiration from Hollow Knight and other platformers of this style. This game has 3 levels, upgrade items, enemies, environmental hazards and a boss. 

To play the game, go to the Releases section of the GitHub, download the .exe file, and boot up the application.


![image](https://github.com/user-attachments/assets/e3256ff0-ba85-45ab-b2d1-d48021b47dcb)

## How It's Made:

**Tech used:** Godot Engine, GDScript

We focused first on getting a playable character with basic movement and jumping setup. We then got an enemy sprite and collectible coin item working. Once these things were done we built the first level's environment. Once we put the player character and other sprites into the level we had to adjust the scaling of the room to make more sense for a platformer. Raise the ceiling height, expand distances of platforms to be trickier, just more horizontal and vertical space for everything over all. At this point we had a fully functional level with a player, enemies, and collectible coins. 

We then went on to add functionality for doing/taking damage to/from enemies, adding the last two rooms, health bars for players and enemies, collectible items that give you upgrades once you collect enough of them, developing a boss, getting a UI setup to show the player how many of each item have been collected, a door system to change scenes to a new level, carrying over the player's status to each room, and then finally adding music and sound effects to the game. Once all of this had been done we spent some time fixing some little bugs we found. One of which was in the boss scene where its attack area wasn't performing as expected and therefore would cause the player not to be damaged by an attack by the boss.

## Lessons Learned:

Throughout the process of building this game we learned a lot about collaborating with others on code and best practices for branching, merging, and distributing tasks using git and GitHub. We also learned a lot about the different processes involved in making a game and Godot in general as this was our first significant dive into making a game.

Merging conflicts in GitHub as a group sometimes ended up being a larger undertaking than expected. When there were larger changes by multiple members being made at once there was sometimes overlap and really understanding our own code and how Godot functions was necessary for figuring out how to best merge everyone's changes.

Creating a linked door to scene system proved to be more challenging than expected for a first game. Learning more about the global scripts and autoloads in Godot proved useful for both the doors changing scenes and the ability to save information about the character and picked up items throughout the different scenes.
