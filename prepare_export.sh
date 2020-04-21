#!/bin/sh

(cd export/windows; zip ls20-windows.zip *; mv ls20-windows.zip ../)
(cd export/linux; zip ls20-linux.zip *; mv ls20-linux.zip ../)
(cd export/mac; mv ls20.zip ../ls20-mac.zip)
(cd export/web; zip ls20-web.zip *; mv ls20-web.zip ../)
