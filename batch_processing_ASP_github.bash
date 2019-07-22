source $HOME/.bash_profile

tile=n27_e086

cd $tile

srtm=REF_DEM_MASK/DEM_REF_for_ASP.tif
utm=`gdalinfo $srtm | grep UTM | awk '{print $6}' | cut -c 1-2`

settings=$HOME/stereo.default.MikeWillisInt
DEM_PS=30.
PS_mapproject=7.5
correl_kernel=7
subpixel_kernel=13
outdir=ASTER_DEM_Used_only
mkdir $outdir

cd raw_L1A
nb_dem=`ls -d AST_L1A*.zip | wc | awk '{print $1}'`
echo "Nb of DEMs to process: " $nb_dem

ls -d AST_L1A*.zip > ../list_of_zipfile.txt
cd ..

N=1
while [ $N -le $nb_dem ]
do

	name=`head -$N  list_of_zipfile.txt | tail -1`
	echo $name

	MM=`echo ${name:11:2}`
	DD=`echo ${name:13:2}`
	YYYY=`echo ${name:15:4}`
	HH=`echo ${name:19:2}`
	MN=`echo ${name:21:2}`
	SS=`echo ${name:23:2}`
	hourdec=`echo "($HH+($MN/60.)+($SS/3600.))/24." | bc -l`
	doy=`date -d "$YYYY-$MM-$DD" +%j`
	dateOK=`echo "$YYYY+($doy+$hourdec)/365.25" | bc -l | awk '{printf "%.8f\n",$0}'`
	outdem="DEM_$dateOK"
	echo "Generating DEM from images acquired:" $outdem
	out=$outdir/$outdem
	mkdir $out
	echo "Output directory:" $out

	cp raw_L1A/$name $out
	unzip $out/$name -d $out
	rm $out/$name
	
	aster2asp $out -o $out/out --min-height 100 --max-height 9000

	mapproject -t rpc --t_srs "+proj=utm +zone=$utm +units=m +datum=WGS84" --mpp $PS_mapproject $srtm $out/out-Band3N.tif $out/out-Band3N.xml $out/out-Band3N_proj_SRTM.tif
	mapproject -t rpc --t_srs "+proj=utm +zone=$utm +units=m +datum=WGS84" --mpp $PS_mapproject $srtm $out/out-Band3B.tif $out/out-Band3B.xml $out/out-Band3B_proj_SRTM.tif
	stereo -t astermaprpc -s $settings --corr-kernel $correl_kernel $correl_kernel --subpixel-kernel $subpixel_kernel $subpixel_kernel --alignment-method none $out/out-Band3N_proj_SRTM.tif $out/out-Band3B_proj_SRTM.tif $out/out-Band3N.xml $out/out-Band3B.xml $out/$outdem $srtm
	point2dem -r earth --search-radius-factor 1.5 --utm $utm --tr ${DEM_PS} --nodata-value -9999 $out/$outdem-PC.tif -o $out/$outdem

	gdal_translate -ot Float32 $out/$outdem-DEM.tif $out/${outdem}_DEM.tif
	rm $out/$outdem-DEM.tif

	dem_geoid $out/${outdem}_DEM.tif --geoid EGM96 -o $out/${outdem}_DEM_EGM96
	gdal_translate -ot Float32 $out/${outdem}_DEM_EGM96-adj.tif $outdir/${outdem}.tif

	
	\rm -rf $out

        N=`expr $N + 1`

done
rm list_of_zipfile.txt

cd ..


