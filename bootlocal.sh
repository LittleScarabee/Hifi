#!/bin/sh

# Tiny Squeeze 1.4.1 (c) 09/01/2016

varfile=/opt/var.sh

v_write(){
    sed -e "s/^$1=.*/$1=$2/" $varfile > /tmp/temp.$$
    /bin/mv -f /tmp/temp.$$ $varfile
}
source /opt/var.sh


cp -f /home/libsoxr.so.0 /lib
#cp -f /home/dsdplay /usr/lms/Bin/i386-linux

ln -s /usr/local /root/alsadir

if [ $role == player ] || [ $role == full ];then
    ln -s /home/tc/sq/writeloop /usr/bin/writeloop
    ln -s /home/tc/sq/catloop /usr/bin/catloop
    ln -s /home/tc/sq/playhrt /usr/bin/playhrt
    ln -s /usr/local/bin/aplay /usr/bin/aplay
fi

filesaves=/opt/.filetool.lst
a=$(cat $filesaves |grep -E "\/lms\/|mediaserver")

if [ $role == server ] || [ $role == full ]; then
    cp -f /home/custom-convert.conf /usr/lms/
    ln -s /home/tc/music /srv/mediaserver/music
    ln -s /home/tc/playlists /srv/mediaserver/playlists
    
    if [ -z "$a" ]; then
	cat $filesaves | sed "12i\/usr\/lms\/cache" | sed "12i\/usr\/lms\/prefs" | sed "12i\/srv\/mediaserver\/prefs">/tmp/temp.$$
	sudo /bin/mv -f /tmp/temp.$$ $filesaves
    fi
else
    if [ -n "$a" ]; then
        cat $filesaves | sed "/\/lms\//d" | sed "/mediaserver/d" >/tmp/temp.$$
    	sudo /bin/mv -f /tmp/temp.$$ $filesaves
    fi

fi

# 0. Optimize timer
echo $hpetfq > /proc/sys/dev/hpet/max-user-freq
echo $tscfq > /sys/class/rtc/rtc0/max_user_freq

ncpu=$(cat /proc/cpuinfo | grep ^processor | wc -l)
echo $ncpu >/tmp/numcpu

boot=$(cat /etc/sysconfig/backup_device | sed "s|\/tce||")
fname="/mnt/$boot/boot/syslinux/syslinux.cfg"

a=$(cat $fname | grep "isolcpus")
case $ncpu in
1) 
    sqcpu=0x01
    lmscpu=0x01
    sqoutcpu=0x01
    if [ -n "$a" ]; then
	sed -e "s|isolcpus=.*|isolcpus=|1" $fname > /tmp/temp.$$ && /bin/mv -f /tmp/temp.$$ $fname
    fi
;;
#2)  
#    sqlst="0x02 0x03"
#    if ! [[ $sqlst =~ .*$sqcpu.* ]]; then
#	sqoutcpu=0x02
#	$(v_write sqoutcpu $sqoutcpu)
#    fi
    
#    if [ -z "$a" ]; then
#	sed -e "s|^.*tinyrt\.gz|& isolcpus=1|1" $fname > /tmp/temp.$$ && /bin/mv -f /tmp/temp.$$ $fname
#    else
#	if [ -z $(echo "$a" | grep "isolcpus=1") ]; then
#	    sed -e "s|isolcpus=.* |isolcpus=1 |1" $fname > /tmp/temp.$$ && /bin/mv -f /tmp/temp.$$ $fname
#	fi
#    fi
#;;
#*)
#    if [ -z "$a" ]; then
#	sed -e "s|^.*tinyrt\.gz|& isolcpus=2,3|1" $fname > /tmp/temp.$$ && /bin/mv -f /tmp/temp.$$ $fname
#    else
#	if [ -z $(echo "$a" | grep "isolcpus=2") ]; then
#	    sed -e "s|isolcpus=.* |isolcpus=2,3 |1" $fname > /tmp/temp.$$ && /bin/mv -f /tmp/temp.$$ $fname
#	fi
#    fi
#;;
esac

# cpu mask
#3 - 1,2
#4 - 2
#5 - 1,3
#6 - 2,3
#7 - 1,2,3
#8 - 4
if [ $ncpu -eq 1 ] || [ $role == server ]; then 
    cpu2=""
    cpubr=""
    cpulms=""
else 
    if [ -n "$sqcpu" ] && [ "$sqcpu" != "0x0" ]; then
	cpu2="/usr/bin/taskset $sqcpu"
    else
	if [ $ncpu -eq 2 ]; then
	    cpu2="/usr/bin/taskset 0x02" #2
	else
	    cpu2="/usr/bin/taskset 0x08" #4
	fi
    fi
    cpubr=""
    if [ -n "$brutecpu" ] && [ "$brutecpu" != "0x0" ]; then
	cpubr="/usr/bin/taskset $brutecpu"
    fi
    cpulms=""
    if [ -n "$lmscpu" ] && [ "$lmscpu" != "0x0" ]; then
	cpulms="/usr/bin/taskset $lmscpu"
    fi
    
fi

# 1. optimize irq priority, network, scheduler

sysctl -p /etc/sysctl.conf & >/dev/null
echo 30 > /proc/sys/vm/stat_interval

if [ "$lowcpu" == "yes" ]; then
    /usr/local/bin/cpufreq-set -c 0 -f $cpufreq -r
    /usr/local/bin/cpufreq-set -c 1 -f $cpufreq -r
fi

/opt/cfq.sh $cfqset

# 2. mount local disk
/opt/bmount.sh
  
if [ $dhcp == no ]; then
    /opt/eth0.sh
else
    /usr/bin/taskset -p 0x01 $(pidof udhcpc)
    /usr/bin/taskset -p 0x01 $(pidof udevd)
fi
[ -n "$ipdns1" ] && echo "nameserver $ipdns1" > /etc/resolv.conf
[ -n "$ipdns2" ] && echo "nameserver $ipdns2" >> /etc/resolv.conf

ifconfig eth0 txqueuelen 10000

# CPU IRQ affinity
if [ "$autoirq" == "yes" ]; then
    /home/tc/rtirq_.sh start & >/dev/null
else
    # IRQ priority
    /opt/irqprio.sh
fi

# 3. acpi power off 
/usr/local/etc/init.d/acpid start & >/dev/null
# 4. start ssh-server 
[ "$sshserv" == "yes" ] && /etc/init.d/dropbear start & >/dev/null

# 5. mount netdisk
/opt/netdisk.sh
if [ $role == full ] || [ $role == server ]; then
    lf=""
    lmsprio=""
    if [ $role == full ]; then 
	lf="--localfile"  # read localfile
#    else
#	lmsprio="--priority -10"
    fi
    mysq=""
    [ $mysqueezebox == no ] && mysq="--nomysqueezebox"
    supnp=""
    [ $lmsupnp = no ] && supnp="--noupnp"
    
    [ "$srvconvert" == "yes" ] && rm -f /usr/lms/convert.conf

    chmod -R 777 /usr/lms
    chown -R root /usr/lms
    $cpulms /usr/lms/slimserver.pl --user root --daemon --novideo --charset utf8 $lf $mysq $supnp $lmsprio --nodebuglog
fi
# 6. cover art server & web-interface
    /usr/local/sbin/lighttpd -f /home/tc/lighttpd.conf & >/dev/null
# 7. alsa tweak 
/usr/bin/aplay -L >/tmp/aplay.lst
/home/tc/sq/hw_params | grep "Formats:\|rates:" >/tmp/formats
if [ $role == full ] || [ $role == player ] ; then
    if [ -n $nrpacks ]; then
        /sbin/modprobe -r snd-usb-audio
    	    /sbin/modprobe snd-usb-audio nrpacks=$nrpacks
    	/sbin/modprobe snd-aloop
    fi
#    amixer -c 0 set Master playback 100% unmute #asus 701

# 8. start squeezeslave

#change .asoundrc
#    num1=$(cat /opt/alsa/devnum)
#    card=${num1:0:1}

#    cat /home/tc/.asoundrc | sed "s/\tpcm \"hw.*/\tpcm \"hw:$num1\"/;s/card.*/card $card/" >/tmp/temp.1
#    /bin/mv -f /tmp/temp.1 /home/tc/.asoundrc

    echo "Starting Squeezeslave."

[ "$sqlog" == "yes" ] && slog="-f /home/tc/log/sqlite.log -d all=debug" || slog=""

if [ -z "$maxrate" ]; then
    rates=$(cat /tmp/formats | grep rate | head -1)
    rates=${rates#*:}
    maxrate=${rates##* }
    $(v_write maxrate $maxrate)
fi

[ "$sqpipe" != "standart" ] && resamplemode=fix
if [ "$resamplermode" == "disabled" ]; then
    srate=""
    usample=""
else
    [ "$resamplermode" == "limit" ] && srate="-r $maxrate" || srate="-r $maxrate-$maxrate"
    [ -n "$resvalue" ] && usample="-R -u $resvalue" || usample="-R" #-
fi
#    usample="-R vLs:18:3"
[ -n "$sqprio" ] && prio="-p $sqprio" || prio=""

sqname=${squeezeplayername// /}
[ $sqbuffer == auto ] && sqbuf="" || sqbuf="-b $sqbuffer:$sqoutbuffer"

if [ $sqpipe == standart ]; then
    [ "$brutefir" == "yes" ] && dev=hw:Loopback,0,0 || dev=$audiodev
    $cpu2 /home/tc/sq/$sqzlite -o $dev -n $sqname -a $sqalsa $sqbuf $srate $usample $slog $prio -z >/dev/null
    sleep 1.5
    a=$(/usr/bin/ps2 -C $sqzlite -L | tail -2 | head -1 | awk '{print $2}')
    if [ -n "$a" ]; then
	/usr/bin/renice -10 $a
	[ -n "$sqoutcpu" ] && [ "$sqoutcpu" != "0x0" ] && /usr/bin/taskset -p $sqoutcpu $a
    fi
    if [ "$brutefir" == "yes" ]; then
	brconfig=/home/tc/.brutefir_config
#	cat $brconfig | sed "/left_out/,/}/s|{ device:.*\"|{ device: \"hw:$num1\"|1" >/tmp/temp.1
	cat $brconfig | sed "/left_out/,/}/s|{ device:.*\"|{ device: \"$audiodev\"|1" >/tmp/temp.1
	/bin/mv -f /tmp/temp.1 $brconfig
	sleep 1
	$cpubr /usr/lib/brutefir/brutefir.real -nodefault $brconfig -daemon
    fi
else
    if [ -z "$format" ]; then
        formats=$(cat /tmp/formats | grep Format | head -1)
        formats=${formats#*:}
        format=${formats##* }
        $(v_write format $format)
    fi

    formatbit=32
    [ $format == S24_3LE ] && formatbit=24
    [ $format == S16_LE ] && formatbit=16
    
    mmap=""                                                                      
    if [ "$sq_mmap" == "1" ]; then                                                       
        mmap=" -M"                                                                          
    fi
    num1=$(cat /opt/alsa/devnum)
    cat /home/tc/sq/pipe_$sqpipe | sed "s/\#device/$num1/;s/\#format/$format/;s/\#rate/$maxrate/;s/\#mmap/$mmap/" >/tmp/temp.1
#    cat /home/tc/sq/pipe_$sqpipe | sed "s/\#device/$audiodev/;s/\#format/$format/" >/tmp/temp.1
#    cat /home/tc/sq/pipe_$sqpipe | sed "s/\#device/$num1/;s/\#format/$format/" >/tmp/temp.1
    /bin/mv -f /tmp/temp.1 /home/tc/sq/pipe3

    [ -n "$sqmacaddr" ] && sqmacaddr="-m $sqmacaddr" || sqmacaddr=""
    $cpu2 /home/tc/sq/$sqzlite -o - -n $sqname -a $sqalsa $sqbuf $srate $usample $slog -j /home/tc/sq/pipe3 -z
    sleep 2
    ap=$(pidof aplay)
    ah=$(pidof playhrt)
    if [ -n "$ap" ]; then
	/usr/bin/renice -10 $ap
	/usr/bin/chrt -p -f $sqprio $ap
    fi
    if [ -n "$ah" ]; then
	/usr/bin/renice -10 $ah
	/usr/bin/chrt -p -f $sqprio $ah
    fi
fi

fi #role=full || player

#13. start samba
if [ "$samba" == "yes" ]; then
    echo "Starting Samba."
    /usr/local/etc/init.d/samba start &
fi

if [ $role == naadaemon ]; then
    sleep 10
    [ -n "$sqcpu" ] && [ "$sqcpu" != "0x0" ] && /usr/bin/taskset $sqcpu /home/tc/naa/networkaudiod -D -p
fi
