from PIL import Image
import os

def convert_white_to_transparent(img):
    image = Image.open("./assets/drawable/" + img)
    image = image.convert("RGBA")
    data = image.getdata()

    newData = []
    for rgba in data:
        if rgba[0] == 255 and rgba[1] == 255 and rgba[2] == 255:
            newData.append((255, 255, 255, 0))
        else:
            newData.append(rgba)

    image.putdata(newData)
    image.save("./assets/drawable/" + img, "PNG")
def reconvert_white(img):
    image = Image.open("./assets/drawable/" + img)
    image = image.convert("RGBA")
    data = image.getdata()

    newData = []
    for rgba in data:
        if rgba[0] == 255 and rgba[1] == 255 and rgba[2] == 255:
            newData.append((255, 255, 255, 255))
        else:
            newData.append(rgba)

    image.putdata(newData)
    image.save("./assets/drawable/" + img, "PNG")
i = 0
for filename in os.listdir("./assets/drawable"):
    i += 1
    if filename.startswith("r"):
        print(filename + " is being converted")
        convert_white_to_transparent(filename)
    elif filename.startswith("stroke"):
        reconvert_white(filename) #this exists because of an oversight
    else:
        print(filename + " IS NOT BEING CONVERTED.//////")
print ("all files were iterated over: " + str((len(os.listdir("./assets/drawable")) == i)))