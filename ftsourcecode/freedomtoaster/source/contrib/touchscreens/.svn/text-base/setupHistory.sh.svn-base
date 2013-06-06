#!/bin/sh

echo "Getting egalax driver files"
if [ ! -d /home/kiosk-admin/Download ]; then
   mkdir /home/kiosk-admin/Download
fi
DRIVER=$(echo `pwd`/$0 | sed 's#/[^/]*$##')
if [ ! -f $DRIVER/?buntu*.tar.gz ]; then
   cd /home/kiosk-admin/Download
   wget 'http://www.egalax.com.tw/drivers/(K)Ubuntu/?buntu*.tar.gz'
else
   cp $DRIVER/?buntu*.tar.gz /home/kiosk-admin/Download/
fi

echo "Busy setting up kernel source"
apt-get install linux-source
cd /usr/src
tar -xjf linux-source-*.tar.bz2
KERNELSOURCEVERSION=$(find ./ -type d -name "linux-source-*" | sort | tail -n 1)
LIBRARYVERSION=$(uname -r)
ln -s /usr/src/$KERNELSOURCEVERSION /lib/modules/$LIBRARYVERSION/build
cd /usr/src/$KERNELSOURCEVERSION
make oldconfig > /dev/null
make scripts > /dev/null

echo "Installing ubuntu egalax driver"
cd /home/kiosk-admin/Download
tar -zxf ?buntu*.tar.gz
cd touchkit/include/
make new
cd ..
sed -i 's#/lib/modules/$LIBRARYVERSION/build#/usr/src/$KERNELSOURCEVERSION#' usb/Makefile
make all > /dev/null
make install

/etc/init.d/rc.local restart
echo "The browser will now start. To return to this script press ctl-F1"
echo "You will need to press ctl-F7 to switch to the graphical screen again to run the 4-point calibration."
/etc/init.d/freedom-toaster-x restart
sleep 5
export DISPLAY=:0.0;touchcfg 

