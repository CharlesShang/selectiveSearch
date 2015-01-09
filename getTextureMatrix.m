function [ textureM ] = getTextureMatrix(colourIm, blobBoxes, neighbours, histSize_texture)
%   getTextureMatrix, get the texture histgram of matrix of the image segmentation
%   blobBoxes: the bouding box result of the segmetation of the original image
%   neighbours: the result neighbours matrix of the segmetation
%   colourIm: the colour image 
%   output: textureM is the texture histgram of matrix of the image segmentation
%   histSize_texture: the parameter that control the size of the histogram, it
%   will refer to one chanel and one direction size,

%imshow(colourIm)
sigma = 1;
h = fspecial('gaussian', 5, sigma);
blurred = zeros(size(colourIm));
for i = 1:3
    blurred(:,:,i) = imfilter(colourIm(:,:,i),h);
end
%figure;
%imshow(blurred)

%construct the bin
binSize = 2 / histSize_texture;
bins = -1+binSize/2 : binSize : 1 - binSize/2;

textureM = zeros(length(neighbours),histSize_texture * 3 * 2);%we should have a hist for each segmentation, and each direction
%in this implementation, I use the image gradient in the x and y direction 

for j = 1:3 % for each channel
   imageChannel = blurred(:,:,j);
   for i = 1: length(neighbours)%for each segmentation
       poi = imageChannel( blobBoxes(i,1):blobBoxes(i,3),blobBoxes(i,2):blobBoxes(i,4) );
       poiSize = size(poi,1) * size(poi,2);
       
       %fprintf('%d %d\n',size(poi,1),size(poi,2));
       if size(poi,1) == 1 && size(poi,2) == 1 
           x = 0;
           y = 0;
       end
       if size(poi,1) == 1 && size(poi,2) ~= 1 
           y = zeros(size(poi));
           x = gradient(poi);
       end
       if size(poi,1) ~= 1 && size(poi,2) == 1 
           x = zeros(size(poi));
           y = gradient(poi);
       end
       if size(poi,1) ~= 1 && size(poi,2) ~= 1 
           [x,y] = gradient(poi);
       end

       [countsX,~] = hist(x(:),bins);
       [countsY,~] = hist(y(:),bins);
       countsX = countsX / (poiSize * 3 * 2);
       countsY = countsY / (poiSize * 3 * 2);
       %for x direction
       beginIndex = 1 + ((j-1) * 2 + 0) * histSize_texture;
       endIndex = histSize_texture + ((j-1) * 2 + 0) * histSize_texture;
       textureM(i,beginIndex:endIndex) = countsX;
       %for y direction
       beginIndex = 1 + ((j-1) * 2 + 1) * histSize_texture;
       endIndex = histSize_texture + ((j-1) * 2 + 1) * histSize_texture;
       textureM(i,beginIndex:endIndex) = countsY;
           
   end
end

end

