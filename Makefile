project=neutrality
version=$(shell date +%Y-%m-%d)-$(shell git rev-parse --short HEAD || echo "git")
theme_dir=$(CURDIR)/build/theme
gimp_dir=$(CURDIR)/build/gimp
frames_dir=$(CURDIR)/build/frames
archive_out=$(CURDIR)/build/$(project)-$(version).tar.gz

define export-script
(define img (aref (cadr (gimp-image-list)) 0)) \
(define savedir "$(frames_dir)") \
(dir-make savedir) \
(export-layers-as-png img img savedir) \
(gimp-quit 0)
endef

define make-index-theme
(echo '[Icon Theme]'; \
echo 'Name=$(project)'; \
echo 'Example=default')
endef

theme: check frames
	rm -rf "$(theme_dir)"
	mkdir -p "$(theme_dir)"
	$(make-index-theme) > "$(theme_dir)/index.theme"
	icon-slicer cursors.xml --output-dir "$(theme_dir)"

frames: check $(frames_dir)/Hotspots.png

$(frames_dir)/Hotspots.png: cursors.xcf gimp-scripts/*.scm
	mkdir -p "$(gimp_dir)/scripts"
	cp -v gimp-scripts/* "$(gimp_dir)/scripts"
	GIMP2_DIRECTORY="$(gimp_dir)" gimp-console -dnic cursors.xcf -b '$(export-script)'
	@echo "*** note: some error messages from gimp are expected (cannot save data, eek memory leak)"
	@echo "generating shadows..."
	for img in "$(frames_dir)"/Frame*.png; do \
		gegl "$$img" -o "$$img" -- gegl:long-shadow style=fading-fixed-length angle=46.00 length=3.0 midpoint=0.6 'color=rgba(0,0,0,0.7)'; \
	done
	@echo "*** note: some error messages from gegl are expected (buffer leak)"

check:
	which gimp-console && which gegl && which icon-slicer && which xcursorgen
	gegl --list-all |grep -q ^gegl:long-shadow

archive: $(archive_out)

$(archive_out): theme
	@echo version=$(version)
	tar -C "$(theme_dir)" --owner=1000 --group=1000 --transform="s:^[.]/:$(project)/:" -zcf "$(archive_out)" .

clean:
	rm -rf build

.PHONY: archive check clean frames theme
