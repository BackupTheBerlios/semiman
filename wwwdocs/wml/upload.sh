#!/bin/sh

RSYNC="rsync --progress --verbose --rsh=ssh -r"

make
BERLIOS=BERLIOS make
cd /var/www/html/seminars-static
echo "Uploading to Com-Net"
echo
# scp * shlomif@vipe.technion.ac.il:public_html/freecell-solver/
$RSYNC * cn1s02@comnet.technion.ac.il:public_html/
cd /var/www/html/seminars-static-berlios
echo "Uploading to Berlios"
echo
# scp * shlomif@shell.berlios.de:/home/groups/fc-solve/htdocs/
$RSYNC * shlomif@shell.berlios.de:/home/groups/semiman/htdocs/

