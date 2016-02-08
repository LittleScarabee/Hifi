#!/bin/sh
printf "#####################\n"
printf "#  Patch Tiny 1.8   #\n"
printf "#####################\n"
printf "\n"
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
printf ">>> START Update...\n"

read -p "Do you want to update '$fileBootLocal' file ? Y/N" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  printf " >> Download all files..."
  sudo /usr/local/bin/wget $urlGitHub$fileBootLocal
  printf " >> Download completed...\n"
  printf " >> Backup files..."
  sudo /bin/cp $folderBootLocal$fileBootLocal $folderBootLocal$fileBootLocal.bkp
  printf " Done !\n"
  printf " >> Replace all files..."
  sudo /bin/cp /tmp/$fileBootLocal $folderBootLocal$fileBootLocal
  printf " Done !\n"
  printf " >> Apply right permissions for each files..."
  sudo /bin/chmod 755 $folderBootLocal$fileBootLocal
  sudo /bin/chown root:staff $folderBootLocal$fileBootLocal
  printf " Done !\n"
fi

read -p "Do you want to update '$fileIndex' file ? Y/N" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  printf " >> Download all files..."
  sudo /usr/local/bin/wget $urlGitHub$fileIndex
  printf " >> Download completed...\n"
  printf " >> Backup files..."
  sudo /bin/cp $folderIndex$fileIndex $folderIndex$fileIndex.bkp
  printf " Done !\n"
  printf " >> Replace all files..."
  sudo /bin/cp /tmp/$fileIndex $folderIndex$fileIndex
  printf " Done !\n"
  printf " >> Apply right permissions for each files..."
  sudo /bin/chmod 755 $folderIndex$fileIndex
  sudo /bin/chown root:root $folderIndex$fileIndex
  printf " Done !\n"
fi

read -p "Do you want to update '$fileSubmitAudio' file ? Y/N" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  printf " >> Download all files..."
  sudo /usr/local/bin/wget $urlGitHub$fileSubmitAudio
  printf " >> Download completed...\n"
  printf " >> Backup files..."
  sudo /bin/cp $folderSubmitAudio$fileSubmitAudio $folderSubmitAudio$fileSubmitAudio.bkp
  printf " Done !\n"
  printf " >> Replace all files..."
  sudo /bin/cp /tmp/$fileSubmitAudio $folderSubmitAudio$fileSubmitAudio
  printf " Done !\n"
  printf " >> Apply right permissions for each files..."
  sudo /bin/chmod 755 $folderSubmitAudio$fileSubmitAudio
  sudo /bin/chown root:root $folderSubmitAudio$fileSubmitAudio
  printf " Done !\n"
fi

read -p "Do you want to add '$filePlayhrt' file ? Y/N" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  printf " >> Download all files..."
  sudo /usr/local/bin/wget $urlGitHub$filePlayhrt
  printf " >> Download completed...\n"
  printf " >> Replace all files..."
  sudo /bin/cp /tmp/$filePlayhrt $folderPlayhrt$filePlayhrt
  printf " Done !\n"
  printf " >> Apply right permissions for each files..."
  sudo /bin/chmod 644 $folderPlayhrt$filePlayhrt
  sudo /bin/chown root:staff $folderPlayhrt$filePlayhrt
  printf " Done !\n"
fi

read -p "Do you want to add compatibility wit AIFF files ? Y/N" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  printf " >> Add AIF Compatibily..."
  printf "##\n" >>$fileCustomConvert
  printf "## Aif Compatibility\n" >>$fileCustomConvert
  printf "##\n" >>$fileCustomConvert
  printf "aif pcm * *\n" >>$fileCustomConvert
  printf "        -\n" >>$fileCustomConvert
  printf " Done !\n"
  printf ">>> END Update...\n"
fi
