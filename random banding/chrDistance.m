function d = chrDistance(ct)
% chrDistance compute the Levenshtein/Editor distance
%   It compute the distance for each pair of unique chromosome listed in
%   the input table. Input should have a Chromosome and a Color field.
%
% USAGE:
%   d = chrDistance(ct)
%   ct: color table, described in oligoPaint
%   d: N x N array
%      N is the number unique chromosome in ct in order of appearance

    chr = unique(ct.Chromosome,'stable');
    toChar = @(x) char(x+48); len = length(chr);
    d = zeros(len);
    for ii = 1:len
        for jj = 1:len
            str1 = toChar(ct.Color(ct.Chromosome == chr(ii))');
            str2 = toChar(ct.Color(ct.Chromosome == chr(jj))');
            temp = strdist(str1,str2,2);
            d(ii,jj) = temp(2);
        end
    end
end