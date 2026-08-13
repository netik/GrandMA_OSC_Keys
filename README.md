# GrandMA_OSC_Keys

GrandMA OSC Keys Plugin 

This plugin is forked from Rik Berkelder's [original plugin| https://riksolo.com/blog/grandma3-osc-keys/]

It repairs an issue in the original code base when using Page IDs which are not Page 1 

Original Bug:

`setup()` was doing:

```Cmd("Store page " .. exec_page)```

If you used page 5, the create command becomes "Store page 5". In grandMA3, that is not how you create an executor “page 5” for playback.  The page has to exist first. 


This bug is addressed in this fork.


