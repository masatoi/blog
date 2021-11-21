(defpackage #:blog/views/root
  (:use #:cl
        #:lsx
        #:utopian)
  (:shadowing-import-from #:utopian
                          #:render-object
                          #:render)
  (:export #:index-page))
(in-package #:blog/views/root)

(named-readtables:in-readtable :lsx-syntax)

(defview index-page ()
  ()
  (:metaclass html-view-class)
  (:render
   <html>
     <head>
       <title>index | blog</title>
     </head>
     <body>
       <h1>index</h1>
     </body>
   </html>
))
