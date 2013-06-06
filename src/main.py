#!/usr/bin/python

import gtk

import globals
import isolist
import burn

class ToasterMain:
    
    def destroy(self, widget, data=None):
        print "quitting"
        gtk.main_quit()
    
    def __init__(self):
        self.window = gtk.Window(gtk.WINDOW_TOPLEVEL)
        self.window.connect("destroy", self.destroy)
        self.window.set_default_size(globals.RESOLUTION[0], globals.RESOLUTION[1])
        self.window.show()
        
        mainvbox = gtk.VBox(False, 20)
        self.window.add(mainvbox)
        mainvbox.show()
        
        # top middle (title)
        titleLbl = gtk.Label('<span size="32000"><b>' + 'Seneca Freedom Toaster' + '</b></span>')
        titleLbl.set_use_markup(True)
        mainvbox.pack_start(titleLbl, False, False)
        titleLbl.show()
        directionsLbl = gtk.Label('<span size="12000">' + 
                                  "Touch the button for the software you're interested in." + 
                                  '</span>')
        directionsLbl.set_use_markup(True)
        mainvbox.pack_start(directionsLbl, False, False)
        directionsLbl.show()
        
        # load the list of available software
        isoList = isolist.populateIsoList()
        
        numButtonsAdded = 0
        for iso in isoList:
            # Use this condition if you want two buttons per row:
            if numButtonsAdded % 2 == 0:
            # Use this condition if you want one button per row:
            #if numButtonsAdded % 2 == 0 or numButtonsAdded % 2 == 1:
                hbox = gtk.HBox(False, 20)
                mainvbox.pack_start(hbox)
                hbox.show()
            
            # button for this software
            button = gtk.Button()
            button.connect("clicked", readyToBurnScreen, iso)
            hbox.pack_start(button, True, True)
            button.show()
            
            # This is unfortunately needed because the text in a label will not
            # wrap to the size of the parent widget so I have to resize the label 
            # manually.
            # Set the value depending on how many buttons per row you have and 
            # the size of the image.
            # For a 1024x768 window:
            # - with one column and 100px buttons: 850
            # - with two columns and 100px buttons: 350
            buttonTextWidth = 350
            populateButton(button, iso, buttonTextWidth)
            
            numButtonsAdded += 1
        
        # help button
        button = gtk.Button()
        button.connect("clicked", helpScreen)
        mainvbox.pack_start(button, True, True)
        button.show()
        
        # help button contents
        label = gtk.Label('<span size="20000"><b>Press here for help</b></span>')
        label.set_use_markup(True)
        label.show()
        button.add(label)
        
        # get rid of the mouse cursor
        #~ pix_data = """/* XPM */
        #~ static char * invisible_xpm[] = {
        #~ "1 1 1 1",
        #~ "       c None",
        #~ " "};"""
        #~ color = gtk.gdk.Color()
        #~ pix = gtk.gdk.pixmap_create_from_data(None, pix_data, 1, 1, 1, color, color)
        #~ invisible = gtk.gdk.Cursor(pix, pix, color, color, 0, 0)
        #~ gdkWindow = self.window.get_screen().get_root_window()
        #~ gdkWindow.set_cursor(invisible)
        
    def main(self):
        gtk.main()

def populateButton(button, iso, buttonTextWidth):
    hbox = gtk.HBox(False, 5)
    hbox.show()
    button.add(hbox)
    
    # picture
    image = gtk.Image()
    image.set_from_file(iso.picture)
    image.show()
    hbox.pack_start(image, False, False)
    
    # box for the name and description
    vbox = gtk.VBox(False, 5)
    vbox.show()
    hbox.pack_start(vbox, True, True)
    
    # iso name
    label = gtk.Label('<span size="20000"><b>' + iso.displayname + '</b></span>')
    label.set_use_markup(True)
    label.show()
    vbox.pack_start(label, True, True)
    
    # iso description
    label = gtk.Label('<span size="12000">' + iso.description + '</span>')
    label.set_use_markup(True)
    label.set_line_wrap(True)
    label.set_size_request(buttonTextWidth, -1)
    label.show()
    vbox.pack_start(label, True, True)
    
    return vbox, label
    
def readyToBurnScreen(button, iso):
    window = gtk.Window(gtk.WINDOW_TOPLEVEL)
    window.set_default_size(globals.RESOLUTION[0], globals.RESOLUTION[1])
    window.show()
    
    hbox = gtk.HBox(False, 5)
    window.add(hbox)
    hbox.show()
    
    # padding on the left
    fillervbox = gtk.VBox(False, 5)
    fillervbox.set_size_request(100, -1)
    hbox.pack_start(fillervbox, False, False)
    fillervbox.show()
    
    # all content goes here
    vbox = gtk.VBox(False, 5)
    hbox.pack_start(vbox, True, True)
    vbox.show()
    
    # padding on the right
    fillervbox = gtk.VBox(False, 5)
    fillervbox.set_size_request(100, -1)
    hbox.pack_start(fillervbox, False, False)
    fillervbox.show()
    
    # iso name
    label = gtk.Label('<span size="36000"><b>' + iso.displayname + '</b></span>')
    label.set_use_markup(True)
    label.show()
    vbox.pack_start(label, False, False)
    
    fillerhbox = gtk.VBox(False, 5)
    #fillerhbox.set_size_request(100, -1)
    vbox.pack_start(fillerhbox, False, False)
    fillerhbox.show()
    
    # box for iso picture and description
    hbox = gtk.HBox(False, 5)
    vbox.pack_start(hbox, False, False)
    hbox.show()
    
    # picture
    image = gtk.Image()
    image.set_from_file(iso.picture)
    image.show()
    hbox.pack_start(image, True, True)
    
    # iso description
    label = gtk.Label('<span size="12000">' + iso.longdescription + '</span>')
    label.set_use_markup(True)
    label.set_line_wrap(True)
    label.set_size_request(globals.RESOLUTION[0] - 400, -1)
    label.show()
    hbox.pack_start(label, False, False)
    
    fillerhbox = gtk.VBox(False, 5)
    fillerhbox.set_size_request(-1, 20)
    vbox.pack_start(fillerhbox, False, False)
    fillerhbox.show()
    
    if iso.type == 'CD':
        label = gtk.Label('<span size="24000"><b>Blank CD or DVD required</b></span>')
    else:
        label = gtk.Label('<span size="24000"><b>Blank DVD required</b></span>')
    label.set_use_markup(True)
    label.show()
    vbox.pack_start(label, False, False)
    
    fillerhbox = gtk.VBox(False, 5)
    fillerhbox.set_size_request(-1, 20)
    vbox.pack_start(fillerhbox, True, True)
    fillerhbox.show()
    
    button = gtk.Button()
    button.connect("clicked", burn.burn, iso.filename)
    button.set_size_request(-1, 100)
    vbox.pack_start(button, False, False)
    button.show()
    label = gtk.Label('<span size="24000"><b>' + 'Insert disk and press here to burn' + '</b></span>')
    label.set_use_markup(True)
    label.show()
    button.add(label)
    
    fillerhbox = gtk.VBox(False, 5)
    fillerhbox.set_size_request(-1, 20)
    vbox.pack_start(fillerhbox, False, False)
    fillerhbox.show()
    
    button = gtk.Button()
    button.connect("clicked", burn.closeWindowAndEjectCbk, window)
    button.set_size_request(-1, 100)
    vbox.pack_start(button, False, False)
    button.show()
    label = gtk.Label('<span size="24000"><b>' + 'Press here to go to the main menu' + '</b></span>')
    label.set_use_markup(True)
    label.show()
    button.add(label)
    
    fillerhbox = gtk.VBox(False, 5)
    fillerhbox.set_size_request(-1, 20)
    vbox.pack_start(fillerhbox, False, False)
    fillerhbox.show()

def helpScreen(button):
    window = gtk.Window(gtk.WINDOW_TOPLEVEL)
    window.set_default_size(globals.RESOLUTION[0], globals.RESOLUTION[1])
    window.show()
    
    hbox = gtk.HBox(False, 5)
    window.add(hbox)
    hbox.show()
    
    # padding on the left
    fillervbox = gtk.VBox(False, 5)
    fillervbox.set_size_request(50, -1)
    hbox.pack_start(fillervbox, False, False)
    fillervbox.show()
    
    # all content goes here
    vbox = gtk.VBox(False, 5)
    hbox.pack_start(vbox, True, True)
    vbox.show()
    
    # padding on the right
    fillervbox = gtk.VBox(False, 5)
    fillervbox.set_size_request(50, -1)
    hbox.pack_start(fillervbox, False, False)
    fillervbox.show()
    
    # BEGIN HELP contents
    helpfile = open(globals.HELPFILE, "r")
    helptext = helpfile.read()
    
    label = gtk.Label(helptext)
    label.set_use_markup(True)
    label.set_size_request(globals.RESOLUTION[0] - 200, -1)
    label.set_line_wrap(True)
    label.show()
    vbox.pack_start(label, False, False)
    # END HELP contents
    
    #~ # padding between help and close button
    #~ fillervbox = gtk.VBox()
    #~ vbox.pack_start(fillervbox, True, True)
    #~ fillervbox.show()
    
    # close button
    button = gtk.Button()
    button.connect("clicked", closeWindowCbk, window)
    button.set_size_request(-1, 100)
    vbox.pack_start(button, False, False)
    button.show()
    
    # close button contents
    label = gtk.Label('<span size="24000"><b>' + 'Press here to go to the main menu' + '</b></span>')
    label.set_use_markup(True)
    label.show()
    button.add(label)

def closeWindowCbk(button, window):
    window.destroy()

if __name__ == "__main__":
    main = ToasterMain()
    main.main()
