clear;
load('C:\Users\ALBAS18\Desktop\Will\test\workspace.mat');
sb = 48; gf = 1.5;
blob = getBlob(sb,gf);
[x,y] = find(skeleton == true);
imconv = zeros(size(dapi));
val = zeros(length(x),1);

for ii = 1:length(x)
    xi = x(ii) - round(sb/2);
    xi = xi:(xi + sb - 1);
    yi = y(ii) - round(sb/2);
    yi = yi:(yi + sb - 1);
    val(ii) = mean(mean(blob .* mask(xi,yi)));
    imconv(x(ii),y(ii)) = val(ii);
end

% Show histogram and choose value
histogram(val,50);
cut = 0.14;

% Clean skeleton
skeleton(x(val < cut),y(val < cut)) = false;
imshow(skeleton)

function blob = getBlob(sb,gfilter)
    blob = zeros(sb);
    bx = 1:sb; by = 1:sb;
    cx = round(sb/2); % circle center
    cy = round(sb/2); % circle center
    r = round(sb/4); % radius 
    Mask =((bx-cx(1)).^2 + (by'-cy(1)).^2) < r^2  ; % Creating a mask
    blob(Mask) = 1; % filling the mask
    blob = imgaussfilt(blob,gfilter);
end