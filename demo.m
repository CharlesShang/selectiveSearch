%this is the yiqing's implementation of the selevtive search algorithm

clear;clc;

addpath('Dependencies');



fprintf('  this is the yiqing implementation of the selevtive search algorithm\n');


% Compile anisotropic gaussian filter
if(~exist('anigauss'))
    fprintf('Compiling the anisotropic gauss filtering of:\n');
    mex Dependencies/anigaussm/anigauss_mex.c Dependencies/anigaussm/anigauss.c -output anigauss
end

if(~exist('mexCountWordsIndex'))
    mex Dependencies/mexCountWordsIndex.cpp
end

% Compile the code of Felzenszwalb and Huttenlocher, IJCV 2004.
if(~exist('mexFelzenSegmentIndex'))
    fprintf('Compiling the segmentation algorithm of:\n');

    mex Dependencies/FelzenSegment/mexFelzenSegmentIndex.cpp -output mexFelzenSegmentIndex;
end



% Thresholds for the Felzenszwalb and Huttenlocher segmentation algorithm.
% Note that by default, we set minSize = k, and sigma = 0.8.
k = 200; % controls size of segments of initial segmentation. 
minSize = k;
sigma = 0.8;
histSize_color = 25;% how many bins to use in a color histogram
histSize_texture = 25;% how many bins to use in a single texture histogram
% As an example, use a single image
images = {'099.jpg'};
im = imread(images{1});


%change the image to hsv color map
colourIm = rgb2hsv(im);
imageHeight = size(colourIm,1);
imageWidth = size(colourIm,2);
imageToSegment = uint8(colourIm * 255);
    
% Get initial segmentation, boxes, and neighbouring blobs
[blobIndIm blobBoxes neighbours] = mexFelzenSegmentIndex(imageToSegment, sigma, k, minSize);
originalBoxes = blobBoxes;%this is the original boxes saved after segmentation

sizeM = getSizeMatrix( blobIndIm, neighbours );
histM  = getHistMatrix( blobIndIm, neighbours, colourIm, histSize_color );
textureM = getTextureMatrix(colourIm, blobBoxes, neighbours, histSize_texture);
totalSize = size(blobIndIm,1) * size(blobIndIm,2);

similarM_size = getInitialSimilarM_size(neighbours,sizeM,totalSize);
similarM_fill = getInitialSimilarM_fill(neighbours,sizeM,totalSize,blobBoxes);
similarM_color = getInitialSimilarM_color(neighbours,histM);
similarM_texture  = getInitialSimilarM_texture( neighbours,textureM );

para_size = 1;
para_fill = 2;
para_color = 1;
para_texture = 1;
parameter_suite = [para_size,para_fill,para_color,para_texture];

resultBoundingBox = zeros(length(similarM_size) - 2,4);
index = 1;

while(length(similarM_size) > 2)
        
    [firstBlob,secondBlob] = mergeSimilarMAndFindMaxPos(similarM_size,similarM_fill,similarM_color,similarM_texture,parameter_suite);
    
    histM = mergeHistM( histM, sizeM ,firstBlob, secondBlob);%this function must be call before the merge the size matrix
    textureM  = mergeTextureM( textureM, blobBoxes ,firstBlob, secondBlob);%this function must be called before the merge of bounding box
    sizeM = mergeSizeM( sizeM, firstBlob, secondBlob );
    blobBoxes  = mergeBoudingBox( blobBoxes,firstBlob,secondBlob );
    
   
    resultBoundingBox(index,:) = blobBoxes(firstBlob,:); %this function must be called after the merge of the bounding box
    
    [similarM_size,similarM_fill,similarM_color,similarM_texture] = mergeSimilarityMatrixes(similarM_size,similarM_fill,similarM_color,similarM_texture,firstBlob,secondBlob);
    similarM_size = updateSimilarityM_size(similarM_size,firstBlob,sizeM,totalSize);
    similarM_fill = updateSimilarityM_fill(similarM_fill,blobBoxes,firstBlob,sizeM,totalSize);
    similarM_color = updateSimilarityM_color(similarM_color,histM,firstBlob);
    similarM_texture = updateSimilarityM_texture(similarM_texture,textureM,firstBlob);
    
    %at last, add the index
    index = index + 1;
end


%we also need to add the original boxes after segmentation into it
conbineResult = [originalBoxes;resultBoundingBox];

duplicateThreshold = 0.01;%this is the threshold to tell how similar should be classified as similar
conbineResult = deduplicate(conbineResult, imageHeight*duplicateThreshold, imageWidth*duplicateThreshold);

ShowRectsWithinImage(conbineResult, 5, 5, im);

 %drawBoundingboxOnImage( im, resultBoundingBox );
 %drawBoundingboxOnImageWithRandomColor( im, resultBoundingBox );
 
 imWithBoxes = drawRectangleOnImage(im, conbineResult);
 imwrite(imWithBoxes,'resultImage.jpg');
 figure;
 imshow(imWithBoxes);

drawRectangleOnDifferentImage(im,conbineResult,4);
