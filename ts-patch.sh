#!/bin/sh
printf "#####################"
printf "#  Patch Tiny 1.6   #"
printf "#####################"
printf ""
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
printf ">>> START Update..."
printf " >> Download all files..."
sudo /usr/local/bin/wget $urlGitHub$fileBootLocal
sudo /usr/local/bin/wget $urlGitHub$fileIndex
sudo /usr/local/bin/wget $urlGitHub$filePlayhrt
sudo /usr/local/bin/wget $urlGitHub$fileSubmitAudio
printf " >> Download completed..."

printf " >> Backup files..."
sudo /bin/cp $folderBootLocal$fileBootLocal $folderBootLocal$fileBootLocal.bkp
sudo /bin/cp $folderSubmitAudio$fileSubmitAudio $folderSubmitAudio$fileSubmitAudio.bkp
sudo /bin/cp $folderIndex$fileIndex $folderIndex$fileIndex.bkp
printf " >> Done !"
printf " >> Replace all files..."
sudo /bin/cp /tmp/$filePlayhrt $folderPlayhrt$filePlayhrt
sudo /bin/cp /tmp/$fileBootLocal $folderBootLocal$fileBootLocal
sudo /bin/cp /tmp/$fileSubmitAudio $folderSubmitAudio$fileSubmitAudio
sudo /bin/cp /tmp/$fileIndex $folderIndex$fileIndex
printf " >> Done !"
printf " >> Apply right permissions for each files..."
sudo /bin/chmod 755 $folderBootLocal$fileBootLocal
sudo /bin/chown root:staff $folderBootLocal$fileBootLocal
sudo /bin/chmod 644 $folderPlayhrt$filePlayhrt
sudo /bin/chown root:staff $folderPlayhrt$filePlayhrt
sudo /bin/chmod 755 $folderSubmitAudio$fileSubmitAudio
sudo /bin/chown root:root $folderSubmitAudio$fileSubmitAudio
sudo /bin/chmod 755 $folderIndex$fileIndex
sudo /bin/chown root:root $folderIndex$fileIndex
printf " >> Done !"
printf " >> Add AIF Compatibily..."
printf "##" >>$fileCustomConvert
printf "## Aif Compatibility" >>$fileCustomConvert
printf "##" >>$fileCustomConvert
printf "aif pcm * *" >>$fileCustomConvert
printf "        -" >>$fileCustomConvert
printf " >> Done !"
printf ">>> END Update..."
