# Introduction #

bim-tools is a set of plugins that can help you create building elements in sketchup and share them with BIM-software-users through the IFC file format.

# How to install #

Download the latest zip-archive from the [downloads](http://code.google.com/p/bim-tools/downloads/list) page.


Place the contents of the zip in your sketchup plugins folder.
On Windows systems probably something like:
C:\Program Files\Google\Google SketchUp 8\Plugins\

# How to use #
## Creating walls ##
![https://lh6.googleusercontent.com/-shKtHrVm_L8/To_8kfOxicI/AAAAAAAAAE8/PNGwyALNJP0/s800/steps-create-walls.png](https://lh6.googleusercontent.com/-shKtHrVm_L8/To_8kfOxicI/AAAAAAAAAE8/PNGwyALNJP0/s800/steps-create-walls.png)
  * Step 1
    * After installing the plugin, open SketchUp and draw some horizontal lines(on the red/green-plane).
    * Select the lines you want to convert to walls.
  * Step 2
    * Open the bim-tools menu, and unfold the "Create" section.
    * Set the wall properties, and click the "walls from selection" button.
  * Step 3
    * Walls are created on top of the lines, and placed in the layer "ifcWall".
## Creating wall-openings ##
![https://lh4.googleusercontent.com/-z4qQ2rkS2Og/To_8kypZHwI/AAAAAAAAAFE/D4KGiydbZGs/s800/steps-create-windows.png](https://lh4.googleusercontent.com/-z4qQ2rkS2Og/To_8kypZHwI/AAAAAAAAAFE/D4KGiydbZGs/s800/steps-create-windows.png)
  * Step 1
    * Draw the profile of a window.
  * Step 2
    * Select the drawn window.
    * Create a sketchUp component from the selection, with the options "Glue to" and "Cut opening" enabled.
    * (and optionally create a window frame(or other geometry) as a nested group/component).
  * Step 3
    * Select the component from the component-menu and place it on the wall surface.
## Export to IFC ##
![https://lh6.googleusercontent.com/-4dLWm6PRmbQ/TpCUI5gGymI/AAAAAAAAAFQ/65hU7I7J6C4/s800/steps-export-ifc.png](https://lh6.googleusercontent.com/-4dLWm6PRmbQ/TpCUI5gGymI/AAAAAAAAAFQ/65hU7I7J6C4/s800/steps-export-ifc.png)
  * Step 1
    * Make sure you save the SketchUp model first, so the exporter knows where to put the IFC file.
    * (optional) Add some project info, unfold the bim-tools "Project" section, and fill in the form.
    * (optional) Add a location, http://sketchup.google.com/support/bin/answer.py?answer=95069
    * Unfold the bim-tools "Export" section, and click the "Export to IFC" button.
  * Step 2
    * An IFC file with the same name and path as the saved sketchup model will be created.
  * Step 3
    * View the file in a IFC-viewer, BIM-software or upload it to BIMserver.
      * http://www.iai.fzk.de/www-extern/index.php?id=1138&L=1
      * http://bimserver.org/
# Known bugs and limitations #
  * Link between opening-geometry and hole is lost after closing and re-opening SketchUp.
  * Only an opening-hole gets exported to IFC, not the window geometry.
  * Sometimes wall-opening-holes pop out of the wall instead of cutting through(haven't been able to reproduce).
  * Relations in model are still "fragile", after some copy/pasting the IFC exporter might fail.
  * Solving of corners for connecting wall sections works best when using walls with the same width and height.
Please report any other bugs you encounter. It's best to add them to the Issue Tracker. http://code.google.com/p/bim-tools/issues/list

I also greatly appreciate any kind of response; missing features; broken parts; like/not like; test-cases...
# Example images #
![https://lh3.googleusercontent.com/_SNATjAuQuDk/TXPOKwJk8pI/AAAAAAAAABE/OjgcTiCibHE/s640/room01.jpg](https://lh3.googleusercontent.com/_SNATjAuQuDk/TXPOKwJk8pI/AAAAAAAAABE/OjgcTiCibHE/s640/room01.jpg)
![https://lh3.googleusercontent.com/_SNATjAuQuDk/TXPOLFlbpqI/AAAAAAAAABI/Ah9ROjf2A0M/s640/room02.jpg](https://lh3.googleusercontent.com/_SNATjAuQuDk/TXPOLFlbpqI/AAAAAAAAABI/Ah9ROjf2A0M/s640/room02.jpg)



