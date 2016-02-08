#!/bin/sh
printf "#####################\n"
printf "#  Patch Tiny 1.11  #\n"
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

read -p "Do you want to update '$fileBootLocal' file ? [y/n] " 
response
echo
if [[ $response == "y" || $response == "Y" || $response == "yes" || $response == "Yes" ]]
then
  printf " >> Download all files..."
  cmd = $(sudo /usr/local/bin/wget $urlGitHub$fileBootLocal)
  echo $cmd
  eval $cmd
  printf " >> Download completed...\n"
  printf " >> Backup files..."
  cmd = $(sudo /bin/cp $folderBootLocal$fileBootLocal $folderBootLocal$fileBootLocal.bkp)
  echo $cmd
  eval $cmd
  printf " Done !\n"
  printf " >> Replace all files..."
  cmd = $(sudo /bin/cp /tmp/$fileBootLocal $folderBootLocal$fileBootLocal)
  echo $cmd
  eval $cmd
  printf " Done !\n"
  printf " >> Apply right permissions for each files..."
  cmd = $(sudo /bin/chmod 755 $folderBootLocal$fileBootLocal)
  echo $cmd
  eval $cmd
  cmd = $(sudo /bin/chown root:staff $folderBootLocal$fileBootLocal)
  echo $cmd
  eval $cmd
  printf " Done !\n"
fi

read -p "Do you want to update '$fileIndex' file ? [y/n] " 
response
echo
if [[ $response == "y" || $response == "Y" || $response == "yes" || $response == "Yes" ]]
then
  printf " >> Download all files..."
  cmd = $(sudo /usr/local/bin/wget $urlGitHub$fileIndex)
  echo $cmd
  eval $cmd
  printf " >> Download completed...\n"
  printf " >> Backup files..."
  cmd = $(sudo /bin/cp $folderIndex$fileIndex $folderIndex$fileIndex.bkp)
  echo $cmd
  eval $cmd
  printf " Done !\n"
  printf " >> Replace all files..."
  cmd = $(sudo /bin/cp /tmp/$fileIndex $folderIndex$fileIndex)
  echo $cmd
  eval $cmd
  printf " Done !\n"
  printf " >> Apply right permissions for each files..."
  cmd = $(sudo /bin/chmod 755 $folderIndex$fileIndex)
  echo $cmd
  eval $cmd
  cmd = $(sudo /bin/chown root:root $folderIndex$fileIndex)
  echo $cmd
  eval $cmd
  printf " Done !\n"
fi

read -p "Do you want to update '$fileSubmitAudio' file ? [y/n] " 
response
echo
if [[ $response == "y" || $response == "Y" || $response == "yes" || $response == "Yes" ]]
then
  printf " >> Download all files..."
  cmd = $(sudo /usr/local/bin/wget $urlGitHub$fileSubmitAudio)
  echo $cmd
  eval $cmd
  printf " >> Download completed...\n"
  printf " >> Backup files..."
  cmd = $(sudo /bin/cp $folderSubmitAudio$fileSubmitAudio $folderSubmitAudio$fileSubmitAudio.bkp)
  echo $cmd
  eval $cmd
  printf " Done !\n"
  printf " >> Replace all files..."
  cmd = $(sudo /bin/cp /tmp/$fileSubmitAudio $folderSubmitAudio$fileSubmitAudio)
  echo $cmd
  eval $cmd
  printf " Done !\n"
  printf " >> Apply right permissions for each files..."
  cmd = $(sudo /bin/chmod 755 $folderSubmitAudio$fileSubmitAudio)
  echo $cmd
  eval $cmd
  cmd = $(sudo /bin/chown root:root $folderSubmitAudio$fileSubmitAudio)
  echo $cmd
  eval $cmd
  printf " Done !\n"
fi

read -p "Do you want to add '$filePlayhrt' file ? [y/n] " 
response
echo
if [[ $response == "y" || $response == "Y" || $response == "yes" || $response == "Yes" ]]
then
  printf " >> Download all files..."
  cmd = $(sudo /usr/local/bin/wget $urlGitHub$filePlayhrt)
  echo $cmd
  eval $cmd
  printf " >> Download completed...\n"
  printf " >> Replace all files..."
  cmd = $(sudo /bin/cp /tmp/$filePlayhrt $folderPlayhrt$filePlayhrt)
  echo $cmd
  eval $cmd
  printf " Done !\n"
  printf " >> Apply right permissions for each files..."
  cmd = $(sudo /bin/chmod 644 $folderPlayhrt$filePlayhrt)
  echo $cmd
  eval $cmd
  cmd = $(sudo /bin/chown root:staff $folderPlayhrt$filePlayhrt)
  echo $cmd
  eval $cmd
  printf " Done !\n"
fi

read -p "Do you want to add compatibility wit AIFF files ? [y/n] " 
response
echo
if [[ $response == "y" || $response == "Y" || $response == "yes" || $response == "Yes" ]]
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
