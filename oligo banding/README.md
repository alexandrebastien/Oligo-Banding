# Oligo-Banding ImageJ Macro

## Installation and requirements
The installation is simply done by copying the Oligo_Banding.ijm file into your [ImageJ](https://imagej.net/) (or [Fiji](https://fiji.sc/)) plugin folder. This pluggin is only tested with the Fiji distribution of ImageJ and ImageJ version 1.53t. You will need to install [Action Bar](https://figshare.com/articles/dataset/Custom_toolbars_and_mini_applications_with_Action_Bar/3397603/12) from Jerome Mutterer. This can be done by adding [IBMP-CNRS](https://sites.imagej.net/Mutterer/) update site to Fiji.

## Usage
<img src="https://github.com/alexandrebastien/Oligo-Banding/blob/main/oligo%20banding/Oligo-Banding%20Screenshot.png" width="600">

### Loading an image
In order to get started, simply load an image from the *sample data* folder and the associated regions of interest (ROIs) in the zip file by dragging both on the ImageJ bar. This should open the image and ROI Manager with all the chromosomes already selected.

### Mode
Click on this button to rotate on the three imaging mode: Single channel black and white, single channel color, multi-channel merged colors. In single channel mode, use the numbers to the right to select the desired channel. In multi-channel mode, numbers will toggle on/off the channels.

### Overlays (Ov)
This button toggles hide/view of possible overlays. This could be use to put notes on the images, or arrow.

### Denoise
This button will run the Remove Outliers command. Make sure to use it only once on an image to avoid excess blur.

### Brightness and Contrast (B/C)
This button opens the Brightness and Contrast window.

### Region of Interest (ROI)
This buttons opens the ROI Manager window.

### Analyze
This button will trigger the main analysis. It scans all ROIs and get a linear plot profile for each color then find all the maximas. After that, the peaks are merged across colors to create the composite color signature. By default the base colors are red (R), yellow (Y) and cyan (C). If a peak is detected in red and yellow within close proximity it will be labeled as orange (O) in the composite signature. Composite colors are orange (R+Y = O), white (C+R = W) and green (C+Y = G). The signature is a string of letters printed in the Results table for each chromosome. Once the signature are acquired, the closest theorical chromosome signature (Ref) and its sequence will be found by minimizing the Levenstein distance, and the number of error (Err) will be listed.

### Config
* In the *Config* menu, one can set the base and composite *colors* as a string (default is RYCOWG).
* Then all the *chromosomes* signature reference are listed as comma seperated values with the last two being X and Y, and could be edited in this parameter.
* *X Tolerance* is the spacing in µm where two peaks will be considered as one and merged.
* *Y Tolerance* is prominence used in percentage when finding the peaks maxima.
* *Cutoff* is a level expressed in percentage that is going to be substracted from the plot for data cleaning. Every value below that level is replaced by 0. This is not needed generally.
* *Dapi mask* is generally the last channel in the image. It could be used to remove unwanted signal from the plots. If selected, an automatic threshold is done on the dapi channel to create a mask that remove any signal in the other channel that is not overlapping with dapi. It is not necessary to use this, but could improve results slightly.
* *Tool icon in ImageJ* option will check for the Oligo-Banding icon in ImageJ bar and will add it if selected and not present.

### Layout
With this, one can save and load all the windows positions to quickly create an effective working environnement.

### Quit (x)
This close the Oligo-Banding Action Bar.

## TO DO

* Check if DAPI threshold follows config option
* Check if cutoff behave properly
* Check if plot is scaled properly

