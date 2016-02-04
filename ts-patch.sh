#!/bin/sh
echo "#####################"
echo "#                   #"
echo "#    Patch Tiny     #"
echo "#                   #"
echo "#####################"
echo ""
folderPlayhrt="/home/tc/sq/"
folderBootLocal="/opt/"
folderSubmitAudio="/opt/www/cgi-bin/"
folderIndex="/opt/www/"

filePlayhrt="pipe_playhrt_custom"
fileBootLocal="bootlocal.sh"
fileSubmitAudio="submit_audio.yy"
fileIndex="index.yy"

urlGitHub="https://github.com/LittleScarabee/Hifi/blob/master/"

cd /tmp

echo " >> Download all files..."
echo ""
sudo /usr/local/bin/wget $urlGitHub$fileBootLocal
sudo /usr/local/bin/wget $urlGitHub$fileIndex
sudo /usr/local/bin/wget $urlGitHub$filePlayhrt
sudo /usr/local/bin/wget $urlGitHub$fileSubmitAudio
echo " >> Download completed..."
echo ""

echo " >> Backup files..."
echo ""
sudo /bin/cp $folderBootLocal$fileBootLocal $folderBootLocal$fileBootLocal.bkp
sudo /bin/cp $folderSubmitAudio$fileSubmitAudio $folderSubmitAudio$fileSubmitAudio.bkp
sudo /bin/cp $folderIndex$fileIndex $folderIndex$fileIndex.bkp

echo " >> Replace all files..."
echo ""
sudo /bin/cp /tmp/$filePlayhrt $folderPlayhrt$filePlayhrt
sudo /bin/cp /tmp/$fileBootLocal $folderBootLocal$fileBootLocal
sudo /bin/cp /tmp/$fileSubmitAudio $folderSubmitAudio$fileSubmitAudio
sudo /bin/cp /tmp/$fileIndex $folderIndex$fileIndex

echo " >> Apply right permissions for each files..."
echo ""
sudo /bin/chmod 755 $folderBootLocal$fileBootLocal
sudo /bin/chown root:staff $folderBootLocal$fileBootLocal
echo ""
sudo /bin/chmod 644 $folderPlayhrt$filePlayhrt
sudo /bin/chown root:staff $folderPlayhrt$filePlayhrt
echo ""
sudo /bin/chmod 755 $folderSubmitAudio$fileSubmitAudio
sudo /bin/chown root:root $folderSubmitAudio$fileSubmitAudio
echo ""
sudo /bin/chmod 755 $folderIndex$fileIndex
sudo /bin/chown root:root $folderIndex$fileIndex
