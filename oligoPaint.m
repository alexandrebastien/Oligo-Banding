% oligoPaint generates semi-random colors to make a chromosome barcode
%   This is used in a karyotyping experiment where chromosomes defects
%   could be spotted using spatial information from the color coding. Each
%   color blocks will be associated with fluorescent conjugated oligo
%   probes, and detect by FISH microscopy. oligoPaint will avoid pattern
%   repetitions (ex: 1,2,1,2), simple repetitions (ex: 1,1,1), symetries
%   (ex: 1,2,3,2,1) and it will maximize Levenshtein/Editor distance
%   between chromosomes.
%
% USAGE:
%   ct = oligoPaint(csvConf,csvOut)
%     read conf file (CSV), ex:
%       Chromosomes;Stripes;Colors;Optimization
%       chr1;23;6;200
%       chr2;8;;
%       ...
%     generate a color table (CSV), ex:
%       Chromosome,Color
%       chr1,2
%       chr1,5
%       ...
%     generate a JPG representation of the colored stripes
%
%   In conf file, Chromosome column is the chromosome names, Stripes is the
%   number of desired stripes for the chromosome, Colors (first row only) 
%   sets the number of diffrent colors needed, Optimization is the number 
%   of iterations to do in order to maxize the Levenshtein/Editor distance.
%   Iterations are the numbers after distance starts to decrease.

% Main function
function ct = oligoPaint(csvConf,csvOut)
    % Read CSV for configuration
    cfg = readtable(csvConf,'TextType','String');

    % Generate stripes
    ct = maximizeRandom(cfg);

    % Save output CSV
    writetable(ct,csvOut);
    
    % Save image representation of the stripes
    [filepath,name,~] = fileparts(csvOut);
    saveJPG(ct, [filepath name '.jpg']);
end

% Maximize Levenshtein/Editor distances
function ct = maximizeRandom(cfg)
    % Initial color selection
    ct = chooseRandomColors(cfg);
    d1 = sum(sum(chrDistance(ct)));
    ii = 0; jj = 0;
    while ii < cfg.Optimization(1)
        % Test a candidate and measure distance
        candidate = chooseRandomColors(cfg);
        d = sum(sum(chrDistance(candidate)));
        % Keep if distance is higher then previous iteration
        if d > d1
            d1 = d; ii = 0;
            ct = candidate;
        % Else, increment counter to until defined max attemps
        else
            ii = ii + 1;
            if ii > jj; jj = ii; end
            textwaitbar(jj,cfg.Optimization(1),'Maximizing randomness');
        end
    end
end

% Semi-random color selection
function ct = chooseRandomColors(cfg)
    chr = 1; col = cfg.Colors(1);
    % Loops on chromosome
    while chr <= length(cfg.Stripes)
        % Init. stripes for this chromosome
        stripes{chr} = zeros(cfg.Stripes(chr),1); %#ok<AGROW>
        % Loops on every stripe
        for ii = 1:cfg.Stripes(chr)
            % Loop until candidate avoid repetitions
            while true
                % Select a random color (int)
                candidate = randi(col);
                % The first one has no constraint
                if ii == 1; break;
                else
                    % Avoid simple repetitions (ex: 1,1)
                    if candidate ~= stripes{chr}(ii-1)
                        if ii >= 4
                            % Avoid pattern repetitions (ex: 1,2,1,2)
                            b = [stripes{chr}(ii-3:ii-1);candidate];
                            if ~(b(1) == b(3) && b(2) == b(4)); break; end
                        else; break;
                        end
                    end
                end
            end
            stripes{chr}(ii) = candidate;
        end
        % Avoid symetries over 80%
        if mean(flip(stripes{chr}) == stripes{chr}) <= 0.8
            chr = chr + 1; % Otherwise restart chromosome selection
        end
    end
    % Convert cell to color table for compatibility with other functions
    ct = stripesToColorTable(stripes, cfg);
end

% Convert a cell representation to color table
function ct = stripesToColorTable(stripes, cfg)
    len = sum(cellfun(@length,stripes)); jj = 1;
    chrT = strings(len,1); colT = zeros(len,1);
    for chr = 1:length(stripes)
        for ii = 1:length(stripes{chr})
            chrT(jj) = cfg.Chromosomes(chr);
            colT(jj) = stripes{chr}(ii);
            jj = jj + 1;
        end
    end
    ct = table(chrT,colT,'VariableNames',{'Chromosome','Color'});
end