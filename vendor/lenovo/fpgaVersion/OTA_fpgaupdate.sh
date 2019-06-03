#! /system/bin/sh
mkdir -p /data/updateReadBack/
#init fgupdate_status 0
echo 0 > /sys/fpga_xo3r/fgupdate_status
echo 0 > /sys/fpga_xo3r/xo3rupdate_status
echo 0 > /sys/fpga_xo3l/xo3lupdate_status
update_flag=0
update_ecp5=0
update_crosslink=0
update_xo3=0
update_success=0
update_count=0

upgrade_data=$(getprop persist.FPGAUPDATE.enable)
if [ $upgrade_data -eq 1 ];
then
	echo "upgrade_data"
	mkdir /data/updateNEW/
	mkdir /data/updateOLD/
	cp /system/bin/updateNEW/* /data/updateNEW/
	cp /system/bin/updateOLD/* /data/updateOLD/
	setprop persist.FPGAUPDATE.enable 0
fi

while [ $update_success -eq 0 ] && [ $update_count -lt 3 ]
do
#compare FPGA update file
file1=/data/updateNEW/BOX_ECP5.bit
file2=/data/updateOLD/BOX_ECP5.bit

if [ -f $file1 ] && [ -f $file2 ];
then
	diff $file1 $file2 > /dev/null
	if [ $? == 0 ]; then
 	  echo "Both file are same"
	else
   	  update_flag=1
   	  echo "Both file are different"
  	  echo 1 > /sys/fpga_xo3r/fgupdate_status
  	  echo "update ECP5"
	  echo 1 > /sys/class/mtd/mtd0/device/m25p80_erase
	  sleep 5
   	  dd if=/data/updateNEW/BOX_ECP5.bit of=/dev/mtd/mtd0
  	  sleep 3
	  #Determine whether the update successful
	  echo '' > /data/updateReadBack/ECP5readback.txt
          cat /dev/mtd/mtd0 > /data/updateReadBack/ECP5readback.txt
          ECP5readback=/data/updateReadBack/ECP5readback.txt
          ECP5verify=/data/updateOLD/ECP5verify.txt
          diff $ECP5readback $ECP5verify > /dev/null
          if [ $? == 0 ]; then
 	      echo "delete OLD ECP5 file"
  	      rm -f /data/updateOLD/BOX_ECP5.bit
 	      echo "copy NEW file to OLD file"
  	      cp /data/updateNEW/BOX_ECP5.bit /data/updateOLD/
	  else
              echo "update ECP5 fail"
	      update_ecp5=1
          fi
	fi
else
    echo "$file1 or $file2 does not exist, please check filename."
fi
sleep 1

#compare CROSSLINK update file
file3=/data/updateNEW/BOX_CROSSLINK.bit
file4=/data/updateOLD/BOX_CROSSLINK.bit

if [ -f $file3 ] && [ -f $file4 ];
then
	diff $file3 $file4 > /dev/null
	if [ $? == 0 ]; then
  	   echo "Both file are same"
	else
     	   update_flag=2
 	   echo "Both file are different"
  	   echo 1 > /sys/fpga_xo3r/fgupdate_status
  	   echo "update CROSSLINK"
  	   echo 1 > /sys/class/mtd/mtd1/device/m25p80_erase
  	   sleep 5
  	   dd if=/data/updateNEW/BOX_CROSSLINK.bit of=/dev/mtd/mtd1
  	   sleep 3
	   #Determine whether the update successful
	   echo '' > /data/updateReadBack/CROSSLINKreadback.txt
           cat /dev/mtd/mtd1 > /data/updateReadBack/CROSSLINKreadback.txt
           CROSSLINKreadback=/data/updateReadBack/CROSSLINKreadback.txt
           CROSSLINKverify=/data/updateOLD/CROSSLINKverify.txt
           diff $CROSSLINKreadback $CROSSLINKverify > /dev/null
           if [ $? == 0 ]; then
 	       echo "delete OLD CROSSLINK file"
  	       rm -f /data/updateOLD/BOX_CROSSLINK.bit
 	       echo "copy NEW file to OLD file"
  	       cp /data/updateNEW/BOX_CROSSLINK.bit /data/updateOLD/
	   else
               echo "update CROSSLINK fail"
	       update_crosslink=1
           fi
	fi
else
   echo "$file3 or $file4 does not exist, please check filename."
fi
sleep 1

#compare XO3 update file
file5=/data/updateNEW/BOX_XO3.hex
file6=/data/updateOLD/BOX_XO3.hex

if [ -f $file5 ] && [ -f $file6 ];
then
	diff $file5 $file6 > /dev/null
	if [ $? == 0 ]; then
 	   echo "Both file are same"
	else
   	   update_flag=3
 	   echo "Both file are different"
 	   echo 1 > /sys/fpga_xo3r/fgupdate_status
 	   echo "update XO3"
  	   xo3update
	   sleep 3
	   #Determine whether the update successful
	   read xo3rupdate_status < /sys/fpga_xo3r/xo3rupdate_status
	   read xo3lupdate_status < /sys/fpga_xo3l/xo3lupdate_status
           if [ "$xo3rupdate_status" = "1" ] && [ "$xo3lupdate_status" = "1" ]; then
		echo "delete OLD XO3 file"
		rm -f /data/updateOLD/BOX_XO3.hex
		echo "copy NEW file to OLD file"
		cp /data/updateNEW/BOX_XO3.hex /data/updateOLD/
	   else
		echo "update XO3 fail"
		update_xo3=1
	   fi
	fi
else
   echo "$file5 or $file6 does not exist, please check filename."
fi
sleep 2

#update finished
if [ $update_flag -eq 0 ];  
then  
    update_success=1
    setprop persist.OTA_fpgaupdate.enable 0
    exit 
else
    if [ $update_ecp5 -eq 0 ] && [ $update_crosslink -eq 0 ] && [ $update_xo3 -eq 0 ]; then
        echo "update success"
        echo 2 > /sys/fpga_xo3r/fgupdate_status
	update_success=1
	setprop persist.OTA_fpgaupdate.enable 0
        exit
    else
	if [ $update_ecp5 -eq 1 ]; then
	  echo "update_ecp5 failed"
          echo 3 > /sys/fpga_xo3r/fgupdate_status
	fi
	if [ $update_crosslink -eq 1 ]; then
	  echo "update_crosslink failed"
          echo 3 > /sys/fpga_xo3r/fgupdate_status
	fi
	if [ $update_xo3 -eq 1 ]; then
	  echo "update_xo3 failed"
          echo 3 > /sys/fpga_xo3r/fgupdate_status
	fi
        let update_count+=1
	sleep 9
    fi
fi  
done

if [ $update_count -eq 3 ]; then
echo "update failed"
echo 4 > /sys/fpga_xo3r/fgupdate_status
fi
setprop persist.OTA_fpgaupdate.enable 0
