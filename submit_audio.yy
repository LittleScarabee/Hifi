#!/bin/sh
cgi_getvars()
{
    [ $# -lt 2 ] && return
    local q p k v s
# get query
    case $1 in
    	GET)
	        [ ! -z "${QUERY_STRING}" ] && q="${QUERY_STRING}&"
	        echo "${QUERY_STRING}" 
    	    ;;
    esac
    shift
    s=" $* "
    # parse the query data
    while [ ! -z "$q" ]; do
    	p="${q%%&*}"  # get first part of query string
        k="${p%%=*}"  # get the key (variable name) from it
    	v="${p#*=}"   # get the value from it
        q="${q#$p&*}" # strip first part from query string
    	
        [ "$1" = "ALL" -o "${s/ $k /}" != "$s" ] && \
	    eval "$k=$v"
    done
    return
}

varfile=/opt/var.sh

v_hex() {
    binary=$1
    
    bnumber=$binary
    power=1
    while [ $binary -ne 0 ]
    do
	rem=$(expr $binary % 10)
	decimal=$((decimal+(rem*power)))
        power=$((power*2))
        binary=$(expr $binary / 10)
    done

    printf '0x%x' "$decimal"
}

v_read(){
    echo $(grep "^$1=" $varfile | sed -e "s|^$1=||")
}
v_write(){
    sed -e "s/^$1=.*/$1=$2/" $varfile > /tmp/temp.$$
    sudo /bin/mv -f /tmp/temp.$$ $varfile
}

v_write2(){
    str="cat $varfile"
    for x in $1
    do
    	pre1=$(echo $x | cut -f 1 -d ':')
        pre2=$(echo $x | cut -f 2 -d ':')
        echo $pre1 $pre2
        str=$(echo "$str | sed -e 's|^$pre1=.*|$pre1=$pre2|'")
    done
    str=$(echo $str " > /tmp/temp.$$ && sudo /bin/mv -f /tmp/temp.$$ $varfile")
    eval $str
}

#echo "${QUERY_STRING}">123.txt
# register all GET variables
cgi_getvars GET ALL

#-------- 2 Audio
boot=$(cat /etc/sysconfig/backup_device)
fname="/mnt/$boot/onboot.lst"
ncpu=$(cat /tmp/numcpu)

#player_save
if [ -n "$player_save" ]; then
    sqzlite=$(v_read sqzlite)

    audiodev=${audiodev//%3A/:}
    audiodev=${audiodev//%3D/=}
    audiodev=${audiodev//%2C/,}
    $(v_write audiodev $audiodev)
    num2=0
    
    cat /proc/asound/cards |grep "]:"| while read line; do
    fl=$(echo $line | grep "ICE1724\|"AV200"")
#    if [ -z "$fl" -a $audiodev == usb ] || [ -n "$fl" -a $audiodev == pci ] ; then
        number=${line:0:1}
        sdev=${line#*]: }
    
	echo "$number,$num2" >/opt/alsa/devnum
	echo $sdev >/opt/alsa/devname

        break
#    fi
    done

    brutefir=$(v_read brutefir)
    sudo /usr/bin/pkill brutefir.real

    sudo /usr/bin/pkill $sqzlite
    sudo /usr/bin/pkill writeloop
    sudo /usr/bin/pkill catloop
    sudo /usr/bin/pkill playhrt
    sudo /usr/bin/pkill aplay

    sleep 1.5

    sqname=$(v_read squeezeplayername)
    sqmacaddr=$(v_read sqmacaddr)
    dev=$(v_read audiodev)
    sqalsa=$(v_read sqalsa)
    sqbuffer=$(v_read sqbuffer)
    sqoutbuffer=$(v_read sqoutbuffer)
    sqprio=$(v_read sqprio)
    sqpipe=$(v_read sqpipe)
    sqlog=$(v_read sqlog)
    format=$(v_read format)
    maxrate=$(v_read maxrate)

    sqcpu=$(v_read sqcpu)
    sqoutcpu=$(v_read sqoutcpu)
    
    resamplermode=$(v_read resamplermode)
    resval=$(v_read resvalue)
    
    if [ -z "$maxrate" ]; then
	rates=$(cat /tmp/formats | grep rate | head -1)
	rates=${rates#*:}
	maxrate=${rates##* }
	$(v_write maxrate $maxrate)
    fi

    [ "$brutefir" == "yes" ] && resamplermode=fix
    
    if [ "$resamplermode" == "disabled" ]; then
	srate=""
	usample=""
    else
	[ "$resamplermode" == "limit" ] && srate="-r $maxrate" || srate="-r $maxrate-$maxrate"
	usample="-R -u $resval"
    fi
    cpu2=""
    [ -n "$sqcpu" ] && [ "$sqcpu" != "0x0" ] && cpu2="/usr/bin/taskset $sqcpu"
    [ -n "$sqprio" ] && prio="-p $sqprio" || prio=""
    [ $sqbuffer == auto ] && sqbuf="" || sqbuf="-b $sqbuffer:$sqoutbuffer"
    [ "$sqlog" == "yes" ] && slog="-f /home/tc/log/sqlite.log -d all=debug" || slog=""

    if [ $sqpipe == standart ]; then
	[ $audiodev == usb ] || [ -z "$audiodev" ] && audiodev=front
	sudo /bin/sh /home/tc/memclear.sh
	sudo $cpu2 /home/tc/sq/$sqzlite -o $audiodev -n $sqname -a $sqalsa $sqbuf $srate $usample $prio $slog -z >/dev/null
	sleep 1.5
	a=$(/usr/bin/ps2 -C $sqzlite -L | tail -2 | head -1 | awk '{print $2}')
	if [ -n "$a" ]; then
	    sudo /usr/bin/renice -10 $a
	    [ -n "$sqoutcpu" ] && [ "$sqoutcpu" != "0x0" ] && sudo /usr/bin/taskset -p $sqoutcpu $a
	fi

	if [ "$brutefir" == "yes" ]; then
	    brconfig=/home/tc/.brutefir_config
	    cat $brconfig | sed "/sampling_rate/s| .*#| $maxrate; #|1"|\
	    sed "/sample:/s| .*;| \"$format\";|g"  > /tmp/temp.1
	    sudo /bin/mv -f /tmp/temp.1 $brconfig

	    brutecpu=$(v_read brutecpu)
	    cpu2=
	    [ -n "$brutecpu" ] && [ "$brutecpu" != "0x0" ] && cpu2="/usr/bin/taskset $brutecpu"
	    sudo $cpu2 /usr/lib/brutefir/brutefir.real -nodefault /home/tc/.brutefir_config -daemon
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
#	cat /home/tc/sq/pipe_$sqpipe | sed "s/\#device/$audiodev/;s/\#format/$format/;s/\#rate/$maxrate/;s/\#mmap/$mmap/" >/tmp/temp.1
	sudo /bin/mv -f /tmp/temp.1 /home/tc/sq/pipe3

	[ -n "$sqmacaddr" ] && sqmacaddr="-m $sqmacaddr" || sqmacaddr=""
	    #sudo /usr/bin/chrt -f 60 
	sudo /bin/sh /home/tc/memclear.sh
	sudo $cpu2 /home/tc/sq/$sqzlite -o - -n $sqname $sqmacaddr -a $sqalsa $sqbuf $srate $usample $slog -j /home/tc/sq/pipe3 -z
	sleep 1.5
#	a=$(pidof $sqzlite)
#	if [ -n "$pa" ]; then
#	    sudo /usr/bin/renice -10 $pa
#	    sudo /usr/bin/chrt -p -f 95 $pa
#	fi

	pa=$(pidof aplay)
	ph=$(pidof playhrt)
	if [ -n "$pa" ]; then
	    sudo /usr/bin/renice -10 $pa
	    sudo /usr/bin/chrt -p -f $sqprio $pa
	fi
	if [ -n "$ph" ]; then
	    sudo /usr/bin/renice -10 $ph
	    sudo /usr/bin/chrt -p -f $sqprio $ph
	fi

    fi
    
fi #player_save

#atweak_save - Audio tweak save
if [ -n "$atweak_save" ]; then
    if [ -n "$alsaprio" ]; then
	if [ $alsaprio == standart ] && [ -n $(cat $fname | grep "Linux-PAM") ]; then
	    cat $fname | sed /PAM/d >/tmp/temp.$$$
	    sudo /bin/mv -f /tmp/temp.$$$ $fname
	else
	    if [ -z $(cat $fname | grep "Linux-PAM") ]; then
		cat $fname| sed "7iLinux-PAM.tcz" >/tmp/temp.$$$
		sudo /bin/mv -f /tmp/temp.$$$ $fname
	    fi
	    
	    if [ $alsaprio == high ]; then
		aprio=90
		anice=-10
	    else
		if [ $alsaprio == extreme ]; then
		    aprio=99
		    anice=-19
		else # highest
		    aprio=95
		    anice=-15
		fi
	    fi
	    ff1=/etc/security/limits.conf

	    cat $ff1 | sed "s|^.*rtprio.*|@audio - rtprio $aprio|;s|^.*nice.*|@audio - nice $anice|" >/tmp/temp.$$$
	    sudo /bin/mv -f /tmp/temp.$$$ $ff1
	fi
    fi #alsaprio
    
#    $(v_write2 "alsaperiods:$alsaperiods nrpacks:$nrpacks")
    $(v_write nrpacks $nrpacks)

    audiodev=$(v_read audiodev)
    #audiodev=$(cat /opt/alsa/devnum)

#    if [ $audiodev == usb ]; then
	$(sudo /sbin/modprobe -r snd-usb-audio)
	$(sudo /sbin/modprobe snd-usb-audio nrpacks=$nrpacks)
#    fi
fi #atweak_save

if [ -n "$sqlite_save" ]; then
    case $format in
	"S32_LE") ff=32
	;;
	"S16_LE") ff=16
	;;
	"S24_LE") ff=24
	;;
	"S24_3LE") ff=24_3
	;;
    esac
    sqalsa=$sq_alsabuf:$sq_period:$ff:$sq_mmap
#    sqalsa=$sq_alsabuf:$sq_period::$sq_mmap

    bcpu=
    for i in $(seq 1 16)
    do
	var=sqcpu$i
	eval a=\$$var
	[ $a == on ] && bcpu="1$bcpu" || bcpu="0$bcpu"
    done
    mcpu=$(v_hex $bcpu)

    bcpu=
    for i in $(seq 1 16)
    do
	var=sqoutcpu$i
	eval a=\$$var
	[ $a == on ] && bcpu="1$bcpu" || bcpu="0$bcpu"
    done
    ocpu=$(v_hex $bcpu)
    
    [ -n "$sqlog" ] && slog=yes || slog=no
    
    if [ "$sqpipe" != "standart" ]; then
	resamplermode=fix
	$(v_write brutefir no)
    fi
    
    if [ "$resamplermode" == "disabled" ]; then
	srate=""
	supsample=""
    else
       [ "$resamplermode" == "limit" ] && srate="-r $maxrate" || srate="-r $maxrate-$maxrate"

	[ -n "$rcurve" ] && scurve="s" || scurve=
	[ -n "$rasync" ] && async="X" || async=
	f1=$rquality$rphase$scurve$async

	[ $ratten -eq 1 ] && ratten=
	resval="$f1::$ratten:$rprecision"
	if [ -n "$rend" ] || [ -n "$rstop" ]; then
    	    [ -z "$rend" ] && rend=0
    	    [ -z "$rstop" ] && rstop=0
    	    if [ $rend -gt $rstop ]; then
		resval="$resval:$rstop:$rend"
	    else
		resval="$resval:$rend:$rstop"
	    fi
	    [ -n "$rphasep" ] && resval="$resval:$rphasep"
	else
	    [ -n "$rphasep" ] && resval="$resval:::$rphasep"
	fi
#	echo "$resval">err.txt
	$(v_write resvalue $resval)
	
	supsample="-R -u $resval"
    fi

    [ -z "$squeezename" ] && squeezename="TinySqueeze";
    sqmacaddr=${sqmacaddr//%3A/:}

    sqzlite=$sqversion
    $(v_write2 "sqzlite:$sqversion resamplermode:$resamplermode sqcpu:$mcpu sqoutcpu:$ocpu sqpipe:$sqpipe maxrate:$maxrate sqlog:$slog format:$format squeezeplayername:$squeezename sqmacaddr:$sqmacaddr sqbuffer:$sqbuffer sqoutbuffer:$sqoutbuffer sqprio:$sqprio")

    $(v_write sqalsa $sqalsa)

    num1=$(cat /opt/alsa/devnum)

    brutefir=$(v_read brutefir)
    sudo /usr/bin/pkill brutefir.real

    sudo /usr/bin/pkill $sqzlite
    sudo /usr/bin/pkill writeloop
    sudo /usr/bin/pkill catloop
    sudo /usr/bin/pkill playhrt
    sudo /usr/bin/pkill aplay
    sleep 2.0
    cpu2=""
    [ -n "$sqcpu" ] && [ "$sqcpu" != "0x0" ] && cpu2="/usr/bin/taskset $sqcpu"
    [ -n "$sqprio" ] && prio="-p $sqprio" || prio=""
    [ $sqbuffer == auto ] && sqbuf="" || sqbuf="-b $sqbuffer:$sqoutbuffer"
    [ "$slog" == "yes" ] && slog="-f /home/tc/log/sqlite.log -d all=debug" || slog=""

    audiodev=$(v_read audiodev)
    #audiodev=$(cat /opt/alsa/devnum)
    if [ $sqpipe == standart ]; then
        [ $audiodev == usb ] || [ -z "$audiodev" ] && audiodev=front
	sudo /bin/sh /home/tc/memclear.sh
	sudo $cpu2 /home/tc/sq/$sqzlite -o $audiodev -n $squeezename -a $sqalsa $sqbuf $srate $supsample $prio $slog -z >/dev/null
	
	sleep 1.5
	a=$(/usr/bin/ps2 -C $sqzlite -L | tail -2 | head -1 | awk '{print $2}')
	if [ -n "$a" ]; then
	    sudo /usr/bin/renice -10 $a
	    [ -n "$sqcpu" ] && [ "$sqcpu" != "0x0" ] && sudo /usr/bin/taskset -p $sqoutcpu $a
	fi
	
	if [ "$brutefir" == "yes" ]; then
	    brconfig=/home/tc/.brutefir_config
	    cat $brconfig | sed "/sampling_rate/s| .*#| $maxrate; #|1"|\
	    sed "/sample:/s| .*;| \"$format\";|g"  > /tmp/temp.1
	    sudo /bin/mv -f /tmp/temp.1 $brconfig

	    brutecpu=$(v_read brutecpu)
	    cpu2=
	    [ -n "$brutecpu" ] && [ "$brutecpu" != "0x0" ] && cpu2="/usr/bin/taskset $brutecpu"
	    sudo $cpu2 /usr/lib/brutefir/brutefir.real -nodefault /home/tc/.brutefir_config -daemon
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
#	cat /home/tc/sq/pipe_$sqpipe | sed "s/\#device/$audiodev/;s/\#format/$format/;s/\#rate/$maxrate/;s/\#mmap/$mmap/" >/tmp/temp.1
	cat /home/tc/sq/pipe_$sqpipe | sed "s/\#device/$num1/;s/\#format/$format/;s/\#rate/$maxrate/;s/\#mmap/$mmap/" >/tmp/temp.1
	sudo /bin/mv -f /tmp/temp.1 /home/tc/sq/pipe3
    
	[ -n "$sqmacaddr" ] && sqmacaddr="-m $sqmacaddr" || sqmacaddr=""
	    #sudo /usr/bin/chrt -f 60 
	sudo /bin/sh /home/tc/memclear.sh
        sudo $cpu2 /home/tc/sq/$sqzlite -o - -n $squeezename $sqmacaddr -a $sqalsa $sqbuf $srate $supsample $slog -j /home/tc/sq/pipe3 -z
	sleep 2

	pa=$(pidof aplay)
	ph=$(pidof playhrt)
	if [ -n "$pa" ]; then
	    sudo /usr/bin/renice -10 $pa
	    sudo /usr/bin/chrt -p -f $sqprio $pa
	fi
	if [ -n "$ph" ]; then
	    sudo /usr/bin/renice -10 $ph
	    sudo /usr/bin/chrt -p -f $sqprio $ph
	fi

    fi

	
fi #sqlite_save

if [ -n "$brute_save" ]; then
    sudo /usr/bin/pkill brutefir.real
    sudo /usr/bin/pkill squeezelite
    sudo /usr/bin/pkill writeloop
    sudo /usr/bin/pkill catloop
    sudo /usr/bin/pkill playhrt
    sudo /usr/bin/pkill aplay
    sleep 2

    sqzlite=$(v_read sqzlite)
    sqalsa=$(v_read sqalsa)
    sqname=$(v_read squeezeplayername)

    sqcpu=$(v_read sqcpu)
    sqoutcpu=$(v_read sqoutcpu)

    sqprio=$(v_read sqprio)
    sqlog=$(v_read sqlog)
    
    sqbuffer=$(v_read sqbuffer)
    sqoutbuffer=$(v_read sqoutbuffer)
    [ $sqbuffer == auto ] && sqbuf="" || sqbuf="-b $sqbuffer:$sqoutbuffer"
    [ "$sqlog" == "yes" ] && slog="-f /home/tc/log/sqlite.log -d all=debug" || slog=""
    
    resval=$(v_read resvalue)
    cpu2=""
    [ -n "$sqcpu" ] && [ "$sqcpu" != "0x0" ] && cpu2="/usr/bin/taskset $sqcpu"
    [ -n "$sqprio" ] && prio="-p $sqprio" || prio=""

    if [ -n "$brutefir" ]; then
	brutefir=yes

	[ -n "$powersave" ] && psave=true || psave=false
	format=$(v_read format)

	drcpath=/home/tc/music/drc/
	brconfig=/home/tc/.brutefir_config
	filterlen=${filterlen/%2C/,}
	cat $brconfig | sed "/float_bits/s| .*#| $bruteformat; #|1" |\
	   sed "/sampling_rate/s| .*#| $samplerate; #|1" |\
	   sed "/filter_length/s| .*#| $filterlen; #|1" |\
	   sed "/powersave/s| .*#| $psave; #|1" |\
	   sed "/attenuation/s| .*#| $attenuation; #|g" |\
	   sed "/sample:/s| .*;| \"$format\";|g" |\
	   sed "/left_in\"\//s| .*;| \"left_in\"\/$attenuation;|1" |\
	   sed "/right_in\"\//s| .*;| \"right_in\"\/$attenuation;|1"|\
	   sed "/drc_l/,/}/s|filename.*;|filename: \"$drcpath$filterleft\";|1"|\
	   sed "/drc_r/,/}/s|filename.*;|filename: \"$drcpath$filterright\";|1" >/tmp/temp.1
	sudo /bin/mv -f /tmp/temp.1 $brconfig

	cpu=
	for i in $(seq 1 16)
	do
	    var=brutecpu$i
	    eval a=\$$var
	    [ $a == on ] && bcpu="1$bcpu" || bcpu="0$bcpu"
	done
	mcpu=$(v_hex $bcpu)
	
	$(v_write2 "maxrate:$samplerate resamplermode:fix sqpipe:standart brutecpu:$mcpu")

#restart squeezlite
    	srate="-r $samplerate-$samplerate"
    	usample=
    	[ -n "$resval" ] && usample="-R -u $resval"
    
        spk="hw:Loopback,0,0"
	sudo /bin/sh /home/tc/memclear.sh
	sudo $cpu2 /home/tc/sq/$sqzlite -o $spk -a $sqalsa -n $sqname $sqbuf $srate $usample $prio $slog -z
        sleep 1.0
        a=$(/usr/bin/ps2 -C $sqzlite -L | tail -1 | awk '{print $2}')
        if [ -n "$a" ]; then
            sudo /usr/bin/renice -10 $a
            [ -n "$sqoutcpu" ] && [ "$sqoutcpu" != "0x0" ] && sudo /usr/bin/taskset -p $sqoutcpu $a
        fi
#start brutefir
	br=/usr/lib/brutefir/brutefir.real
	cpubr=""
	[ -n "$mcpu" ] && [ "$mcpu" != "0x0" ] && cpubr="/usr/bin/taskset $mcpu"
    	sudo $cpubr $br -nodefault $brconfig -daemon

    else
	$(v_write resamplermode:disabled)

	#audiodev=$(v_read audiodev)
	audiodev=$(cat /opt/alsa/devnum)
	[ $audiodev == usb ] && audiodev=front
	brutefir=no
	sudo /bin/sh /home/tc/memclear.sh
	sudo $cpu2 /home/tc/sq/$sqzlite -o $audiodev -a $sqalsa -n $sqname $sqbuf $prio $slog -z
        sleep 1.0
        a=$(/usr/bin/ps2 -C $sqzlite -L | tail -1 | awk '{print $2}')
        if [ -n "$a" ]; then
            sudo /usr/bin/renice -10 $a
            [ -n "$sqoutcpu" ] && [ "$sqoutcpu" != "0x0" ] && sudo /usr/bin/taskset -p $sqoutcpu $a
        fi
    fi

    $(v_write brutefir $brutefir)
fi
