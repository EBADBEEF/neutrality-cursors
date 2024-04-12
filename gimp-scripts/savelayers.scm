(define (export-layer img layer savedir)
  (let* (
    (layername (car (gimp-layer-get-name layer)))
    (filename (string-append savedir "/" layername ".png"))
  )
    (file-png-save
      RUN-NONINTERACTIVE ; run-mode
      img                ; IMAGE
      layer              ; DRAWABLE
      filename           ; filename
      filename           ; raw-filename
      0                  ; interlace
      9                  ; compression
      0                  ; bkgd
      0                  ; gama
      0                  ; offs
      0                  ; phys
      0                  ; time
    )
  )
)

(define (export-layers-as-png img drawable savedir)
  (for-each
    (lambda (layer) (export-layer img layer savedir))
    (vector->list (cadr (gimp-image-get-layers img)))))

(define (export-layers-as-png-noninteractive)
  (let* (
    (img (aref (cadr (gimp-image-list)) 0))
    (filename (car (gimp-image-get-filename img)))
    (savedir (string-append filename "-layers/"))
  )
    (dir-make savedir)
    (export-layers-as-png img img savedir)
  )
)

(script-fu-register
  "export-layers-as-png"
  "Export Layers as PNG"
  "Exports all layers of an image as PNG files to the specified directory."
  ""
  ""
  ""
  "*"
  SF-IMAGE "Image to process" 0
  SF-DRAWABLE "Image to process" 0
  SF-DIRNAME "Where to save" ""
)

(script-fu-register
  "export-layers-as-png-noninteractive"
  "Export Layers as PNG (non-interactive)"
  "Exports all layers of the current image as PNG files in the same directory as the image."
  ""
  ""
  ""
  "*"
)

(script-fu-menu-register
  "export-layers-as-png" "<Image>/Filters")

(script-fu-menu-register
  "export-layers-as-png-noninteractive" "<Image>/Filters")
