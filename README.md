# closet
A simple WoW: Classic addon to create and delete equipment sets.

Usage:

* `/saveset name` - Overwrites the equipment set named "name" with all equipment currently worn, or creates a set if one doesn't yet exist
* `/deleteset name` or `delset name` - Deletes the equipment set "name" if it exists
* `/listsets` - Lists all currently saved sets for the current character
* `/equipset name` - Equips items from the previously saved set named "name"

Notes:

Classic Era WoW API supports the Blizzard equipment manager functionality and the `/equipset` macro command, but the UI options for creating and modifying sets are disabled.

This addon just creates a couple slash commands to easily interface with the existing Blizzard API to allow creating, editing, and deleting sets.

There are no plans to develop more advanced features like integrating this visually into the "paperdoll" character frame or allowing for editing individual slots at a time. This is all or nothing. When you save a set, it saves everything you're currently wearing with the name you chose.