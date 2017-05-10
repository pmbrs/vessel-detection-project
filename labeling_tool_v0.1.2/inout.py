#!/usr/bin/python

# Shows the frame numbers where the objects enter or leave the field of view.
# The information is retrieved from the labels contained in a label file.
#
# Version 0.1
#
# Author:
#    Ricardo Ribeiro <ribeiro@isr.ist.utl.pt>


import sys
import os
import subprocess

def main(argv):

    if len(argv) < 1 or len(argv) > 1:
        print ''
        print 'Prints a list of the frames where each object enters or leaves the field of view.'
        print ''
        print 'usage:'
        print '       inout.py labelsfile.gt.txt'
        print ''
        print 'NOTE: The temporary labels are ignored.'
        print ''
        return

    filename = argv[0]

    if not os.path.isfile(filename):
        print "ERROR: video file not found. \n(searched for file: " + filename + " )"
        return

    f = open(filename, 'r+')

    objects = []
    start = []
    stop = []


    for line in f:
        words = line.split(" ")
        frame = int(words[0])
        objectId = int(words[5])
        temp = int(words[6])
        if objectId not in objects:
            objects.append(objectId)
            start.append([frame])
            stop.append([frame])
        idx = objects.index(objectId)
        if ( not temp ):
                if ( stop[idx][-1] < frame - 1 ): ## there is a gap of frames without label - add new set
                    start[idx].append(frame)
                    stop[idx].append(frame)
                else:                              ## no gap - update exit frame number
                    stop[idx][-1] = frame


    print ""
    print filename

    for i in range(len( objects )):
        print ""
        print "ObjectId = " + str( objects[i] )
        print "\tstart\tstop\t\tframe count while in FOV"
        for j in range(len( start[i] )):
            print "\t" + str( start[i][j] ) + "\t" + str( stop[i][j] ) + "\t\t\t" + str( stop[i][j]-start[i][j]+1 )


    f.close



if __name__ == "__main__":
   main(sys.argv[1:])

