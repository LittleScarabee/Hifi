#!/bin/sh
echo "#####################"
echo "#  Patch Tiny 1.6   #"
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

fileCustomConvert="/home/custom-convert.conf"

urlGitHub="https://raw.githubusercontent.com/LittleScarabee/Hifi/master/"

cd /tmp
echo ">>> START Update..."
echo " >> Download all files..."
sudo /usr/local/bin/wget $urlGitHub$fileBootLocal
sudo /usr/local/bin/wget $urlGitHub$fileIndex
sudo /usr/local/bin/wget $urlGitHub$filePlayhrt
sudo /usr/local/bin/wget $urlGitHub$fileSubmitAudio
echo " >> Download completed..."

echo " >> Backup files..."
sudo /bin/cp $folderBootLocal$fileBootLocal $folderBootLocal$fileBootLocal.bkp
sudo /bin/cp $folderSubmitAudio$fileSubmitAudio $folderSubmitAudio$fileSubmitAudio.bkp
sudo /bin/cp $folderIndex$fileIndex $folderIndex$fileIndex.bkp
echo -e "Done !"
echo " >> Replace all files..."
sudo /bin/cp /tmp/$filePlayhrt $folderPlayhrt$filePlayhrt
sudo /bin/cp /tmp/$fileBootLocal $folderBootLocal$fileBootLocal
sudo /bin/cp /tmp/$fileSubmitAudio $folderSubmitAudio$fileSubmitAudio
sudo /bin/cp /tmp/$fileIndex $folderIndex$fileIndex
echo -e "Done !"
echo " >> Apply right permissions for each files..."
sudo /bin/chmod 755 $folderBootLocal$fileBootLocal
sudo /bin/chown root:staff $folderBootLocal$fileBootLocal
sudo /bin/chmod 644 $folderPlayhrt$filePlayhrt
sudo /bin/chown root:staff $folderPlayhrt$filePlayhrt
sudo /bin/chmod 755 $folderSubmitAudio$fileSubmitAudio
sudo /bin/chown root:root $folderSubmitAudio$fileSubmitAudio
sudo /bin/chmod 755 $folderIndex$fileIndex
sudo /bin/chown root:root $folderIndex$fileIndex
echo -e "Done !"
echo " >> Add AIF Compatibily..."
echo "##" >>$fileCustomConvert
echo "## Aif Compatibility" >>$fileCustomConvert
echo "##" >>$fileCustomConvert
echo "aif pcm * *" >>$fileCustomConvert
echo "        -" >>$fileCustomConvert
echo -e "Done !"
echo ">>> END Update..."
