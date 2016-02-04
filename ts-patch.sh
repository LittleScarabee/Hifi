#!/bin/sh
echo "#####################"
echo "#                   #"
echo "#    Patch Tiny     #"
echo "#                   #"
echo "#####################"
echo ""
cd /tmp

echo " >> Download all files..."
echo ""
sudo /usr/local/bin/wget https://github.com/LittleScarabee/Hifi/blob/master/bootlocal.sh
sudo /usr/local/bin/wget https://github.com/LittleScarabee/Hifi/blob/master/index.yy
sudo /usr/local/bin/wget https://github.com/LittleScarabee/Hifi/blob/master/pipe_playhrt_custom
sudo /usr/local/bin/wget https://github.com/LittleScarabee/Hifi/blob/master/submit_audio.yy
echo " >> Download completed..."
echo ""

echo " >> Backup files..."
echo ""
sudo /bin/cp /home/tc/sq/pipe_playhrt /home/tc/sq/bkp.pipe_playhrt
sudo /bin/cp /opt/bootlocal.sh /opt/bkp.bootlocal.sh
sudo /bin/cp /opt/www/cgi-bin/submit_audio.yy /opt/www/cgi-bin/bkp.submit_audio.yy
sudo /bin/cp /opt/www/index.yy /opt/www/bkp.index.yy

echo " >> Replace all files..."
echo ""
sudo /bin/cp /tmp/pipe_playhrt_custom /home/tc/sq/pipe_playhrt_custom
sudo /bin/cp /tmp/bootlocal.sh /opt/bootlocal.sh
sudo /bin/cp /tmp/submit_audio.yy /opt/www/cgi-bin/submit_audio.yy
sudo /bin/cp /tmp/index.yy /opt/www/index.yy

echo " >> Apply right permissions for each files..."
echo ""
sudo /bin/chmod 755 /opt/bootlocal.sh
sudo /bin/chown root:staff /opt/bootlocal.sh
echo ""
sudo /bin/chmod 644 /home/tc/sq/pipe_playhrt_custom
sudo /bin/chown root:staff /home/tc/sq/pipe_playhrt_custom
echo ""
sudo /bin/chmod 755 /opt/www/cgi-bin/submit_audio.yy
sudo /bin/chown root:root /opt/www/cgi-bin/submit_audio.yy
echo ""
sudo /bin/chmod 755 /opt/www/index.yy
sudo /bin/chown root:root /opt/www/index.yy
