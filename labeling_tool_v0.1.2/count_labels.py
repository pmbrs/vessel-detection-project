#!/usr/bin/python

# Counts the number of labels contained in a label file.
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
        print 'usage:'
        print '       count_labels.py labelsfile.gt.txt'
        return

    filename = argv[0]
    filename_video = os.path.splitext( os.path.splitext(filename)[0] )[0] + ".avi"

    video_frame_count = -1

    if os.path.isfile(filename_video):
        out = subprocess.check_output(["mediainfo", "--Inform=Video;%FrameCount% ", filename_video ])
        #subprocess.call(["mediainfo", "--Inform=Video;%FrameCount% ", filename_video ], stdout=out )
        video_frame_count = int(out)
        #print "Total video frame count: " + str(out)
    else:
        print "WARNING: video file not found. Could not determine the video frame count. (searched for file: " + filename_video + " )"





    f = open(filename, 'r+')

    objects = []
    counts = []
    counts_temp = []
    frames = []

    for line in f:
        words = line.split(" ")
        frame = int(words[0])
        objectId = int(words[5])
        temp = int(words[6])
        if objectId not in objects:
            objects.append(objectId)
            counts.append(0)
            counts_temp.append(0)
        if frame not in frames:
            frames.append(frame)
        idx = objects.index(objectId)
        if (temp):
            counts_temp[idx] += 1
        else:
            counts[idx] += 1


    if video_frame_count >= 0 :
        print "Number of video frames: " + str(video_frame_count)
    print "Number of frames containing labels: " + str(len(frames))
    print "Number of objects: " + str(len(objects))
    print "---------------------------------------------------------------------"
    print "ObjectId\t|\tnumber of labels"
    print "\t\t|\tfinal\t\ttemporary\ttotal"
    print "---------------------------------------------------------------------"
    for objectId in objects:
        idx = objects.index(objectId)
        print "    " + str(objectId) + "\t\t|\t" + str(counts[idx]) + "\t\t" + str(counts_temp[idx]) + "\t\t" + str( counts[idx] + counts_temp[idx] )
    print "---------------------------------------------------------------------"
    print "Total:\t\t|\t" + str(sum(counts)) + "\t\t" + str(sum(counts_temp)) + "\t\t" + str(sum(counts)+sum(counts_temp))
    print "---------------------------------------------------------------------"
    

    f.close



if __name__ == "__main__":
   main(sys.argv[1:])

