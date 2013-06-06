     if (self.location.href == top.location.href) {
         var newlocation = location.pathname + location.search;
         var cgibin = newlocation.lastIndexOf('/cgi-bin');
         var lastslash = newlocation.lastIndexOf('/');
         if (cgibin != -1) {
            var indexlocation = "..";
            newlocation = newlocation.substring(cgibin);
         } else {
            var indexlocation = newlocation.substring(0,newlocation.lastIndexOf('/locale/'));
            newlocation = newlocation.substring(lastslash+1);
         }
         newlocation = indexlocation + '/index.html?' + newlocation;
         top.location.href = newlocation;
      }

function magnifySelect(obj)	{
	if (obj.style.fontSize!='xx-large')	{
		obj.style.fontSize='xx-large';
		obj.style.backgroundColor='#ec870e';
		if (parent.numLanguages>10)		obj.size=10;
		else	obj.size=parent.numLanguages;
    	} else {
     		obj.style.fontSize='medium';
    		obj.style.backgroundColor='transparent';
    		obj.size=1;
    	}
}

function populateSelect()	{
	var num=0;
	for (var i in parent.languages)	{
		obj = document.getElementById("lang-sel");
		obj.options[num] = new Option(i,parent.languages[i]);
		if (parent.lang == parent.languages[i])  obj.selectedIndex = num;
		num++;
	}
	if (num<2) {
		// Only one language, no need to display menu
		document.getElementById("language-bg").style.visibility="hidden";
		document.getElementById("language").style.visibility="hidden";
	}
}

function changeLang(obj)	{
	parent.lang=obj.options[obj.selectedIndex].value;
	parent.setCookie('FTlang',parent.lang,360);
	// Reload current page with new lang
	top.location.href=document.location.href;
}
