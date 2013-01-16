# The first for loop is to rename all files with spaces in their filenames to be replaced with "_"
# uncomment the command lines
for i in ./*" "*.tif
do 
 y=$(printf %sa "$i"|tr " " "_") 
 b=${y%a}
 echo mv "$i" $b
 #mv "$i" $b
done

# The seconf for loop is to convert tif file into jpeg format
# uncomment the command lines

for i in $(ls *.tif)
do
 echo sips -s format jpeg $i --out ${i/.tif/}.jpg
 #sips -s format jpeg $i --out ${i%.tif}.jpg
done
