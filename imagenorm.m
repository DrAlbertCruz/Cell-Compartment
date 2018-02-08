
% Sub function for normalizing the image
function outimage = imagenorm( image )
image = double( image );
outimage = image - min(min( image ));
if max(max( outimage )) ~= 0
    outimage = outimage ./ max(max( outimage ));
end
end