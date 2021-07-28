title = getTitle();
run("Subtract Background...", "rolling=50");
run("Duplicate...", " ");
setOption("ScaleConversions", true);
run("8-bit");
run("Auto Local Threshold", "method=Phansalkar radius=15 parameter_1=0 parameter_2=0 white");
run("Analyze Particles...", "size=500-Infinity pixel show=Masks include in_situ");
rename("mask"); run("Duplicate...", " ");
run("Outline"); rename("outline");
