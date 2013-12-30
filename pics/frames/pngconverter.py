import os, sys
import Image

fo = open("output.hex", "w")

def loadImg(filename):
    im = Image.open(filename + ".png")


    pix = im.load()

    width, height = im.size
    #width -=1
    #height +=1
    

    for y in xrange(0, height):
            for x in xrange(0, width):
                            currpix = pix[x,y]
                            red = currpix[0]
                            green = currpix[1]
                            blue = currpix[2]
                            reds = bin(red).lstrip("0b")
                            reds=reds[:-3]
                            while(len(reds) < 5):
                                    reds = "0" + reds
                            greens = bin(green).lstrip("0b")
                            greens = greens[:-3]
                            while(len(greens) <5):
                                    greens = "0" + greens
                            blues = bin(blue).lstrip("0b")
                            blues = blues[:-3]
                            while(len(blues)<5):
                                    blues = "0" + blues
                       # fo.write(reds + " " + greens + " " + blues + " 0" + '\n')
                            colors = reds + greens + blues + "0"
                            colorsInt = int(colors, base=2)
                            colors = hex(colorsInt).lstrip("0x")
                            if(len(colors) == 3):
                                    colors = "0" + colors
                            if(len(colors) == 2):
                                    colors = "00" + colors
                            if(len(colors) == 1):
                                    colors = "000" + colors
                            if(len(colors) == 0):
                                    colors = "0000" + colors  
                       # fo.write(str(colorsInt) + "\n")
                            fo.write(colors + "\n")
			
    #fo.write("------------------------------------------------------------")
    
loadImg("link-up-walk-1")
loadImg("link-up-walk-2")
loadImg("link-down-walk-1")
loadImg("link-down-walk-2")
loadImg("link-left-walk-1")
loadImg("link-left-walk-2")
loadImg("link-right-walk-1")
loadImg("link-right-walk-2")

loadImg("link-up-sword-2")
loadImg("link-up-sword-3")
loadImg("link-down-sword-2")
loadImg("link-down-sword-3")
loadImg("link-left-sword-2")
loadImg("link-left-sword-3")
loadImg("link-right-sword-2")
loadImg("link-right-sword-3")

loadImg("Landmark0")
loadImg("Landmark1")
loadImg("Landmark2")
loadImg("Landmark3")
loadImg("Landmark4")
loadImg("Landmark5")

loadImg("bat1")
loadImg("bat2")
loadImg("spinner1")
loadImg("spinner2")
loadImg("like1")
loadImg("like2")

for p in xrange(0, 20):
    fo.write("feea\n");
for p in xrange(0, 20):
    fo.write("8464\n");

    
fo.close()   
