<h1 align="center">CubeTime</h1>

<p align="center">
  <img src="https://github.com/CubeStuffs/CubeTime/assets/65262710/4dcd721c-2e15-4ca4-8443-36be7d24f3c2"
       width="200"
       height="200">
<p align="center">
<h4 align="center">a speedcubing timer & utility app</h4>
<p align="center">
  <a href="https://apps.apple.com/us/app/cubetime/id1600392245">
    <img src="https://user-images.githubusercontent.com/24711088/146530953-94bc8542-8a1a-49a5-9faf-75c63281f2fc.png"
         height="48">
  </a>
  <a href="https://ko-fi.com/cubetime">
      <img src="https://github.com/CubeStuffs/CubeTime/assets/65262710/544abfd5-3221-4950-8bb1-f2364ff4cb97"
           height="48">
  </a>
</p>

---

# Contents
1. [Overview](#overview)
2. [Screenshots](#screenshots)
3. [Features](#features)
4. [Introductory User Guide](#introductory-user-guide)
5. [Some final stuff](#some-final-stuff)

## Overview

### Information!

 - Free (both as in libre and gratis), copylefted software (GPLv3)
 - Fully built with Swift (SwiftUI and UIKit), lightweight and modern app architecture
   * Some stats accelerated with C++
 - Simple and modern user interface
   * Beautiful dark mode that saves battery on OLED phones
   * Clean tab bar for effortless navigation

## Screenshots

#### iOS
<p align="center">
  <img src="https://user-images.githubusercontent.com/65262710/225591753-e764aef2-4694-4ba9-bf7a-e5959cef555f.png" width="19%" />
  
  <img src="https://user-images.githubusercontent.com/65262710/225591798-1e647057-88fa-49c3-be67-0c5804efebdc.png" width="19%" />
  
  <img src="https://user-images.githubusercontent.com/65262710/225592018-3c1ceb5a-7c22-4d40-a713-4682aec12532.png" width="19%" />
  
  <img src="https://user-images.githubusercontent.com/65262710/225592044-f631703d-3b81-4b60-9e5a-8c1e89f9c24f.png" width="19%" />
  
  <img src="https://user-images.githubusercontent.com/65262710/225592066-2f36a0c1-505f-44be-8c15-a8bb218c47ba.png" width="19%" />
</p>


#### iPadOS
![1](https://user-images.githubusercontent.com/65262710/225591896-848e0441-24ae-4c3e-a702-c164dc5ab140.png)
![2](https://user-images.githubusercontent.com/65262710/225591921-5709b01f-daed-4fda-a49a-01ee73aafb90.png)
![6](https://user-images.githubusercontent.com/65262710/225591977-f19c13c9-22c4-42b1-b62f-1a093e0b89af.png)


## Features
### App Features
- Built-in system haptics, and able to be changed to your liking

- Audio alerts in inspection

- All the basic timing functionalities, and fully customisable:
   * Customisable hold down time
   * Inspection time
   * Customisable timer update intervals and statistics display precision
   * Draw scramble
   * Intuitive gestures for quick and easy access to actions
     * Customisable activation threshold

- Easy to use session support
  * featuring many modes, including:
    * Standard session
    * Multiphase - for blind and other events
    * Playground sessions that support all scramble types for quick access to scrambling
    * Comp Sim
  * pinnable sessions for easy access

- Simple card design for viewing your times
  * Searchable times, along with quick and easy to use sort and filter functionality - to sort your times by date or by speed, and filter by comment, scramble type and penalty
  * Batch select times for deletion, adding penalties, moving to a different session, or copying
  * Add comments for special solves
  * Long-press menu for easy access to solve options

- Extensive statistics and solve analysis:
  * Visual graphs for your sessions
    * Such as time trend, time distribution and other graphs
  * All standard calculations, including best and current averages of 5, 12 and 100, session mean, median, and many more

- Other stats and tools, including special ones for compsim, such as:
  * calculating your bpa and wpa
  * calculating time needed to secure certain averages
  * batch scramble generator
  * timer only and scramble only tool

- iPad® support, including:
  * Keyboard shortcuts
  * Trackpad support
  * Multitasking window support
  
- CloudKit® for iCloud® session and solve syncing
- iCloud® settings syncing – so all your settings are the same across devices
     
### Upcoming Features

You can view our [Todo List for this repo](https://github.com/orgs/CubeStuffs/projects/3) for a list of all our upcoming features. You can add suggestions by opening an issue.
Here's an outline of some of the major upcoming features
- Support for bluetooth cubes
- Support for stackmats
- Importing sessions and solves from common timers, such as ChaoTimer and csTimer
- Easy to use export to save your sessions
- Algorithm Trainer and more to come...

## Introductory User Guide

### Timer
Press and hold until the timer turns green to start. You can change the hold time in settings.
The default gestures are as follows:
- swipe left to delete the current solve
- swipe right to generate a new scramble
- swipe down to add a penalty

On iPads, you can use your trackpad to two-finger swipe in the same way as your finger.

### Time List
All your solves in the currently selected session will be displayed in your time list.
Pressing the select button on the top right will enter selection mode, where you can batch select, delete, move or penalise solves.
Pressing on the seach icon will reveal the search bar, where you can search for your times.
You can also filter for scramble types, penalties and comments, along with sorting your times.
Searching while in select mode will preserve your current selection.

Clicking on a solve will bring up the solve details, the time, date, event and scramble.
You can add a comment if you wish by typing in the comment box.
"Copy Solve" will copy the solve details to your clipboard.
"Share Solve" allows you to share it to other apps or save as a file.

### Stats
The default stats view shows your current and best averages of 5, 12 and 100, the number of solves in the session, session mean and your best single.
Clicking on each of the stats will bring up a detail view, such as the solves in your average.

### Sessions
Create a new session by clicking the "New Session" button.
You can select from different types of sessions:
1. Standard Session: is a normal session where the scramble is fixed to the session event
2. Multiphase: times many phases during your solve, useful in blind or analysing your solve breakdown
3. Playground: session with no fixed scramble type, you can change the scramble within the session
4. Comp Sim: non-rolling session that records solves in averages of x, instead of a big session. Simulates competitions

Pinning a session will make the session bigger and stickied at the top of sessions, and you can pin a session when creating or by long pressing on a session to access the menu.
Deleting a session will delete *all* your solves in that session, so be careful!

### Settings
You can customise almost all settings in the app and the appearance and themes.

### Tools
You can access the tools menu through settings on iPhone (or split view iPad) and through the menu icon on large iPad modes. CubeTime has basic timer and scramble only modes, along with a batch scramble generator and average calculator.

## Some final stuff
As we are using the official TNoodle scrambler library, please see our [transpiled tnoodle-lib-objc repo](https://github.com/CubeStuffs/tnoodle-lib-objc) for more information. 

iPad and App Store are trademarks of Apple Inc., registered in the U.S. and other countries.
