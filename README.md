<h1 align="center">CubeTime</h1>

<p align="center">
  <img src="https://user-images.githubusercontent.com/65262710/146141635-06fff458-003e-45af-b7ee-6860d7b4ea72.png"
       width="300"
       height="300">
<p align="center">
<h4 align="center">SPEEDCUBING TIMER & UTILITIES</h4>
<p align="center">
  <a href="https://apps.apple.com/us/app/cubetime/id1600392245">
    <img src="https://user-images.githubusercontent.com/24711088/146530953-94bc8542-8a1a-49a5-9faf-75c63281f2fc.png"
         height="48">
  </a>
  <a href="https://ko-fi.com/cubetime">
      <img src="https://user-images.githubusercontent.com/65262710/151313673-05574ab7-371c-4735-ab95-319b6dd40d82.png"
           height="48">
  </a>
</p>

---

# Contents
1. [Overview](#overview)
2. [Screenshots](#screenshots)
3. [Features](#features)
4. [User Guide](#user-guide)
5. [Some final stuff](#some-final-stuff)

## Overview

### Information!

 - Free (both as in libre and gratis), copylefted software (GPLv3)
 - Fully built with SwiftUI, lightweight and modern app architecture
 - Simple and modern user interface
   * Beautiful dark mode that saves battery on OLED phones
   * Clean tab bar for effortless navigation

## Screenshots
### Dark Mode
![dark mode screenshot](https://user-images.githubusercontent.com/65262710/146157994-ee501ac8-1c26-424b-9826-34cb8f1727f9.png)

### Light Mode
![light mode screenshot](https://user-images.githubusercontent.com/65262710/146157963-54d03464-625d-4dfe-a411-d36af00e3484.png)


## Features
### App Features
- Built-in system haptics, and able to be changed to your liking

- All the basic timing functionalities, and fully customisable:
   * Customisable hold down time
   * Inspection time
   * Customisable timer update intervals and statistics display precision
   * Intuitive gestures for quick and easy access to actions
     * Customisable gestures
     * Customisable gesture activation distance

- Easy to use session support
  * featuring many modes, including:
    * Standard sessions
    * Alg Trainers
    * Multiphase - for blind and other events
    * Playground sessions that support all scramble types for quick access to scrambling
    * Comp Sim
  * pinnable sessions for easy access

- Simple card design for viewing your times
  * Searchable times, along with quick and easy to use sort functionality - to sort your times by date or by speed
  * Batch select times for deletion, adding penalties, or to export or move to a different session
  * Adding comments for special solves

- Extensive statistics and solve analysis:
  * Visual graphs for your sessions
    * Such as time trend, time distribution and other graphs
  * All standard calculations, including best and current averages of 5, 12 and 100, session mean, median
  * History of PBs in each session
  * Inspection time tracking and analysis
  * Total time spent solving

- Other tools, including special ones for Comp Sim, such as:
  * calculating your bpa and wpa
  * calculating time needed to secure certain averages

     
### Upcoming Features

You can view our [Todo List for this repo](https://github.com/orgs/CubeStuffs/projects/3) for a list of all our upcoming features. You can add suggestions in the 'Needs Triage' column. 
Here's an outline of some of the major upcoming features
- iPad® support, including:
  * Keyboard shortcuts
  * Trackpad support
  * Multitasking window support
- Cloudkit for time syncing
- Multiperson nearby competition modes, so you can cube along with your friends
- Audio analysis for pauses during solves
- Support for bluetooth cubes
- Support for stackmats
- ~~Draw scramble functionality, along with a native implementation of a scrambler built from scatch~~
- Importing sessions and solves from common timers, such as ChaoTimer and csTimer
- Easy to use export to save your sessions


## User Guide

### Timer
Press and hold until the timer turns green to start. You can change the hold time in settings.
The default gestures are as follows:
- swipe left to delete the current solve
- swipe right to generate a new scramble
- swipe down to add a penalty

### Time List
All your solves in the currently selected session will be displayed in your time list.
You can sort your times by pressing "Sort by Date" or "Sort by Time". The button to the right will sort by ascending or descending order.
Pressing the select button on the top right will enter selection mode, where you can batch select, delete, move or penalise solves.
Swiping down will reveal the search bar, where you can search for your times.
Searching while in select mode will preserve your current selection.

Clicking on a solve will bring up the solve details, the time, date, event and scramble.
You can add a comment if you wish by typing in the comment box.
"Copy Solve" will copy the solve details to your clipboard.

### Stats
The default stats view shows your current and best averages of 5, 12 and 100, the number of solves in the session, session mean and your best single.
Clicking on each of the stats will bring up a detail view, such as the solves in your average.

You can customise the graphs by pressing and holding on the graph.

### Sessions
Create a new session by clicking the "New Session" button.
You can select from different types of sessions:
1. Standard Session: is a normal session where the scramble is fixed to the session event
2. Algorithm Trainer: generates scrambles that allow you to train a certain algset
3. Multiphase: times many phases during your solve, useful in blind or analysing your solve breakdown
4. Playground: session with no fixed scramble type, you can change the scramble within the session
5. Comp Sim: non-rolling session that records solves in averages of x, instead of a big session

Pinning a session will make the session bigger, and you can pin a session when creating or by long pressing on a session to access the menu.
Deleting a session will delete *all* your solves in that session, so be careful!

### Settings
You can customise almost all settings in the app and the appearance and themes.

## Some final stuff
As we are using the official TNoodle scrambler library, please see our [transpiled tnoodle-lib-objc repo](https://github.com/CubeStuffs/tnoodle-lib-objc) for more information. 
iPad and App Store are trademarks of Apple Inc., registered in the U.S. and other countries.
