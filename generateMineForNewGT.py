from os import listdir
from os.path import isfile, join
import xml.etree.cElementTree as ET



tagset = ET.Element('tagset')

#this is the list of all the directory of result bounding boxes
#mypath = ['../icdar1003/SceneTrialTest/sml_01.08.2002/','../icdar1003/SceneTrialTest/ryoungt_13.08.2002/','../icdar1003/SceneTrialTest/ryoungt_05.08.2002/']
mypath = ['../icdar1003/SceneTrialTest/picsForNewGT/']

for ii in range(len(mypath)):

    onlyfiles = [ f for f in listdir(mypath[ii]) if isfile(join(mypath[ii],f)) ]
    onlyfiles.sort();

    for i in range(0,len(onlyfiles)):  
     
        if onlyfiles[i][-3:] == 'JPG' or onlyfiles[i][-3:] == 'jpg':
            txtName = onlyfiles[i][0:-3] + 'txt'
            if txtName not in onlyfiles:
                continue
        else:
            continue
        
        filename = mypath[ii] + onlyfiles[i][0:-3] + 'txt';
        
        fin = open(filename,'r');
        lines = fin.readlines();
        counter = 0;
        
        image = ET.SubElement(tagset,'image')
        imageName = ET.SubElement(image,'imageName')
        imageName.text = onlyfiles[i];
        taggedRectangles = ET.SubElement(image,'taggedRectangles')

        for line in lines:
            if(counter ==  0):
                counter += 1;
                continue;
            theList = line[:-1].split(' ');
            theList = filter(None,theList);
            x = int(theList[1])
            y = int(theList[0])
            height = int(theList[2]) - int(theList[0])
            width = int(theList[3]) - int(theList[1])
            taggedRectangle = ET.SubElement(taggedRectangles,'taggedRectangle');
            taggedRectangle.set('x',str(x));
            taggedRectangle.set('y',str(y));
            taggedRectangle.set('width',str(width));
            taggedRectangle.set('height',str(height));
            taggedRectangle.set('offset',"0");
            #print(theList)
            counter += 1

        
        
        
        
tree = ET.ElementTree(tagset);
tree.write('myNewResult_GT.xml')
