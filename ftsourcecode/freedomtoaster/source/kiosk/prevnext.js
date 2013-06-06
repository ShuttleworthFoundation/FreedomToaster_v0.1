var count=1;
function next(imgId,imgBasename,MaxCount)	{
   count += 1;
   if (count>=MaxCount+1) count = MaxCount;
   document.getElementById(imgId).src=imgBasename+count+".png";
}
function prev(imgId,imgBasename)	{
   count -= 1;
   if (count<=0) count = 1;
   document.getElementById(imgId).src=imgBasename+count+".png";
}
