# This Makefile is currently only used by the debian packaging system
# don't use it for anything else 

HTMLDIR = /srv/www/kiosk
CGIDIR = $(HTMLDIR)/cgi-bin
ISODIR = $(DESTDIR)/srv/isos

build:
	$(MAKE) -C po/ translations

install:
# www and iso directories
	install --directory $(ISODIR) $(DESTDIR)$(HTMLDIR) $(DESTDIR)$(CGIDIR)
	svn export --force kiosk/ $(DESTDIR)$(HTMLDIR)
	svn export --force isos/ $(ISODIR)
	chown -R www-data: $(DESTDIR)$(HTMLDIR)
	chown -R www-data: $(ISODIR)
#	install --owner=www-data kiosk/* $(HTMLDIR)

# apache2 config
	sed -e "s%@@HTMLDIR@@%$(HTMLDIR)%g" \
	  -e "s%@@CGIDIR@@%$(CGIDIR)%g" \
	  ./virtualhost.in > $(DESTDIR)/etc/apache2/sites-available/freedomtoaster
	ln -fs ../sites-available/freedomtoaster $(DESTDIR)/etc/apache2/sites-enabled/freedomtoaster
# not for package creation, done in postinst script
	if [ -z $(DESTDIR) ]; then \
		if ! grep -q freedomtoaster.localdomain /etc/hosts 2> /dev/null; then \
			cp $(DESTDIR)/etc/hosts $(DESTDIR)/etc/~hosts; \
			sed -e "s%^\(127\.0\.0\.1.*\)$%\1 freedomtoaster\.localdomain freedomtoaster%g" /etc/hosts > /etc/hosts; \
		fi \
	fi

# launch SetupScript here?
#	./SetupScript

.PHONY : clean
clean:
