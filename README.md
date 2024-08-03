# Nopeus
An extension of the MoreSpeeds mod for Balatro, including a new speed which reduces delays in the event manager to 0/near-zero.

Requires Steamodded 1.0.0

## Why does "nil" (or some numerical value) show up at the top left of my screen on the main menu?

This is a bug, but not one worth fixing because there's ultimately no reason to.

This is because the original UI element for the Game Speed option gets overwritten. The text that would be displayed on the option has nowhere to go, so it docks to the default position, which is the top left of your screen.
This bug is completely harmless and does nothing. Even then, it fixes itself if you load into a run and back out. The text ends up disappearing.
The text doesn't appear during a run (or maybe it is but it's appearing behind the run UI), and even then going back to the main menu won't show any leftover text.

If this bug is still grinding your gears for some arbitrary reason, I don't know what else to tell you.
