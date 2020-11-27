# oligoPaint
generates semi-random colors to make a chromosome barcode

This is used in a karyotyping experiment where chromosomes defects could be spotted using spatial information from the color coding. Each color blocks will be associated with fluorescent conjugated oligo probes, and detect by FISH microscopy. oligoPaint will avoid pattern repetitions (ex: 1,2,1,2), simple repetitions (ex: 1,1,1), symetries (ex: 1,2,3,2,1) and it will maximize Levenshtein/Editor distance between chromosomes.

## Usage
`ct = oligoPaint(csvConf,csvOut)`
- read conf file (example/config.csv)
- generate a color table (example/stripes.csv)
- generate an image of the colored stripes (example/stripes.jpg)

## Parameters in config.csv
- Chromosome: chromosome names
- Stripes: number of desired stripes for the chromosome
- Colors (first row only): number of diffrent colors needed
- Optimization: number of iterations to do in order to maximize the Levenshtein/Editor distance.
