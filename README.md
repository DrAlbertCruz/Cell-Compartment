# Neurospora Crassa Length (NCL) Software
First version 2013. Created by A.Cruz (Center for Research in Intelligent Systems) for the Borkovich Lab (UC Riverside).

# Installation

* Run 'runGUI.m' from the MATLAB command line.
* MATLAB 2016a or higher is recommended.

# Save file format

After saving, the columns are ordered as:

1. Major axis length. The length of the long side (in um).
2. Minor axis length. The width of the short side (in um).
3. Area (in um)
4. Perimeter (in um)
5. Orientation. The angle of the major axis from the horizontal axis.

*Note that if you do not have Microsoft Office installed, trying to save as an XLS will fail.*

# Tips

* If you need to tweak the STREL parameter to get better segmentation results, start with low values (1) and work your way up one by one. *This value must be an integer.* Values greater than 20 may create problems.
* Please enter um/pixel, not um^2/pixel^2.
