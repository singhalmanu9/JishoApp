import os;

def listFiles(dir):
    rootdir = dir
    for root, subFolders, files in os.walk(rootdir):
        for file in files:
            yield os.path.join(root,file)
    return

for f in listFiles("."):
    os.rename(f,f.lower())
    print("Renamed " + f + "to" + f.lower())
