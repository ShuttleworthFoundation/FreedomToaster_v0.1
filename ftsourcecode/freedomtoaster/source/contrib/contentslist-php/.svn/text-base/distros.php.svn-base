<?php print("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"); ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
  <title>Freedom Toaster Distros</title>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <meta name="Author" content="Stefano Rivera"/>
  <link rel="stylesheet" href="distros.css" type="text/css" />
</head>
<body>
  <h1>UCT Freedom Toaster Distros</h1>

<?php

$isodir="/srv/www/isos";

print("  <ul id=\"distros\">\n");

$distros=array();

// Iterate across Distros
$d = dir($isodir);
while (false !== ($distro = $d->read())) {
  if (substr($distro, 0, 1) == "."
      || $distro == "toaster"
      || substr($distro, -4) == ".xml"
      || substr($distro, -1) == "~")
    continue;
  
  $distros[]=$distro;
}

sort($distros);

foreach ($distros as $distro) {
  print("    <li class=\"distro\">$distro:\n");
  print("      <ul class=\"verions\">\n");
  
  $versions=array();
  
  // Iterate across Versions
  $dd = dir("$isodir/$distro");
  while (false !== ($version = $dd->read())) {
    if (substr($version, 0, 1) == "."
        || $version == "Images"
        || substr($version, -4) == ".xml"
        || substr($version, -1) == "~")
      continue;
    
    $versions[]=$version;
  }
  
  array_multisort($versions, SORT_NUMERIC, SORT_DESC, $versions, SORT_STRING);
  
  foreach ($versions as $version) {
    // Count up media types
    $media["CD"] = 0;
    $media["DVD"] = 0;
    foreach (array("CD", "DVD") as $mediatype) {
      if (is_dir("$isodir/$distro/$version/$mediatype")) {
        $ddvm = dir("$isodir/$distro/$version/$mediatype");
        while (false !== ($iso = $ddvm->read())) {
          if (substr($iso, -4) == ".iso")
            $media[$mediatype]++;
        }
      }
    }
    
    $medialist = "";
    if ($media["CD"] > 0) {
      $medialist = $media["CD"] . " CD";
      if ($media["CD"] != 1)
        $medialist .= "s";
      if ($media["DVD"] > 0)
        $medialist .= " or ";
    }
    if ($media["DVD"] > 0) {
      $medialist .= $media["DVD"] . " DVD";
      if ($media["DVD"] != 1)
        $medialist .= "s";
    }

    print("        <li class=\"version\">$version ($medialist)</li>\n");   
  }
  
  print("      </ul>\n");
  print("    </li>\n");
}
print("  </ul>\n");
?>
<p id="requests">To request a Distribution or version, please email <strong>legadmin</strong> AT <strong>leg</strong> "dot" <strong>uct</strong> _dot_ <strong>ac</strong> DOT <strong>za</strong></p>
<p id="footer">This page is generated automatically and therefore always 100% up to date</p>
</body>
</html>
