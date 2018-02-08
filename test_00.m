addpath C:\albert_cruz\images\ilvasdata\set-2\WT\20X\
I = imread( 'Acquired.tif' );

% Pre-processing

I = imresize( I, [NaN 500] );
f = fspecial( 'gaussian', [7 7] );
Is = imfilter(double(I), f, 'replicate');
figure, imshow(Is,[]), title('Smoothed image');

hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(Is), hy, 'replicate');
Ix = imfilter(double(Is), hx, 'replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);
figure, imshow(gradmag,[]), title('Gradient magnitude (gradmag)');

gradmag = uint8( imnorm( gradmag ) * 255 );

Ibw = im2bw( double(gradmag), graythresh( double(gradmag) ) );
imshow( Ibw, [] )
% a = WATERSHED( Io );