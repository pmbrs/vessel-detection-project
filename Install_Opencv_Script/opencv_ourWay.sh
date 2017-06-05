sudo apt-get autoremove libopencv-dev python-opencv
sudo apt-get update
sudo apt-get upgrade
sudo apt-get dist-upgrade
#sudo apt-get autoremove

cd ~/Downloads
echo "Installing OpenCV 2.4.13.2"
mkdir OpenCV
cd OpenCV


#----------Way #0 of installing dependencies
sudo apt-get install build-essential
sudo apt-get install cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev
sudo apt-get install python-dev python-numpy libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libdc1394-22-dev

#----------Way #1 of installing dependencies
#---first block not needed
# sudo apt-get install build-essential cmake qt5-default libvtk6-dev zlib1g-dev libjpeg-dev libwebp-dev libpng-dev libtiff5-dev libjasper-dev libopenexr-dev libgdal-dev libdc1394-22-dev libavcodec-dev libavformat-dev libswscale-dev libtheora-dev libvorbis-dev libxvidcore-dev libx264-dev yasm libopencore-amrnb-dev libopencore-amrwb-dev libv4l-dev libxine2-dev libtbb-dev libeigen3-dev ant default-jdk doxygen
# cd ~/Downloads
# echo "Installing OpenCV 2.4.2"
# mkdir OpenCV
# cd OpenCV

#-----------------------installing dependencies
# echo "Removing any pre-installed ffmpeg and x264"
# sudo apt-get remove ffmpeg x264 libx264-dev
# echo "Installing Dependenices"
# sudo apt-get install libopencv-dev
# sudo apt-get install build-essential checkinstall cmake pkg-config yasm
# sudo apt-get install libtiff4-dev libjpeg-dev libjasper-dev
# sudo apt-get install libavcodec-dev libavformat-dev libswscale-dev libdc1394-22-dev libxine-dev libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev libv4l-dev
# sudo apt-get install python-dev python-numpy
# sudo apt-get install libtbb-dev
# sudo apt-get install libqt4-dev libgtk2.0-dev
# echo "Downloading x264"
# wget ftp://ftp.videolan.org/pub/videolan/x264/snapshots/x264-snapshot-20120528-2245-stable.tar.bz2
# tar -xvf x264-snapshot-20120528-2245-stable.tar.bz2
# cd x264-snapshot-20120528-2245-stable/
# echo "Installing x264"
# if [ $flag -eq 1 ]; then
# ./configure --enable-static
# else
# ./configure --enable-shared --enable-pic
# fi
# make
# sudo make install
# cd ..
# echo "Downloading ffmpeg"
# wget http://ffmpeg.org/releases/ffmpeg-0.11.1.tar.bz2
# echo "Installing ffmpeg"
# tar -xvf ffmpeg-0.11.1.tar.bz2
# cd ffmpeg-0.11.1/
# if [ $flag -eq 1 ]; then
# ./configure --enable-gpl --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libvorbis --enable-libx264 --enable-libxvid --enable-nonfree --enable-postproc --enable-version3 --enable-x11grab
# else
# ./configure --enable-gpl --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libvorbis --enable-libx264 --enable-libxvid --enable-nonfree --enable-postproc --enable-version3 --enable-x11grab --enable-shared
# fi
# make
# sudo make install
# cd ..
# echo "Downloading v4l"
# wget http://www.linuxtv.org/downloads/v4l-utils/v4l-utils-0.8.8.tar.bz2
# echo "Installing v4l"
# tar -xvf v4l-utils-0.8.8.tar.bz2
# cd v4l-utils-0.8.8/
# make
# sudo make install
# cd ..

#----------------------installing opencv
echo "Downloading OpenCV 2.4.13.2"
wget -O OpenCV-2.4.13.2.tar.gz https://github.com/opencv/opencv/archive/2.4.13.2.tar.gz
echo "Installing OpenCV 2.4.13.2"
tar -xvf OpenCV-2.4.13.2.tar.gz
cd openCV-2.4.13.2



mkdir build
cd build

cmake -DWITH_QT=ON -DWITH_OPENGL=ON -DFORCE_VTK=ON -DWITH_TBB=ON -DWITH_GDAL=ON -DWITH_XINE=ON -DBUILD_EXAMPLES=ON /home/asus/Downloads/OpenCV/opencv-2.4.13.2

make -j7

sudo make install

sudo ldconfig
echo "-------End of Script"