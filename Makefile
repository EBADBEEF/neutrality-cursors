DESTDIR=out

theme: cursors.xcf-layers/Hotspots.png
	mkdir -p "$(DESTDIR)"
	cp index.theme "$(DESTDIR)"
	icon-slicer cursors.xml --output-dir "$(DESTDIR)"

cursors.xcf-layers/Hotspots.png: cursors.xcf
	mkdir -p .gimp/scripts
	cp gimp-scripts/* .gimp/scripts
	GIMP2_DIRECTORY="$(CURDIR)/.gimp" gimp -dnic cursors.xcf -b '(export-layers-as-png-noninteractive)' -b '(gimp-quit 0)'
	@echo "note: error messages from gimp are expected (cannot save data, eek memory leak)"
	rm -fr .gimp

clean:
	rm -rf cursors.xcf-layers/ .gimp

.PHONY: theme clean
