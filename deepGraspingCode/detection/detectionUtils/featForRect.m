% Extracts features for the given axis-aligned rectangle in the given set
% of color, depth, and normal images.
%
% Author: Ian Lenz

function [feat, mask] = featForRect(I,D,N,DMask,r,c,h,w,featSz,maskThresh)

% Extract region from each input image
I = I(r:r+h-1,c:c+w-1,:);
D = D(r:r+h-1,c:c+w-1,:);
N = N(r:r+h-1,c:c+w-1,:);
DMask = DMask(r:r+h-1,c:c+w-1,:);

% Scale and pad depth channel and mask
[D,DMask] = padMaskedImage2(D,DMask,featSz,featSz);

DMask = DMask > maskThresh;

% Scale and pad normal channel
[N,~] = padImage(N,featSz,featSz);

% Mask depth and normal channels again
D = D.*DMask;

N = bsxfun(@times,N,DMask);

% Scale and pad color channels
[I,IMask] = padImage(I,featSz,featSz);
IMask = IMask > maskThresh;
I = bsxfun(@times,I,IMask);

% Re-range the YUV image. Just scale the Y channel to the [0,1] range.
% The version of yuv2rgb used here gives values in the [-128,128] range, so
% scale that to the [-1,1] range (but keep some values negative since this
% is more natural for the U and V components)
I(:,:,1) = I(:,:,1)/255;
I(:,:,2) = I(:,:,2)/128;
I(:,:,3) = I(:,:,3)/128;

% Scale the depth data by its std since we do this per-case. Other
% whitening is assumed to be done elsewhere.
[D,~] = caseWiseWhiten(D,DMask);

feat = [D(:); I(:); N(:)]';

if nargout > 1
    mask = [DMask(:); repmat(IMask(:),3,1); repmat(DMask(:),3,1)]';
end