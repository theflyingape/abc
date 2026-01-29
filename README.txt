VIC 20 Awesome Boot Cartridge (ABC)

 -- authored by Robert Hurst
	started on 24-Nov-2015


FOREWORD:

Commodore invented a "Super Expander" cartridge that essentially upgrades the 
VIC 20 to an 8K machine with an extended BASIC.  Back then, it was good 
marketing to sell a home computer at a cheaper cost with the continuity angle
of "future expansion".

Frankly, most consumers then didn't know what they needed a home computer for 
to start with, so how could they forecast if more expansion would be needed? 
Well, it was a comforting thought nonetheless that the upfront investment 
could allow for choices on incremental improvements over time.  And then 
there was always that "one up" crowd to appease, you know, my machine is 
better than yours?

Commodore BASIC 2.0 was fine for what it was purposed for: beginners.  And 
Super Expander made a "level up" experience for beginners to explore, from a 
BASIC programmer's perspective, enhanced home computing in that era.

Today, VIC ABC is an attempt to make a "level up" experience for the aspiring 
homebrew programmer to help appease an unwavering appetite found with retro-
computing enthusiasts.  I hope you will find it meeting the challenge.


OBJECTIVE:

A floppy disk that can load the VIC ABC image for autostarting in the game 
cartridge space.  Another option is put many programs on an ABC floppy disk 
that presents a user menu to autoload and run a title.

Other parts to the VIC ABC image will include an arcade game programmer's API, 
suited to ease the display activities needed for graphic animation.  The 
programmer can concentrate more on the game play itself, the creativity 
needed to make it fun (or addictive) and friendly to use.  Just like the 
VIC 20 was intended to be!


OPERATION:

A VIC 20 (real or emulated) with at least 8K memory expansion slotted for the
game cartridge address space ($A000) is required to boot off its floppy disk:

LOAD "ABC",8,1
SYS 64802

... or any other machine "warm reset" method available to you.

One could also burn this as a cartridge image to ROM for use on a real VIC 20, 
or attach it separately like a ROM cartridge, i.e., using the -cartA option or 
pressing Alt-C to attach it from within the VICE emulator.

Swapping floppy disks between resets is allowed.  An encouraging thought, 
because would that not be wonderful if such a video game library of sorts grew 
from VIC ABC use?


ABOUT THE AUTHOR:

Robert Hurst (me) adopted home computing using VIC 20 back in February 1982. 
As a junior in high school, I learned computer math using BASIC programming. 
Like every other typical teenager of the day, I had an appetite for video
games.  But unlike most, I had a desire and aptitude to create my own brand 
of games, which urged me to dive deeper into my VIC 20 using machine 
language.

A series of BASIC-hybrid video games followed: Solarian-V, Pizza Delivery Man, 
and Sea War.  After 2-years, I committed to 100% machine language programming. 
First was the QuikVIC Graphic Editor to compete with Andy Finkel's utility. 
Then came the ultimate prize in Quikman: an unashamed clone of Pac-Man.

I would re-visit my VIC 20 roots in October 2008, purely as a pastime, and 
began to tinker with the cc65 6502 compiler suite.  After disassembling the 
retrieved Quikman code saved on a tape made in 1984, I was able to remake a
series of improvements to the game: Quikman2K8, a 4K and 8K Quikman game 
cartridge, and finishing it off with Quikman+ using 8K memory expansion.

Other game titles (Omega Fury, Berzerk-MMX, Break-Out! and Sprite Invaders)
came along the way to leverage a VIC Software Sprite Stack: my API not unlike 
what is to be found with this Awesome Boot Cartridge.  Another programmer found 
use of VIC-SSS in his wonderful port of Pooyan, so it has proven to be of some 
value beyond its gamers.

In the end, keep it real, and always keep it fun!

