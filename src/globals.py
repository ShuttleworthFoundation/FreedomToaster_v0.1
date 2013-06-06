# width, height
RESOLUTION = 1024, 768

# Directory containing the xml files describing the available isos.
# (these can be symbolic links to another directory)
ISOLISTDIR = '/isolist/'
# Where on the filesystem the ISOs are
ISOPATH = '/iso/'
# Where on the filesystem the images (to be used inside buttons) are
ISOIMAGEPATH = ISOPATH
# The file with the help, including path
HELPFILE = "help.txt"

# any more than this in ISOLISTDIR will be ignored
MAXNUMISOS = 6

# program to do the burning: wodim or cdrecord or any other compatible app
BURNINGPROGRAM = 'wodim'

# recorder
DEVICE = '/dev/hdc'
