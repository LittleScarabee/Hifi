#!/bin/sh

tce=$(cat /etc/sysconfig/backup_device)
lang=$(cat /mnt/$tce/language/default)
dir1="/mnt/$tce/language/"

source /opt/var.sh
[ "$lang" == "" ] && lang=ru

source /mnt/$tce/language/lang_$lang

cat <<EOF 
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
<meta content="yes" name="apple-mobile-web-app-capable" />
<meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
<meta content="minimum-scale=1.0, width=device-width, maximum-scale=0.6667, user-scalable=no" name="viewport" />
<link href="css/style.css" rel="stylesheet" media="screen" type="text/css" />
<script src="js/functions.js" type="text/javascript"></script>
<title>TinySqueeze Control Center
</title>
</head>

<body>
<script>
form2.role.value='';

function change_language(a){
    formr.command.value='changelang';
    formr.lang.value=a;
    document.getElementById('formr').submit();
    setTimeout(function() { window.location.href = window.location.href; },1000); 
}

function changemysq(a){
    if (a) {
	val="yes";
    }
    else {
	val="no";
    }
    formsq.mysq.value=val;
    document.getElementById('formsq').submit();
}

function changeupnp(a){
    if (a) {
	val="yes";
    }
    else {
	val="no";
    }
    formupnp.upnp.value=val;
    document.getElementById('formupnp').submit();
}

function changeconv(a){
    if (a) {
	val="yes";
    }
    else {
	val="no";
    }
    formconv.convert.value=val;
    document.getElementById('formconv').submit();
}

function changerole(a){
    var lms = document.getElementById('lmspanel');
    var lms2 = document.getElementById('lmspanel2');
    var lms3 = document.getElementById('lmspanel3');
    var lms4 = document.getElementById('lmspanel4');
    var netw = document.getElementById('netw');
    var audi = document.getElementById('audi');
    if (a == 'player' || a == 'naadaemon') {
	lms.style.display = 'none';
	lms2.style.display = 'none';
	lms3.style.display = 'none';
	lms4.style.display = 'none';
	netw.style.display = 'block';
	audi.style.display = 'block';
    }
    else {
	if (a == 'full')
	{
	    lms.style.display = 'block';
	    lms2.style.display = 'block';
	    lms3.style.display = 'block';
	    lms4.style.display = 'block';
	    netw.style.display = 'block';
	    audi.style.display = 'block';
	}
	else {
	    lms.style.display = 'block';
	    lms2.style.display = 'block';
	    lms3.style.display = 'block';
	    lms4.style.display = 'block';
	    netw.style.display = 'block';
	    audi.style.display = 'none';
	}
    }
    form2.role.value=a;
    document.getElementById('form2').submit();
}

function openlms(){
    ref="http://"+location.hostname+":9000/";
    window.open(ref,"_blank");
}

</script>
	<style>
	    #lmspanel2 span, #lmspanel3 span, #lmspanel4 span {
		font-weight:normal !important;
		}
	</style>

<div id="topbar">
	<div id="rightnav">
	<select name="lang" id="lang" onchange="change_language(this.value)" style="border:1px solid black;background:#cdd5df">
EOF

ls $dir1 | grep "lang" | while read line
do
#list files
    lcut=${line#*_}
    langfile=$(cat $dir1/$line |grep "language=")
    langname=${langfile%\"*}
    langname=${langname#*\"}
    if [ "$lcut" == "$lang" ]; then
	tsel=selected
    else
	tsel=""
    fi
    echo "<option value=\"$lcut\" $tsel>$langname</option>"
	
done
cat <<EOF
	</select>
	</div>
	<div id="title">
		TinySqueeze </div>
</div>
<div id="tributton">
	<div class="links">
		<a id="pressed" href="#">$tab1</a><a href="changelog.yy">$tab2</a><a href="about.yy">$tab3</a></div>
</div>
<style>
#imagePreloader {
    display:none;
    background:url("images/squeezebox.png") no-repeat;
    background:url("images/icon/reboot.png") no-repeat;
    background:url("images/icon/poweroff.png") no-repeat;
    background:none;
}

a {
    text-decoration:none;
}
td {
    padding:6px 0 6px 0;
}
.ramka1 {
    border-right:2px solid #ccc;
    border-bottom:2px solid #ccc;
}
.ramka2 {
    border-right:2px solid #ccc;
}
</style>
<div id="imagePreloader"></div>
<div id="content" style="max-width:630px;margin:auto;">
	<div style="width:380px;float:left;">
	<ul class="pageitem">
	    <li class="select"><select name="role" onchange="changerole(this.value);">
EOF
	tsel=""
	[ $role == full ] && tsel=selected
	echo "	<option $tsel value=\"full\">Role: LMS + Squeezebox player</option>"
	tsel=""
	[ $role == server ] && tsel=selected
	echo "	<option $tsel value=\"server\">Role: LMS server</option>"
	if [ $role == player ] || [ $role == naadaemon ]; then
	    lmsvis=none
	    cnvvis=none
	    audvis=block
	    netwvis=block
	else
	    if [ $role == full ]; then
		lmsvis=block
		audvis=block
		cnvvis=block
		netwvis=block
	    else
		lmsvis=block
		cnvvis=block
		audvis=none
		netwvis=block
	    fi
	fi
	
mycheck=""
[ "$mysqueezebox" == "yes" ] && mycheck=checked

upnpcheck=""
[ "$lmsupnp" == "yes" ] && upnpcheck=checked

convcheck=""
[ "$srvconvert" == "yes" ] && convcheck=checked

tsel=""
[ $role == player ] && tsel=selected
cat <<EOF
	<option $tsel value="player">Role: Squeezebox player</option>
EOF
tsel=
[ $role == naadaemon ] && tsel=selected
cat <<EOF
	<option $tsel value="naadaemon">Role: NAA Daemon</option>
	</select><span class="arrow"></span>
	</li>
	<li class="menu" id="lmspanel" style="display:$lmsvis;"><a class="noeffect" href="#" onclick="openlms();">
		<img src="images/squeezebox.png"/>
		<span class="name">$tlms</span></a>
	</li>
	<li class="checkbox" id="lmspanel2" style="display:$lmsvis;"><span class="name">mysqueezebox.com </span>
	<input name="mysqueezebox" type="checkbox" $mycheck onclick="changemysq(this.checked);" /> </li>
	<li class="checkbox" id="lmspanel3" style="display:$lmsvis;"><span class="name">UPnP Service </span>
	<input name="upnp" type="checkbox" $upnpcheck onclick="changeupnp(this.checked);" /> </li>
	<li class="checkbox" id="lmspanel4" style="display:$cnvvis;"><span class="name">Convert to PCM </span>
	<input name="srvconvert" type="checkbox" $convcheck onclick="changeconv(this.checked);" /> </li>
	</ul>
EOF
pathcpu=/sys/devices/platform/coretemp.0
fl=$(ls * $pathcpu/ | grep temp)
if [ -n "$fl" ]; then
cat <<EOF
	<ul class="pageitem">
	    <li class="textbox">
EOF

pathcpu=/sys/devices/platform/coretemp.0

ls * $pathcpu/ | grep temp | while read line 
do
    line1=${line#*_}
    if [ $line1 == crit ]; then
	krit=$(cat $pathcpu/$line)
	let "krit=krit/1000"
    fi
    if [ $line1 == input ]; then
	input=$(cat $pathcpu/$line)
	let "input=input/1000"
    fi
    if [ "$line1" == "label" ]; then
	label=$(cat $pathcpu/$line)
	echo "<span>$label: ${input}°C (max ${krit}°C)</span><br>"
    fi
done

cat <<EOF
	    </li>
	</ul>
EOF
fi
cat <<EOF
	</div>
	<div style="width:220px;float:left;">
	<ul class="pageitem">
		<li class="menu" id="netw" style="display:$netwvis;"><a href="network.yy"><span class="name" style="padding-left:30px;">$mnu1</span></a></li>
		<li class="menu" id="audi" style="display:$audvis;"><a href="audio.yy"><span class="name" style="padding-left:30px;">$mnu2</span></a></li>
		<li class="menu" ><a href="kernel.yy"><span class="name" style="padding-left:30px;">$mnu3</span></a></li>
		<li class="menu" ><a href="system.yy"><span class="name" style="padding-left:30px;">$mnu6</span></a></li>
	</ul>
	<script>
	    formr.command.value='';

	    function poweroff(a){
		if (a == 0) {
		    formr.command.value='reboot';
		}
		else {
		    formr.command.value='poweroff';
		}
		document.getElementById('formr').submit();
		setTimeout(function() { window.location.href = window.location.href; },300); 
		//location.reload();
	    }
	</script>
	<ul class="pageitem">
		<li class="menu" ><a class="noeffect" href="#" onclick="poweroff(0);">
		<img src="images/icon/reboot.png"/>
		<span class="name">$but2</span></a>
		</li>
		<li class="menu" ><a class="noeffect" href="#" onclick="poweroff(1);">
		<img src="images/icon/poweroff.png"/>
		<span class="name">$but3</span></a>
		</li>
	</ul>
	</div>
</div>
<form style="visibility:hidden;" id="formr" action="http://${HTTP_HOST}/cgi-bin/submit_system.yy" target="myIFR" method="GET">
	<input name="command" type="text" value="" />
	<input name="lang" type="text" value="" />
	<input name="powerbtn" type="submit" value="OK" />
</form>
<form style="visibility:hidden;" id="form2" action="http://${HTTP_HOST}/cgi-bin/submit_role.yy" target="myIFR" method="GET">
	<input name="role" type="text" value="" />
	<input name="send" type="submit" value="OK" />
</form>
<form style="visibility:hidden;" id="formsq" action="http://${HTTP_HOST}/cgi-bin/submit_role.yy" target="myIFR" method="GET">
	<input name="mysq" type="text" value="" />
	<input name="send2" type="submit" value="OK" />
</form>
<form style="visibility:hidden;" id="formupnp" action="http://${HTTP_HOST}/cgi-bin/submit_role.yy" target="myIFR" method="GET">
	<input name="upnp" type="text" value="" />
	<input name="send3" type="submit" value="OK" />
</form>
<form style="visibility:hidden;" id="formconv" action="http://${HTTP_HOST}/cgi-bin/submit_role.yy" target="myIFR" method="GET">
	<input name="convert" type="text" value="" />
	<input name="send3" type="submit" value="OK" />
</form>
<iframe name="myIFR" style="display: none"></iframe>
EOF
echo "</body>"
echo "</html>"
