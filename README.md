# SketchUp Open Street Map Building Importer

## Introduction
OSMBI is a Open Street Map Building Importer for SketchUp


## Installation

**You can choose source code installation or extension installation as you like.**

- ### Source code installation

1. Copy `tm_osmi.rb` and `tm_osmi` folder to SketchUp extension folder.
2. Restart SketchUp
- #### NOTES
Extension folder for windows is `%appdata%\SketchUp\SketchUp ####\SketchUp\Plugins\`  
Extension folder for Mac OS X is `~/Library/Application Support/SketchUp ####/SketchUp/Plugins`  
Please change the `####` to the appropriate version of SketchUp.  
For example, extension folder of SketchUp 2018 (both pro and make version) in windows is `%appdata%\SketchUp\SketchUp 2018\SketchUp\Plugins\`

- ### Extension installation
1. Download extension file (.rbz file) form [releases](../../releases)
2. Select `Window > Extension Manager` (Windows) or `SketchUp > Extension Manager` (Mac OS X)
3. Click `Install Extension` button and select `skp_osmbi.rbz` file


#### Usage

1. Select `Extensions` menu, click `OSMBI`.
2. Select your open street map file (.osm).
3. Wait for a while.


#### Example

map: [https://www.openstreetmap.org/api/0.6/map?bbox=-74.00362,40.72491,-73.99424,40.73209](https://www.openstreetmap.org/api/0.6/map?bbox=-74.00362,40.72491,-73.99424,40.73209)
png: [https://render.openstreetmap.org/cgi-bin/export?bbox=-74.00362,40.72491,-73.99424,40.73209&scale=6800&format=png](https://render.openstreetmap.org/cgi-bin/export?bbox=-74.00362,40.72491,-73.99424,40.73209&scale=6800&format=png)


#### Issues
- Do not support color and metarial.
- Do not support the shape of roof, only flat roof.

#### References

1. [Open Street Map](https://www.openstreetmap.org/)
2. [SketchUp](https://www.sketchup.com/)
3. [SketchUp Download](https://www.sketchup.com/download/all)
3. [SketchUp Ruby API](https://ruby.sketchup.com/)
4. [Ruby REXML (xml parser) Doc](https://ruby-doc.org/stdlib-2.2.3/libdoc/rexml/rdoc/REXML/Document.html)



