DESTDIR=$(CURDIR)/build/theme
gimp_dir=$(CURDIR)/build/gimp
frames_dir=$(CURDIR)/build/frames

define export-script
(define img (aref (cadr (gimp-image-list)) 0)) \
(define savedir "$(frames_dir)") \
(dir-make savedir) \
(export-layers-as-png img img savedir) \
(gimp-quit 0)
endef

theme: frames
	mkdir -p "$(DESTDIR)"
	cp index.theme "$(DESTDIR)"
	icon-slicer cursors.xml --output-dir "$(DESTDIR)"

frames: $(frames_dir)/Hotspots.png

$(frames_dir)/Hotspots.png: cursors.xcf gimp-scripts/*.scm
	mkdir -p "$(gimp_dir)/scripts"
	cp -v gimp-scripts/* "$(gimp_dir)/scripts"
	GIMP2_DIRECTORY="$(gimp_dir)" gimp -dnic cursors.xcf -b '$(export-script)'
	@echo "*** note: error messages from gimp are expected (cannot save data, eek memory leak)"
	@echo "generating shadows..."
	for img in "$(frames_dir)"/Frame*.png; do \
		gegl "$$img" -o "$$img" -- gegl:long-shadow style=fading-fixed-length angle=46.00 length=3.0 midpoint=0.6 'color=rgba(0,0,0,0.7)'; \
	done

clean:
	rm -rf build

.PHONY: clean frames theme
