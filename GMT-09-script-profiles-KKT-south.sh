#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Kuril-Kamchatka Trench
# Profiles info: 400 km long, spaced 10 km, sampled every 2km
# GMT modules: grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, psxy, grdtrack, convert, pstext, logo, psconvert
# Unix progs: cat, rm
# Step-1. Generate a file
ps=cross1KKT.ps
# Step-2. Extract a subset of ETOPO1m for the Kuril-Kamchatka Trench area
grdcut earth_relief_01m.grd -R140/170/40/60 -Gkkt_relief.nc
# Step-3. Make color palette
#gmt makecpt -Cglobe.cpt -V -T-10000/1000 > myocean.cpt
gmt makecpt -Crainbow -V -T-10000/1000/500 -Z > myocean.cpt
# Step-4. Make raster image
gmt grdimage kkt_relief.nc -Cmyocean.cpt -R140/170/40/60 -JM6i \
    -P -I+a15+ne0.75 -Xc -K > $ps
# Step-5. Add legend
gmt psscale -Dg135/40+w6.5i/0.15i+v+o0.3/0i+ml -Rkkt_relief.nc -J -Cmyocean.cpt \
	--FONT_LABEL=8p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=5p,Helvetica,dimgray \
	-Baf+l"Color scale legend: depth and height elevations (m)" \
	-I0.2 -By+lm -O -K >> $ps
# Step-6. Add shorelines
gmt grdcontour kkt_relief.nc -R -J -C1000 -O -K >> $ps
# Step-7. Add grid
gmt psbasemap -R -J \
	--FORMAT_GEO_MAP=dddF \
	--MAP_FRAME_PEN=dimgray \
	--MAP_FRAME_WIDTH=0.1c \
	--MAP_TICK_PEN_PRIMARY=thinner,dimgray \
	--FONT_TITLE=12p,Palatino-Roman,black \
	--FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
	--FONT_LABEL=7p,Helvetica,dimgray \
	-Tdx5.3i/0.5i+w0.3i+f2+l+o0.15i \
	-Lx5.3i/-0.5i+c50+w500k+l"Mercator projection. Scale (km)"+f \
	-Bxg4f2a4 -Byg4f2a4 \
	-B+t"Cross-sectional profiles of the Kuril-Kamchatka Trench: southern part" -O -K >> $ps
# Step-8. Select two points along the Kuril-Kamchatka Trench
cat << EOF > trench1.txt
148.0 43.0
153.5 45.5
EOF
# Step-9. Plot trench segment and end points
gmt psxy -Rkkt_relief.nc -J -W2p,red trench1.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Gred trench1.txt -O -K >> $ps # points
# Step-10. Generate cross-track profiles 400 km long, spaced 10 km, sampled every 2km
# and stack these using the median, write stacked profile
gmt grdtrack trench1.txt -Gkkt_relief.nc -C400k/2k/10k+v -Sm+sstack1.txt > table1.txt
gmt psxy -R -J -W0.5p table1.txt -O -K >> $ps
# Step-11. Add text annotation
#gmt pstext -R -J -O -F+f16,Helvetica,white=thin >> cross1KKT.ps << END
#156 44 profiles 400 km long 10 km spaced 2 km sampled
#END
# Step-12. Show upper/lower values encountered as an envelope
gmt convert stack1.txt -o0,5 > env1.txt
gmt convert stack1.txt -o0,6 -I -T >> env1.txt
# Step-13. Plot graph
gmt psxy -R-200/200/-10000/0 -Y7.5i \
    -Bxag100f50+l"Distance from trench (km)" -Byagf+l"Depth (m)" \
	--FONT_ANNOT_PRIMARY=9p,Helvetica,dimgray \
	--FONT_LABEL=9p,Helvetica,dimgray -BWESN \
	-JX6i/2i -Glightgray env1.txt -O -K >> $ps
gmt psxy -R -J -W1p -Ey stack1.txt -O -K >> $ps
gmt psxy -R -J -W1p,red stack1.txt -O -K >> $ps
# Step-14. Add test annotations
echo "0 -300 Median stacked profile with error bars" | gmt pstext -R -J \
    -Gwhite -F+jTR+f10p,Times-Roman,red -Dj0.1i -O -K >> $ps
echo "150 -2000 Greater Kuril Chain" | gmt pstext -R -J -Gwhite -F+jTC+f8p -O -K >> $ps
echo "-150 -6000 Pacific Plate" | gmt pstext -R -J -Gwhite -F+jTC+f8p -O -K >> $ps
#gmt psxy -R -J -T -O -K >> $ps
# Step-15. Add GMT logo
gmt logo -Dx6.2/-21.0+o0.1i/0.1i+w2c -O >> $ps
# Step-16. Cleanup
#rm -f z.cpt trench1.txt table1.txt env1.txt stack1.txt
# Step-17. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert cross1KKT.ps -A0.2c -E720 -Tj -P -Z
