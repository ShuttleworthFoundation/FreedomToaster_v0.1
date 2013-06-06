This is a good directory to have symbolic links to the actual XML files each describing an available image.

To control the order of how the images are displayed in the application give the symbolic links numbers, e.g. here the knoppix CD will be shown before the knoppix DVD:

ln -s ../iso/knoppixcd.xml ./05-knoppixcd.xml
ln -s ../iso/knoppixdvd.xml ./06-knoppixdvd.xml

To keep the location of this directory independent of the computer it's on I recommend you make a link to this directory like so:

ln -s /home/andrew/toaster/isolist /isolist

And set ISOLISTDIR in globals.py to '/isolist/'
