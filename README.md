# OCSP
A program for controlling mob duplicators with the OpenComputers Minecraft mod.

## Requirements
I haven't measured the requirements fully, but the GUI library I chose is pretty beefy so I picked tier 3 components to be safe.
* Tier 3 Computer
  * Tier 3 Case
  * LUA Bios
  * Tier 2+ Processor
  * Tier 3+ Memory x2
  * Tier 2+ Graphics Card
  * Internet Card (for installing the GUI library)
  * Tier 1+ Hard Drive
* Tier 2+ Screen(s)
  * Attach a keyboard to the screen(s) if you don't want to control the spawner with a large touchscreen.
* Transposer
* Redstone I/O
* Chest (or any other compatible inventory)
* Mob Duplicator
* Mob Crusher (or any other redstone triggered mob killer)
* (OPTIONAL) Phantomface
  * Phantomfaces let you interact with remote blocks without having to have direct contact. Using these lets you focus more on the aesthetics of your mob spawner when working with this program.

## Construction
1. Place down your computer case and install the computer components. Don't forget to power it.
1. Install OpenOS
1. Place down your mob duplicator and crusher. Connect them to power and essence, and make sure that the crusher is set to activate only on an active redstone signal.
1. Place down the transposer so that it is adjacent to BOTH the duplicator and the chest.
   1. For example, you could place the chest down, then the transposer on top of it, and then the duplicator on top of that.
1. Place down the redstone i/o so that it is adjacent to the mob crusher.
1. Note the sides that the transposer and redstone i/o are touching their related blocks.
1. Connect the transposer and the redstone i/o to the computer/screen with OpenComputers cables.

## Installation
1. Install [this graphics library by IgorTimeofeev](https://github.com/IgorTimofeev/GUI) to your computer.
1. Download or copy this script to your computer.
   1. You can copy the script to your computer easily by first opening ocsp.lua in Github's raw view and copying all of the text, then typing `edit ocsp.lua` on the computer to bring up the edit program, and finally using the insert key, or middle mouse button to paste into the editor.
1. Edit the script with `edit ocsp.lua`, and scroll down to the constants section. Set the values for `chest`, `spawner`, and `crusherRedstone` to the side of the transposer you have your MIP chest (or other inventory), your Mob Duplicator, and a line of redstone to your Mob Crusher.
   1. There is some commented out code in the program to add another button for toggling the spawner's redstone signal on and off. I found it wasn't that useful for my purposes, but re-enabling it is simple.
1. After making your changes, save the file with `ctrl+s` and exit the edit program with `ctrl+w`. After making sure all of the components are attached, you can run the program.
   1. Whenever the program is started it will check if the spawner has an MIP inside of it, and if it does it will pull it into the MIP chest. It will then condense the items in that chest, and scan for MIPs that contain a mob. Empty MIPs and other invalid items will be ignored.
1. If you want the program to run on startup, move it to `/autorun.lua`

## Screenshots

![GUI](https://raw.githubusercontent.com/kchanakira/OCSP/master/preview_gui.png)
![Front](https://raw.githubusercontent.com/kchanakira/OCSP/master/preview_front.png)
![Side](https://raw.githubusercontent.com/kchanakira/OCSP/master/preview_side.png)
