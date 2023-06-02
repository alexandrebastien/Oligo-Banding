run("Action Bar","/plugins/ULaval/Oligo_Banding.ijm");
exit();

<stickToImageJ>
<noGrid>

<line>
<text>OLIGO-BANDING  
<button>
label=Mode
arg=toggleDispalyMode();
<button>
label=1
arg=toggleChannel(1);
<button>
label=2
arg=toggleChannel(2);
<button>
label=3
arg=toggleChannel(3);
<button>
label=4
arg=toggleChannel(4);
<button>
label=Ov
arg=toggleOverlay();
run("Hide Overlay");
run("Show Overlay");

<separator>
<button>
label=Denoise
arg=run("Remove Outliers...");
<button>
label=B/C
arg=run("Brightness/Contrast...");
<button>
label=ROI
arg=run("ROI Manager...");
<separator>
<button>
label=Analyze
arg=analyze();
<button>
label=Match
arg=match();

<separator>
<button>
label=Config
arg=config();
<button>
label=Layout
arg=layout();
<button>
label=x
arg=<close>
</line>





































<codeLibrary>
// === MOVE THIS LINE TO 103 FOR DEBUGGING (+100 on calls) ===
// Set options for the session
setOption("ExpandableArrays", true);
var num;


function config() {
// [Config] button in action bar
// This function open a dialog box where it is possible to adjust all
// the configuration parameters of Oligo-Banding
 
	// Chromosomes defaults
	// This is designed from the porcine oligo probes used in the lab
	chromosomes = "GYWROWRGCWO,CORGOC,CRWCY,YRWYC,WGCO,"+
				  "YROCRW,YCOYW,RYWGY,OWGYR,CWR,YRG,GOR,"+
				  "GYWCYGWCOCR,CGWYR,WYRWC,WYG,OCY,CWY,OYCG,CR";

	// Loading prefs (all config is saved into ij.Prefs)
	colors = call("ij.Prefs.get", "UL.OligoBanding.colors", "RYCOWG");
	chromosomes = call("ij.Prefs.get", "UL.OligoBanding.chromosomes", chromosomes);
	xtol = call("ij.Prefs.get", "UL.OligoBanding.xtol", 0.3);
	ytol = call("ij.Prefs.get", "UL.OligoBanding.ytol", 9.0);
	dapiMask = call("ij.Prefs.get", "UL.OligoBanding.dapiMask", true);
	cutoff = call("ij.Prefs.get", "UL.OligoBanding.cutoff", 0.0);
	
	// Check if tool icon is in start menu
	str = getStartMenuSTR();
	toolInStartMenu = isToolInStartMenu(str);

	// Build dialog window
	Dialog.create("Oligo Banding Configuration");
	Dialog.addString("Colors", colors, 8);
	Dialog.addString("Chromosomes", chromosomes,8);
	Dialog.addNumber("X Tolerance", xtol,2,4,"um"); //check units
	Dialog.addNumber("Y Tolerance", ytol,1,4,"%");
	Dialog.addNumber("Cutoff", cutoff,0,4,"%");
	Dialog.addCheckbox("DAPI Mask", dapiMask);
	Dialog.addCheckbox("Tool icon in ImageJ", toolInStartMenu);
	Dialog.addHelp("https://github.com/alexandrebastien/Oligo-Banding");
	Dialog.show();

	// Get values from user after dialog is closed
	colors = Dialog.getString();
	chromosomes = Dialog.getString();
	xtol = Dialog.getNumber();
	ytol = Dialog.getNumber();
	cutoff = Dialog.getNumber();
	dapiMask = Dialog.getCheckbox();
	toolInStartMenuNew = Dialog.getCheckbox();

	// Save to prefs
	call("ij.Prefs.set", "UL.OligoBanding.colors", colors);
	call("ij.Prefs.set", "UL.OligoBanding.chromosomes", chromosomes);
	call("ij.Prefs.set", "UL.OligoBanding.xtol", xtol);
	call("ij.Prefs.set", "UL.OligoBanding.ytol", ytol);
	call("ij.Prefs.set", "UL.OligoBanding.dapiMask", dapiMask);
	call("ij.Prefs.set", "UL.OligoBanding.cutoff", cutoff);
	
	// If icon settings changed, write tool in start menu
	if (toolInStartMenuNew == true && toolInStartMenu == false) {
		addRemoveToolInStartMenu(true);
	} else if (toolInStartMenuNew == false && toolInStartMenu == true) {
		addRemoveToolInStartMenu(false); showStatus(" Icon will be removed after restart");
	}
}

function getStartMenuPath() {
	// There's 2 possible path, depending on Fiji/ImageJ version
	ok = false; path = "";
	path1 = getDirectory("macros") + "StartupMacros.fiji.ijm";
	path2 = getDirectory("macros") + "StartupMacros.ijm";
	
	// Check if the file exist and return the path
	if (File.exists(path1)) {
		ok = File.rename(path1, path2);
		path = path2;
	} else {
		if (File.exists(path2)) {
			ok = true;
			path = path2;
		}
	}
	return path;
}

function getStartMenuSTR() {
// Read "StartupMacros" file and return content as a string

	// Get StartupMacros file path
	path = getStartMenuPath();
	
	// If found, read it and return as a string
	if (path != "") {str = File.openAsString(path);}
	else {showMessage("File: "+path+" not found.");}
	return str;
}


function isToolInStartMenu(str) {
// Check if Oligo-Banding tool is present in the string
// retrived from StartupMacros

	startmark = "\n// START OLIGO-BANDING MENU\n";
	start = indexOf(str, startmark);
	if (start == -1) {return false;}
	else {return true}
}

function addRemoveToolInStartMenu(add) {
// Add or remove tool in StartupMacros file
	
	// Get StartupMacros path
	path = getStartMenuPath();
	
	// Marks for the Oligo-Banding section
	startmark = "\n// START OLIGO-BANDING MENU\n";
	endmark   = "// END OLIGO-BANDING MENU\n";
	
	// Check if path is ok
	if (path != "") {
		// Open the file and check for the marks
		str = File.openAsString(path);
		start = indexOf(str, startmark);
		end = lastIndexOf(str, endmark);
		
		// Macro code to add to the file
		new = "macro \"Oligo Banding Action Tool - "+
			  "C000D50D53D58D5bD5eD63D66D68D6bD6eD90D93D96D97D98D9bD9eDa0Da3D"+
			  "a8DabDaeC111D67Cf80D5cD5dD6cD6dD9cD9dDacDadCf0fD5fD6fD9fDafC0f"+
			  "0D59D5aD69D6aD99D9aDa9DaaCff0D51D52D61D62D91D92Da1Da2C222D60Ce"+
			  "12D54D55D64D65D94D95Da4Da5C0ffD76D77D86D87"+
			  "\" {\n"+
			  "    run(\"Oligo Banding\");\n"+
			  "}\n";
		// If ADD is chosen
		if (add) {
			// Save in str variable, and write to a temp file to be installed
			str = str + startmark + new + endmark;
			dir = getDir("temp"); tmppath = dir + File.separator + "Oligo_Banding.ijm";
			File.saveString(str, tmppath);
			run("Install...","install=["+tmppath+"]");
		}
		// If REMOVE is chosen
		else {
			// Keep str before and after the marks
			str = substring(str, 0, start) +
			substring(str, end+lengthOf(endmark)-1, lengthOf(str)-1);
		}
		// Save StartupMacros
		File.saveString(str, path);
	// If path not found
	} else {
		showMessage("File: "+path+" not found.");
	}
}

// [Mode] button in action bar
//	Cycle through composite, color and grayscale
function toggleDispalyMode() {
	msg="";
	if (nImages<1) msg='no image';
	if (nImages>0) if(!is("composite")) msg='not a composite image';
	if (msg!="") {showStatus(msg);return;}
	modes=newArray("Composite","Color","Grayscale");
	Stack.getDisplayMode(mode);
	m=0;
	for (i=0;i<modes.length;i++) 
		if (mode==modes[i].toLowerCase()) m=i;
	m=(m+1)%3;
	Stack.setDisplayMode(modes[m]);
	showStatus("Display mode set to : "+modes[m]);
}

// [1,2,3,4] buttons in action bar
//	Select or toggle channel
function toggleChannel(i) {
	if (nImages<1) return;
	if (!is("composite")) return;
	Stack.getActiveChannels(s);
	c=s.substring(i-1,i);
	Stack.setChannel(i);
	Stack.setActiveChannels(s.substring(0,i-1)+!c+s.substring(i));
}

// [Ov] button in action bar
//	Toggle overlays on/off
function toggleOverlay() {
	if (nImages<1) return;
	if (!is("composite")) return;
	if (Overlay.hidden) Overlay.show; else Overlay.hide;
}

// [B/C], [ROI], and [x] are called directly above

// [Analyze] button in action bar
//	Main function: gets fluo signatures from all ROIs
function analyze() {
	selectMainImage();
	setBatchMode(true);
	data = getData(); // get plot profile data as cells

	/*
	selectMainImage(); setMetadata("Label", "OligoData \n\n");
	setMetadata("OB-data", String.join(data,";"));
	data = parseFloatArray(split(getMetadata("OB-data"),";"));
	*/
	
	minmax = getMinMax(data); // get min max for filtering (before mask)
	data = filterData(data,minmax); // filter data
	peaks = getPeaks(data,minmax); // get peaks from data, as cells
	LetAndPos = getLettersAndPositions(peaks); // get letters
	setBatchMode("exit and display");

	// Show plots
	plotROI(data,peaks,LetAndPos);

	//Match data
	match();
}

/////////////////////////////////////////////////////////////

// This function make sure that main image is selected for analysis
// and not the Plots image, as it would cause an error
function selectMainImage() {
	if (getTitle() == "Plots") {
		images = getList("image.titles");
		for (i = 0; i < images.length; i++) {
			if (images[i] != "Plots") {selectWindow(images[i]);}
		}
	}
}

// [Layout] button function
// Check dialog output and redirect to save or load
function layout() {
	bool = getBoolean("Oligo-Banding: windows layout", "save", "load");
	if (bool == 1) {saveLayout();}
	if (bool == 0) {loadLayout();}
}

// Function to save the windows layout
function saveLayout() {
	// Image and plots size and location
	images = getList("image.titles");
	for (i = 0; i < images.length; i++) {
		selectWindow(images[i]); getLocationAndSize(x, y, w, h);
		if (images[i] != "Plots") {
			List.set("Main", String.join(newArray(x,y,w,h)));
		}	else {
			List.set("Plots", String.join(newArray(x,y,w,h)));
		}
	}

	// ROI Manager Size and Location
	rm = "rm = RoiManager.getInstance();\n";
	x = parseInt(eval("script", rm+"rm.getLocation().getX();\n"));
 	y = parseInt(eval("script", rm+"rm.getLocation().getY();\n"));
	w = parseInt(eval("script", rm+"rm.getSize().getWidth();\n"));
 	h = parseInt(eval("script", rm+"rm.getSize().getHeight();\n"));
	List.set("ROI_Manager", String.join(newArray(x,y,w,h)));

	// Results Size and Location
	rt = "rt = ResultsTable.getResultsWindow();\n";
	x = parseInt(eval("script", rt+"rt.getLocation().getX();\n"));
 	y = parseInt(eval("script", rt+"rt.getLocation().getY();\n"));
	w = parseInt(eval("script", rt+"rt.getSize().getWidth();\n"));
 	h = parseInt(eval("script", rt+"rt.getSize().getHeight();\n"));
	List.set("Results", String.join(newArray(x,y,w,h)));
	
	// ImageJ Size and Location
	x = parseInt(eval("script", "IJ.getInstance().getLocation().getX();"));
	y = parseInt(eval("script", "IJ.getInstance().getLocation().getY();"));
	w = parseInt(eval("script", "IJ.getInstance().getSize().width;"));
	h = parseInt(eval("script", "IJ.getInstance().getSize().height;"));
	List.set("ImageJ", String.join(newArray(x,y,w,h)));

	// Store Layout
	call("ij.Prefs.set", "UL.OligoBanding.layout", List.getList);
}


// Function to load saved windows layout
function loadLayout() {
	defaults = 
		"ImageJ=0, 0, 627, 146\n"+
		"Main=613, 4, 722, 602\n"+
		"Plots=611, 605, 548, 385\n"+
		"ROI_Manager=1148, 603, 188, 388\n"+
		"Results=0, 144, 625, 848\n";
	strlist = call("ij.Prefs.get", "UL.OligoBanding.layout", defaults);
	List.setList(strlist);
	
	// Image and plots size and location
	images = getList("image.titles");
	for (i = 0; i < images.length; i++) {
		selectWindow(images[i]);
		if (images[i] != "Plots") {
			L = split(List.get("Main"),",");
			setLocation(L[0], L[1], L[2], L[3]);
		}	else {
			L = split(List.get("Plots"),",");
			setLocation(L[0], L[1], L[2], L[3]);
		}
	}
	
	// ROI Manager Size and Location
	L = split(List.get("ROI_Manager"),",");
	rm = "rm = RoiManager.getInstance();\n";
	eval("script", rm+"rm.setLocation("+L[0]+","+L[1]+");");
	eval("script", rm+"rm.setSize("+L[2]+","+L[3]+");");
		
	// Results Size and Location
	L = split(List.get("Results"),",");
	rt = "rt = ResultsTable.getResultsWindow();\n";
	eval("script", rt+"rt.setLocation("+L[0]+","+L[1]+");");
	eval("script", rt+"rt.setSize("+L[2]+","+L[3]+");");
	
	// ImageJ Size and Location
	L = split(List.get("ImageJ"),",");
	eval("script","IJ.getInstance().setLocation("+L[0]+","+L[1]+");");
	eval("script","IJ.getInstance().setSize("+L[2]+","+L[3]+");");
}

// Wrapper function to move ImageJ window to a specific location
function setImageJLocationAndSize(x, y, w, h) {
	eval("script","IJ.getInstance().setLocation("+x+","+y+","+w+","+h+");\n")
}

// Function to get a window size and location by title
// Output is an array xywh wrapped into a string
function getLocation(title) {
	selectWindow(title);
	getLocationAndSize(x, y, w, h);
	return String.join(newArray(x,y,w,h));
}

// Convert an array of numerical strings to an array of float
function parseFloatArray(A) {
	B = newArray(A.length);
	for (i = 0; i < A.length; i++)
		B[i] = parseFloat(A[i]);
	return B;
}

// Get letters and positions from peaks data obtained from the plots
function getLettersAndPositions(peaks) {
	// Init stuff
	positions = newArray(0); signature = newArray();
	tol = call("ij.Prefs.get", "UL.OligoBanding.xtol", 0.25);

	// Loop on ROIs
	for (r = 0; r < RoiManager.size; r++) {
		
		// Set ROI columns with names from manager
		Table.set("ROI", r, RoiManager.getName(r));
		
		// Init arrays and define colors
		allmx = newArray(); col = newArray(); ic = 0;
		colors = newArray("R","Y","C","O","W","G");

		// Loop on colors
		for (c = 0; c < 3; c++) {
			
			// Get x max
			mx = getCells(peaks,6*r+2*c);
			
			// Write letter from colors[c]
			for (i = 0; i < mx.length; i++) {
				col[ic] = colors[c]; ic++;
			}
			
			// Concatenate all x max
			allmx = Array.concat(allmx,mx);
		}
		
		// Sort allmx then sort col according to allmx order
		Array.sort(allmx, col);
	
		// Merge array is like [1,1,2,3,3,...], it tells what element to merge
		merge = getMergeArray(allmx,tol);
	
		// Letters for composite peaks
		signature[r] = mergeColors(merge,col);
		Table.set("Signature", r, signature[r]);
	
		// Get average positions in x for the peaks to merge
		tmp = mergePeaks(merge,allmx);
		positions = concatCells(positions,tmp);
	}
	List.set("positions", String.join(positions,";"));
	List.set("letters", String.join(signature,";"));
	return List.getList;
}

// [Match] button in action bar
//	Match the signature to theorical chromosomes minimizing Levenshtein distance
function match() {
	ref = getChrColorSeqRef();
	chr = Table.getColumn("Signature"); // Maybe get this as function input
	
	for (c = 0; c < chr.length; c++) {
		refDist = newArray(ref.length);
		for (r = 0; r < ref.length; r++) {
			refDist[r] = distance(ref[r],chr[c]);
		}
		rank = Array.rankPositions(refDist);
		r1 = rank[0]+1;
		Table.set("Ref", c, r1);
		Table.set("Err", c, refDist[rank[0]]);
		Table.set("Sequence", c, ref[rank[0]]);
	}
}

// Obtain the plot profile data from the images and ROIs
// The data variable is the main variable of this analysis.
// The type is a custom defined cell type that make possible
// the concatenation of many arrays of diffrents size in a 
// single variable.
function getData() {
	// If DAPI is chosen to be used as a mask run this
	// DAPI is supposed to give almost homogeneous signal
	// across all chromosomes.
	run("Duplicate...", "title=main duplicate");
	dapiMask = call("ij.Prefs.get", "UL.OligoBanding.dapiMask", true);
	if (dapiMask) {
		run("Duplicate...", "title=dapi duplicate channels=4");
		setAutoThreshold("Huang dark no-reset");
		setOption("BlackBackground", true);
		run("Convert to Mask"); run("Divide...", "value=255");
		selectWindow("main");
		imageCalculator("Multiply stack", "main","dapi");
		close("dapi"); selectWindow("main");
	}
	
	// Concatenate everything in the data variable as cell type
	data = newArray(0);
	for (r = 0; r < RoiManager.size; r++) {
		roiManager("select", r);
		showStatus("Analyze ROI (" + r+1 + "/"+ RoiManager.size + ")");
		// Get intensities data
		y = getColorProfileY();
		// Get length in real unit
		x = getColorProfileX(y.length,3);
		// Concatenate both x and y
		data = concatCells(data,x);
		for (c = 0; c < 3; c++) {
			tmp = getSubY(y,c,3);
			data = concatCells(data,tmp);
		}
	}
	close("main"); showStatus("");
	return data;
}

// Function to retrieve peaks from the intensities profile data
function getPeaks(data,minmax) {
	peaks = newArray(0);
	for (i = 0; i < RoiManager.size; i++) {
		tol = call("ij.Prefs.get", "UL.OligoBanding.ytol", 10);
		
		x = getCells(data,4*i);
		for (c = 0; c < 3; c++) {
			tolerance = parseFloat(tol)/100 * (minmax[2*c+1]-minmax[2*c]);
			y = getCells(data,4*i+1+c);
			mi = Array.findMaxima(y,tolerance);
			mi = Array.sort(mi);
			mx = getSubArray(x,mi);
			my = getSubArray(y,mi);
			peaks = concatCells(peaks,mx);
			peaks = concatCells(peaks,my);
		}
	}
	return peaks;
}

// Return a linear array in real unit along ROI length
function getColorProfileX(len,ch){
	x = newArray(len/ch);
	getPixelSize(u, pW, pH);
	for (i=0; i<x.length; i++)
		x[i] = i*pW;
	return x;
}

// Return the intensities profile along ROI length
// for all colors concatenated
function getColorProfileY(){
	y = newArray(); filtermin = true;
	getDimensions(w, h, ch, sl, fr);
	for (c = 1; c < ch; c++) {
		Stack.setChannel(c);
		tmp = getProfile();
		y = Array.concat(y,tmp);
	}
	return y;
}


function getMinMax(data){
	minmax = newArray();
	// For each color
	for (c = 0; c < 3; c++) {
		concat = newArray();
		// For each ROI, get the intensities (y) and concatenate
		for (r = 0; r < RoiManager.size; r++) {
			yi = getCells(data,4*r+1+c);
			concat = Array.concat(concat,yi);
		}
		// Get the min/max for all ROIs for a single color
		Array.getStatistics(concat, min, max, mean, stdDev);
		minmax[2*c] = min; minmax[2*c+1] = max;
	}
	// Array of min_color1, max_color1, min_color2, ...
	return minmax;
}

function filterData(data,minmax) {
	newdata = newArray();
	cutoff = newArray();

	cutoff_param = call("ij.Prefs.get", "UL.OligoBanding.cutoff", 30);
	
	// -- Get cutoff --
	// For a each color
	for (c = 0; c < 3; c++) {
		// Concatenate all the intensities from all the ROIs
		y = newArray();
		for (r = 0; r < RoiManager.size; r++) {
			tmp = getCells(data,4*r+1+c);
			y = Array.concat(y,tmp);
		}
		// Sort them and extract the index of the value
		// that closest to the cutoff parameter in percentage
		y = Array.sort(y);
		idx = round(y.length*cutoff_param/100);
		cutoff[c] = y[idx];
	}
	
	
	// -- Push newData --
	// Remove the cutoff value to all intensity data,
	// if the value is negative, change it to 0
	for (r = 0; r < RoiManager.size; r++) {
		x = getCells(data,4*r);
		newdata = concatCells(newdata,x);
		for (c = 0; c < 3; c++) {
			y = getCells(data,4*r+1+c);
			for (i = 0; i < y.length; i++) {
				y[i] = y[i] - cutoff[c];
				if (y[i] < 0) {y[i] = 0;}
			}
			newdata = concatCells(newdata,y);
		}
	}
	return newdata;
}

// Get one y array from a concatenation
// y is the concatenanted data, c is the desired color
// and cn is the color number in the data
function getSubY(y,c,cn){
	len = y.length/cn; y1 = newArray();
	y1 = Array.slice(y,c*len,(c+1)*len);
	return y1;
}

// Plot data
function plotROI(data,peaks,LetAndPos) {
	// Init stuff
	setBatchMode(true);

	// Close plot and save location
	images = getList("image.titles"); plotExist = false;
	for (i = 0; i < images.length; i++) {
		if (images[i] == "Plots") {
			selectWindow("Plots");
			getLocationAndSize(plotx, ploty, plotw, ploth);
			close(images[i]);
			plotExist = true;
		}
	}
	
	hex = getLUTasHEX(); getPixelSize(unit, pW, pH);
	catstr = ""; chr = newArray(RoiManager.size);
	tmp = Array.slice(data,data[0]+1,data.length-1);
	Array.getStatistics(tmp, min, max, mean, std);

	if (LetAndPos.length > 0) {
		List.setList(LetAndPos);
		letters = split(List.get("letters"),";");
		positions = parseFloatArray(split(List.get("positions"),";"));
	}

	// Loop on ROIs
	for (r = 0; r < RoiManager.size; r++) {
		// Init plot
		chr[r] = RoiManager.getName(r);
		Plot.create(chr[r]+"L", unit, "");
		Plot.setLineWidth(3);

		// Get x data
		x = getCells(data,4*r);

		// Loop on colors
		for (c = 0; c < 3; c++) {
			// Set color for plot
			Plot.setColor(hex[c]);
			
			// Plot data
			yi = getCells(data,4*r+1+c);
			Plot.add("line", x, yi, "");

			// Plot peaks
			if (peaks.length > 0) {
				mx = getCells(peaks,6*r+2*c);
				my = getCells(peaks,6*r+2*c+1);
				Plot.add("box", mx, my, "");
			}
		}
		Plot.show(); Plot.setLimitsToFit();
		Plot.getLimits(xMin, xMax, yMin, yMax);
		Plot.setLimits(xMin, xMax, min, max);

		// Plot letters
		if (LetAndPos.length > 0) {
			merge = getCells(positions,r);
			Plot.setColor("black");
			Plot.getLimits(xMin, xMax, yMin, yMax);
			sig = letters[r];
			for (t=0; t < sig.length; t++) {
				posx = (merge[t]-xMin)/(xMax-xMin)-0.01;
				Plot.addText(sig.charAt(t), posx, 0.98);
			}
		}
		
		// Make high resolution plot
		Plot.makeHighResolution(chr[r],2.0);
		close(chr[r]+"L");
		catstr = catstr+" image"+r+1+"="+chr[r];
	}

	// Make plot stack for all ROIs
	run("Concatenate...", "title=tmp "+catstr);
	for (r = 0; r < RoiManager.size; r++) {
		Stack.setSlice(r+1);
		run("Set Label...", "label="+chr[r]);
	}
	run("Scale...", "x=0.5 y=0.5 interpolation=Bilinear average process create title=Plots");
	close("tmp"); close(chr[0]);

	// Reuse plot location
	
	setBatchMode("exit and display");
	selectWindow("Plots");
	if (plotExist) {setLocation(plotx, ploty, plotw, ploth);}
}

// Get hex colors from LUTs
function getLUTasHEX() { 
	getDimensions(w, h, ch, sl, fr);
	hex = newArray(ch); dark = 0.65;
	for (c = 0; c < ch; c++) {
		Stack.setChannel(c+1);
		getLut(reds, greens, blues);
		r = toHex(reds[255]*dark);
		g = toHex(greens[255]*dark);
		b = toHex(blues[255]*dark);
		hex[c] = "#"+""+pad(r)+""+pad(g)+""+pad(b);
	}
	return hex;
}

// Return default value for chr
//     Base colors  : ch1 R:red, ch2 Y:yellow, ch3 C:cyan
//     Mixed colors : O(RY):orange, W(RC):white, G(YC):green
function getChrColorSeqRef() {
	chr = newArray(20);
	chr[0]  = "GYWROWRGCWO"; chr[1]  = "CORGOC"; chr[2]  = "CRWCY";
	chr[3]  = "YRWYC"; chr[4]  = "WGCYC"; chr[5]  = "YROCRW";
	chr[6]  = "YCOYW"; chr[7]  = "RYWGY"; chr[8]  = "OWGYR"; chr[9] = "CWR";
	chr[10] = "YRG"; chr[11] = "GOR"; chr[12] = "GYWCYGWCOCR";
	chr[13] = "CGWYR"; chr[14] = "WYRWC"; chr[15] = "WYG"; chr[16] = "OCY";
	chr[17] = "CWY"; chr[18] = "OYCG"; chr[19] = "CR";
	return chr;
}

// Check for peaks that are too close together,
// based on tolerance (tol), and write a merge
// array. Ex: 111234456
// This means that the first 3 peaks are merged
// together and peaks 6 and 7 together
function getMergeArray(x,tol) {
		merge = newArray(x.length);
		merge[0] = 0; k = 1;

		// Write k (1,2,3..) for x to merge
		for (i = 1; i < x.length; i++) {
			if (x[i]-x[i-1] < tol)
				merge[i] = merge[i-1];
			else {merge[i] = k; k++;}
		}
		return merge;
}

// For all the peaks that need to be merged, find 
// the average position in x and return a new x
function mergePeaks(merge,x) {
	xnew = newArray();
	if (x.length > 0) {
		for (i = 0; i <= merge[merge.length-1]; i++) {
			xval = 0; n = 0;
			for (j = 0; j < merge.length; j++) {
				if (merge[j] == i) {
					xval = xval + x[j]; n++;
				}
			}
			xnew[i] = xval/n;
		}
	}
	return xnew;
}

// From the merge array, write the letters of the colors
// and try to merge them with replaceVal when two peaks
// of diffrent colors match. Return a signature of peaks
// in term of a sequence of string Ex: CWRYG ...
function mergeColors(merge,col) {
	peaks = "";
	if (col.length > 0) {
		for (i = 0; i <= merge[merge.length-1]; i++) {
			val = "";
			for (j = 0; j < merge.length; j++) {
				if (merge[j] == i)
					val = val + col[j];
				if (val.length > 2)
					val = "X";
			}
			val = replaceVal(val);
			peaks = peaks + val;
		}
	}
	return peaks;
}

// Since 3 channels are used to make 6 colors, some values are :
// red-yellow -> orange, red-cyan -> white, yellow-cyan -> green
function replaceVal(val) {
	val = replace(val, "RR", "R");
	val = replace(val, "YY", "Y");
	val = replace(val, "CC", "C");
	val = replace(val, "RY", "O"); val = replace(val, "YR", "O");
	val = replace(val, "RC", "W"); val = replace(val, "CR", "W");
	val = replace(val, "YC", "G"); val = replace(val, "CY", "G");
	return val;
}

// Levenstein distance between two strings s,t
function LD(s,t) {
	// Init d and length
	n = parseInt(s.length);
	m = parseInt(t.length);
	if (n == 0) return m;
	if (m == 0) return n;
	d = iniMat(n+1,m+1,0);

	// Set first row and column to 1,2,3...
	for (i = 0; i <= n; i++)
	  d = setMat(d,i,0,i);
	for (j = 0; j <= m; j++)
	  d = setMat(d,0,j,j);

	// Main loop (fill LD matrix)
	for (i = 1; i <= n; i++) {
		s_i = charCodeAt(s, i-1);
		for (j = 1; j <= m; j++) {
			// Get cost
			t_j = charCodeAt(t, j-1);
			if (s_i == t_j) cost = 0;
			else cost = 1;
			a = getMat(d,i-1,j)+1; // move down cost 1
			b = getMat(d,i,j-1)+1; // move right cost 1
			c = getMat(d,i-1,j-1) + cost; // diagonal cost 0 if matches
			min = minimum(a,b,c); //put the minimum in the cell depending on neighbors
			d = setMat(d,i,j,min); // fill matrix d
		}
    }
	return getMat(d,n,m);
}

// Wrapper function for LD to account for a free
// inversion of the string (chromosome here)
function distance(s1, s2) {
	c1 = LD(s1,s2); c2 = LD(s1,reverseString(s2));
	return Math.min(c1, c2);
}

/******************************
 * REUSABLE TOOLBOX FUNCTIONS *
 ******************************/

// Set val in 2D matrix m at i, j indexes
function setMat(m,i,j,val) {
	m[i + j*m[0] +2] = val;
	return m;
}

// Get val in 2D matrix m at i, j indexes
function getMat(m,i,j) {
	return m[i + j*m[0] +2];
}

// Initialize 2D matrix of i x j size with val
function iniMat(i,j,val) {
	m = newArray(i*j);
	m = Array.fill(m, val);
	m = Array.concat(i,j,m);
	return m;
}

// Minimum out of 3 values
function minimum(a,b,c) {
    mi = a;
    if (b < mi) mi = b;
    if (c < mi) mi = c;
    return mi;
}

// Reverse a string
function reverseString(s) {
	A = newArray("X");
	for (i = 0; i < lengthOf(s); i++)
		A[i] = fromCharCode(charCodeAt(s, i));
	A = Array.reverse(A);
	return String.join(A, "");
}

// Concatenate cells (arrays of diffrent length)
//   Final data looks like this:
//   [number of cells][size of arrays...][data of arrays]
function concatCells(A,B) {
	// Check size and create A if empty
	lenB = parseInt(B.length);
	lenA = parseInt(A.length);
	if (lenA == 0) {
		header = newArray(1,lenB);
		dat = B;
	}
	else {
		// Get n, idx and dat from A
		n = A[0]; idx = Array.slice(A,1,n+1);
		dat = Array.slice(A,n+1);
	
		// Update n, idx and dat with new vector B
		n++; idx[n-1] = idx[n-2]+lenB;
		dat = Array.concat(dat,B);
		header = Array.concat(n,idx);
	}
	return Array.concat(header,dat);
}

// Get cells data aggregated with concatenateCells
function getCells(A,i) {
	// Get n, idx and dat from A
	n = A[0]; idx = Array.slice(A,1,n+1);
	if (i == 0) start = n + 1;
	else start = idx[i-1] + n + 1;
	end = idx[i] + n;
	B =  Array.slice(A,start,end+1);
	return B;
}

// Get a new array out of a with indexes in idx
function getSubArray(a,idx){
	b = newArray(idx.length);
	for (i = 0; i < idx.length; i++) {
		b[i] = a[idx[i]];
	}
	return b;
}

// Pad with one zero a number as string
function pad(n) {
    n = toString(n);
    if(lengthOf(n)==1) n = "0"+n;
    return n;
}

// Run only if image is opend
function ifImgRunCmd(s) {
  if (nImages>0) run(s);
}
</codeLibrary>
