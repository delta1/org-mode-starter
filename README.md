# Track time with Emacs and Org-Mode 

## Install Emacs 
- [Download page](https://www.gnu.org/software/emacs/download.html)
- [Direct Windows Download for 25.2](http://mirror.ufs.ac.za/gnu/emacs/windows/emacs-25.2-x86_64.zip)

## Download the starter
- Clone this repo to your "home" folder ( on Windows: C:\Users\<username>\AppData\Roaming\ ) as the folder **.emacs.d**
- ```git clone git@github.com:delta1/.emacs.d.git .emacs.d```
- In your emacs installation folder run \bin\runemacs.exe 
- This should now start emacs, set the color theme, and open .emacs.d/org/main.org 

## Basic tutorial 
[Org mode reference card](http://orgmode.org/worg/orgcard.html) 

[Norang custom Org mode config](http://doc.norang.ca/org-mode.html)  

- M = Meta = Alt key 
- C = Ctrl
- RET = Return = Enter key

In an org file: 

- create a todo: ```M-RET``` 
- clock in to todo: while on the line of your todo: ```C-c C-x C-i```
- clock out of todo: ```C-c C-x C-o```
- view agenda: ```C-c a t``` or ```F10 t```
- new capture and clock in: ```C-c c t```
- close new capture: ```C-c C-c```
- "punch in" at start of day: ```F9 i```
- "punch out" at end of day: ```F9 o```

## General workflow

- Open Emacs, punch in for the day: ```F9 i```
- At end of day, punch out: ```F9 o```
- View agenda for current todos: ```F10 t``` 
- Up/Down arrows to select a todo, clock in to it: ```I``` (capital i) 
- Hit RET from agenda to go to actual todo for notes taking/reading
- When done with the task, clock out. ```O``` (capital o) from agenda view, or ```C-c C-x C-o``` from org view
- Mark todo as done: ```t d``` from agenda view, or ```Shift-Right``` from org view
- If interupted or need a quick capture and clock in to new todo: ```C-c c t``` and type new title
- ```C-c C-c``` to close this capture. Capture tasks go to ```refile.org``` to be refiled later
- Refiling: from agenda view, mark items with ```m```, hit ```B``` for bulk actions, ```r``` for refile, select new location, RET
- Generate clock table at the end of the month: go to ```main.org```, ```Time Recon``` todo, use TAB to view more, on #+BEGIN clocktable line make sure corrects dates are set, hit ```C-c C-x C-r``` to generate clock table for date range
- Clock table reference: http://orgmode.org/manual/The-clock-table.html 

## Useful Links 
- Emacs [Link1](http://emacs.sexy/) [Link2](http://david.rothlis.net/emacs/howtolearn.html) [Link3](https://www.emacswiki.org/emacs/LearningEmacs)
- [Org mode](http://orgmode.org/)
- [Norang custom Org mode config](http://doc.norang.ca/org-mode.html)  
