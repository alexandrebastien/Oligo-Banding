# Oligo-Banding
This is the repository for all software and scripts described in (publication in progress). This publication describes a new technique to simplify and automatize karyotyping based on oligo-banding, a semi-random color barcode for chromosomes.

## randomBanding
This is a Matlab(R) function that generates semi-random colors to make a chromosome barcode. This is used in a karyotyping experiment where chromosomes defects could be spotted using spatial information from the color coding. Each color blocks will be associated with fluorescent conjugated oligo probes and detected by FISH microscopy. randomBanding will avoid pattern repetitions (ex: 1,2,1,2), simple repetitions (ex: 1,1,1), symmetries (ex: 1,2,3,2,1) and it will maximize Levenshtein/Editor distance between chromosomes.

<img src="https://github.com/alexandrebastien/oligoPaint/blob/main/example/stripes.jpg" width="200">

## Usage
`ct = randomBanding(csvConf,csvOut)`
- read conf file (example/config.csv)
- generate a color table (example/stripes.csv)
- generate an image of the colored stripes (example/stripes.jpg)

## Parameters in config.csv
- Chromosome: chromosome names
- Stripes: number of desired stripes for the chromosome
- Colors (first row only): number of different colors needed
- Optimization: number of iterations to do to maximize the Levenshtein/Editor distance.
