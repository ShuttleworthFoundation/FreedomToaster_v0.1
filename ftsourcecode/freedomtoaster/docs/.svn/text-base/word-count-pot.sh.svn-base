#copy to pwd and execute to see word count of POT. Redirect to file for number count in a text file
for file in `ls *.pot`
do 
echo -n $file 
grep -v '#' $file | awk -F'"' '{print $2}' | wc -w
done