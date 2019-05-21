#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Kuril-Kamchatka Trench
# Profiles info: 400 km long, spaced 10 km, sampled every 2km
# # GMT modules: grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, psxy, grdtrack, convert, pstext, logo, psconvert
# Unix prog: cat
# Step-1. Generate a file
ps=cross2KKT.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=0.5c \
    MAP_ANNOT_OFFSET=0.2c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thin,dimgray \
    MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    FONT_LABEL=10p,Palatino-Roman,dimgray \
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Step-4. Extract a subset of ETOPO1m for the Kuril-Kamchatka Trench area
grdcut earth_relief_01m.grd -R140/170/40/60 -Gkkt_relief.nc
# Step-5. Make color palette
#gmt makecpt -Cglobe.cpt -V -T-10000/1000 > myocean.cpt
gmt makecpt -Crainbow -V -T-10000/1000/500 -Z > myocean.cpt
# Step-6. Make raster image
gmt grdimage kkt_relief.nc -Cmyocean.cpt -R140/170/40/60 -JM6i \
    -P -I+a15+ne0.75 -Xc -K > $ps
# Step-7. Add legend
gmt psscale -Dg135/40+w6.5i/0.15i+v+o0.3/0i+ml -Rkkt_relief.nc -J -Cmyocean.cpt \
	--FONT_LABEL=8p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=5p,Helvetica,dimgray \
	-Baf+l"Color scale legend: depth and height elevations (m)" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour kkt_relief.nc -R -J -C1000 \
    -B+t"Cross-sectional profiles of the Kuril-Kamchatka Trench: northern part" \
    -O -K >> $ps
# Step-9. Add grid
gmt psbasemap -R -J \
	-Lx5.3i/-0.5i+c50+w500k+l"Mercator projection. Scale (km)"+f \
	-Bxg4f2a4 -Byg4f2a4 \
    --MAP_TITLE_OFFSET=0.3c \
    --FONT=7p,Palatino-Roman,dimgray \
    -Tdx0.7c/13.3c+w0.3i+f2+l+o0.15i \
	-UBL/-15p/-35p -O -K >> $ps
# Step-10. Select two points along the Kuril-Kamchatka Trench
cat << EOF > trench2.txt
153.5 45.5
158.5 50.0
EOF
# Step-11. Plot trench segment and end points
gmt psxy -Rkkt_relief.nc -J -W2p,red trench2.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Gred trench2.txt -O -K >> $ps # points
# Step-12. Generate cross-track profiles 400 km long, spaced 10 km, sampled every 2km
# and stack these using the median, write stacked profile
gmt grdtrack trench2.txt -Gkkt_relief.nc -C400k/2k/10k+v -Sm+sstack2.txt > table2.txt
gmt psxy -R -J -W0.5p table2.txt -O -K >> $ps
# Step-13. Add text annotation
#gmt pstext -R -J -O -F+f16,Helvetica,white=thin >> $ps << END
#156 44 profiles 400 km long 10 km spaced 2 km sampled
#END
# Step-14. Show upper/lower values encountered as an envelope
gmt convert stack2.txt -o0,5 > env2.txt
gmt convert stack2.txt -o0,6 -I -T >> env2.txt
# Step-15. Plot graph
gmt psxy -R-200/200/-10000/0 -JX6i/2i -Y7.5i \
    -Bxag100f50+l"Distance from trench (km)" -Byagf+l"Depth (m)" \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_GRID_PEN_PRIMARY=thinner,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWESN \
	-Glightgray env2.txt -O -K >> $ps
gmt psxy -R -J -W1p -Ey stack2.txt -O -K >> $ps
gmt psxy -R -J -W1p,red stack2.txt -O -K >> $ps
# Step-16. Add test annotations
echo "100 -7000 Pacific Plate" | gmt pstext -R -J -Gwhite -F+jTC+f9p -O -K >> $ps
echo "50 -300 Median stacked profile with error bars" | gmt pstext -R -J -Gwhite -F+jTC+f10p,red -O -K >> $ps
echo "0 -8000 Kuril-Kamchatka Trench" | gmt pstext -R -J -Gwhite -F+jTC+f9p -O -K >> $ps
echo "-150 -5000 Greater Kuril Chain" | gmt pstext -R -J -Gwhite -F+jTC+f9p -O -K >> $ps
# Step-17. Add GMT logo
gmt logo -Dx6.2/-21.0+o0.1i/0.1i+w2c -O >> $ps
#gmt psxy -R -J -O -T >> $ps
# Step-18. Clean up (not necessary in this case)
#rm -f z.cpt ridge.txt table.txt env.txt stack.txt
# Step-19. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert cross2KKT.ps -A0.2c -E720 -Tj -P -Z
