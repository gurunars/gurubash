sudo apt-get install mtp-tools mtpfs

#TODO: prompt to plug in the phone (wait while not)
#vendor=`mtp-detect | grep idVendor` # TODO: parse
#product=`mtp-detect | grep idProduct` # TODO: parse
#TODO: prompt to plug out the phone (wait while not)
vendor_id=04e8
product_id=685c
phone_model=GalaxyNexus

echo SUBSYSTEM==\"usb\", ATTR{idVendor}==\"$vendor_id\", ATTR{idProduct}==\"$product_id\", MODE=\"0666\" >> /etc/udev/rules.d/51-android.rules

sudo service udev restart
sudo mkdir /media/$phone_model
sudo chmod a+rwx /media/$phone_model
sudo adduser $USER fuse

# in /etc/fuse.conf uncommet user_allow_other setting
