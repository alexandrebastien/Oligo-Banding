function saveJPG(ct, impath)
% saveJPG turn a color table (ct) into an image
%   Chromosomes are aligned in order of appearance and painted with colors
%   generated from the hsv lookup table, then saved as a JPG.
% USAGE:
%   saveJPG(ct, csvOut)
%   ct: color table, described in oligoPaint
%   path: path for the saved JPG

    [chromo, ~, ic] = unique(ct.Chromosome,'stable');
    stripesPerChromo = accumarray(ic,1);
    im = zeros(max(stripesPerChromo)+2,2*length(stripesPerChromo)+1);
    for chr = 1:length(chromo)
        stripes = ct.Color(ct.Chromosome == chromo(chr));
        for ii = 1:length(stripes)
            im(ii+1,2*(chr-1)+2) = stripes(ii);
        end
    end
    col = length(unique(ct.Color));
    colors = [0,0,0;hsv(col)];       
    im = imresize(ind2rgb(uint16(im),colors),16,'nearest');
    imwrite(im,impath);
end