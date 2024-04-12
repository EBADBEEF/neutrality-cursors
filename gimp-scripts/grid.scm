(define border-size '1)
(define grid-width '8)
(define grid-height '8)
(define tile-width '24)
(define tile-height '24)

; create a list of numbers
(define (range start end incr)
  (let loop ((i start) (acc '()))
    (if (>= i end)
      (reverse acc)
      (loop (+ i incr) (cons i acc)))))

(define (draw-grid-lines drawable width height step-width step-height border-size color)
  (let* ((points (cons-array 4 'double)))
    (gimp-context-push)
    (gimp-context-set-foreground color)
    (gimp-context-set-brush-size border-size)
    (for-each (lambda (x)
      (aset points 0 x)
      (aset points 1 0)
      (aset points 2 x)
      (aset points 3 height)
      (gimp-pencil drawable 4 points))
        (range (+ -1 step-width) width step-width))
    (for-each (lambda (y)
      (aset points 0 0)
      (aset points 1 y)
      (aset points 2 width)
      (aset points 3 y)
      (gimp-pencil drawable 4 points))
        (range (+ -1 step-height) height step-height))
    (gimp-context-pop)))

(define (arrange-images output-image width height cols-per-row)
  (let* (
    (input-image-ids (reverse (vector->list (cadr (gimp-image-list)))))
    (x 0)
    (y 0)
  )
  (for-each (lambda (img-id)
    (let* (
      (layer (car (gimp-image-get-active-layer img-id)))
      (new-layer (car (gimp-layer-new-from-drawable layer output-image)))
    )
      (gimp-message (string-append (number->string x) ", " (number->string y)))
      (gimp-image-add-layer output-image new-layer 0)
      (gimp-layer-translate new-layer (* x width) (* y height))
      (set! x (+ x 1))
      (when (= x cols-per-row)
        (set! x 0)
        (set! y (+ y 1)))
    )) input-image-ids
  )))

(define (images-to-grid-helper draw arrange)
  (when (not (or draw arrange))
    (error "no draw or arrange"))
  (let* (
         (grid-color '(0 0 0))
         (real-width (+ border-size tile-width))
         (real-height (+ border-size tile-height))
         (full-width (+ -1 (* grid-width real-width)))
         (full-height (+ -1 (* grid-height real-height)))
         (output-image (car (gimp-image-new full-width full-height RGB)))
         (output-layer (car (gimp-layer-new output-image (* grid-width real-width) (* grid-height real-height) RGBA-IMAGE "Grid Layer" 100 NORMAL-MODE)))
        )
    (gimp-image-insert-layer output-image output-layer 0 0)
    (when draw
      (draw-grid-lines output-layer full-width full-height real-width real-height border-size grid-color))
    (when arrange
      (arrange-images output-image real-width real-height grid-width))
    (gimp-display-new output-image)))


(define (images-to-grid) (images-to-grid-helper #t #t))
(define (draw-grid) (images-to-grid-helper #t #f))

(script-fu-register
    "draw-grid"
    "Create Grid"
    "Creates a grid pattern in a new image."
    ""
    ""
    ""
    "RGB*")

;script-fu-menu-register
; "create-grid" "<Image>/Filters")

(script-fu-register
    "images-to-grid"
    "Arrange open images in a grid pattern"
    "Create a new image and arrange all previously open images on a grid pattern."
    ""
    ""
    ""
    "RGB*")

;(script-fu-menu-registr
; "images-to-grid" "<Image>/Filters")
