#!/usr/bin/python

import os

os.execl('/usr/local/bin/wodim', 'wodim', 'dev=/dev/hdc', 'gracetime=0', 'blank=fast')