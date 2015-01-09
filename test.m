%  figure
%   imhist(colourIm(:,:,1),10)
%   out = anigauss(in, sigma_v, sigma_u, phi,
%     derivative_order_v, derivative_order_u);
% for i = 1: 8
%     
% 
% % imshow(c)
% [counts,bins] = hist(c(:),10);
% counts = counts / 187500;
% sum(counts)
% 
% end


% fileID = fopen('exp.txt','w');
% fprintf(fileID,'%3d %3d\n',size(blobIndIm,1),size(blobIndIm,2));
% fprintf(fileID,'%3d %3d %3d %3d\n',resultBoundingBox');
% fclose(fileID);


% 
% %109
% 
% 
% fileInfo = dir('099.jpg');
% fileSize = fileInfo.bytes / 1024 ;


shapeInserter = vision.ShapeInserter;
rectangle = int32([600,600,300,300]);
J = step(shapeInserter, im, rectangle);
figure
imshow(J); 


histSize_texture = 25;
binSize = 2 / histSize_texture;
bins = -1+binSize/2 : binSize : 1 - binSize/2;
[countsX,bin] = hist(x(:),bins);
bar(countsX)

