require 'sketchup.rb'
require 'extensions.rb'
require 'json.rb'
require	'rexml/document.rb'
#SKETCHUP_CONSOLE.clear
module TRONMAKE
	module OSMBI
#####################
######
@mod = Sketchup.active_model
@ent = @mod.entities
@sel = @mod.selection
@view = @mod.active_view
@bid_layer
@way_layer
@bbx_layer
@current_layer
######
def self.skpupdate
	@mod = Sketchup.active_model
	@ent = @mod.entities
	@sel = @mod.selection
	@view = @mod.active_view
	@current_layer = @mod.active_layer
end
######
def self.setlayer
	layers = @mod.layers
	@bid_layer = layers.add("osm buildings")
	@way_layer = layers.add("osm ways")
	@bbx_layer = layers.add("osm bounding")
end
######
def self.resorte_layer
	@mod.active_layer = @current_layer
end
######
def self.add_bound(minlat,maxlat,minlon,maxlon)
	ld = Geom::LatLong.new(minlat,minlon).to_utm
	lu = Geom::LatLong.new(maxlat,minlon).to_utm
	rd = Geom::LatLong.new(minlat,maxlon).to_utm
	ru = Geom::LatLong.new(maxlat,maxlon).to_utm
	pts=[]
	pts<<[ld.x.m,ld.y.m,0]
	pts<<[rd.x.m,rd.y.m,0]
	pts<<[ru.x.m,ru.y.m,0]
	pts<<[lu.x.m,lu.y.m,0]
	pts<<[ld.x.m,ld.y.m,0]
	@mod.active_layer = @bbx_layer
	line = @ent.add_line(pts)
end
######
def self.add_building(pts,height)
	@mod.active_layer = @bid_layer
	face = @ent.add_face(pts)
	n = face.normal
	if n[2]<0
		face.reverse!
	end
	if height[1]>0
		face.pushpull(height[1].m,true)
		#face.reverse!    
	end
end
######
def self.add_way(pts)
	@mod.active_layer = @way_layer
	face = @ent.add_line(pts)
end
######
def self.import_osm_file(file)
	self.skpupdate
	self.setlayer
	Sketchup.status_text = "Opening \"#{file}\", please wait..."
	xml = File.new(file)
	if !xml 
		Sketchup.status_text = "Open \"#{file}\" failed!"
		return nil
	end
	Sketchup.status_text = "Parsing \"#{file}\", please wait..."
	doc = REXML::Document.new xml
	if !doc 
		Sketchup.status_text = "\"#{file}\" is not xml format!"
		return nil
	end
	if !doc.elements['osm'] 
		Sketchup.status_text = "\"#{file}\" is not osm format!"
		return nil
	end

	bbx=doc.elements['osm/bounds']
	minlat=bbx.attributes['minlat'].to_f
	maxlat=bbx.attributes['maxlat'].to_f
	minlon=bbx.attributes['minlon'].to_f
	maxlon=bbx.attributes['maxlon'].to_f
	self.add_bound(minlat,maxlat,minlon,maxlon)
	Sketchup.status_text = "Loading \"#{file}\", please wait..."
	osmid=[]
	osmll=[]
	doc.elements.each("osm/node") { |node| 
	    osmid << node.attributes["id"].to_i
	    osmll << Geom::LatLong.new(node.attributes["lat"].to_f,node.attributes["lon"].to_f)
	}
	bids=0
	wids=0
	wcount=0
	progress=0
	wlength = REXML::XPath.first(doc, "count(osm/way)")
	doc.elements.each("osm/way") { |way|
	    height=[0,0]
	    isbuilding=false
	    isway=false
	    way.elements.each("tag") { |tag|
	        k = tag.attributes["k"]
	        if k==="building"
	            isbuilding=true
	        elsif k==="building:part"
	            isbuilding=true
	        elsif k==="height"
	            height[1] = tag.attributes["v"].to_f
	        elsif k==="min_height"
	            height[0] = tag.attributes["v"].to_f
	          # roof color material TBD
	        end
	        
	        if k==="highway"
	            isway=true
	        elsif k==="building:part"
	            isbuilding=true
	        elsif k==="height"
	            height[1] = tag.attributes["v"].to_f
	        elsif k==="min_height"
	            height[0] = tag.attributes["v"].to_f
	          # roof color material TBD
	        end
	        
	    }
	    if isbuilding
	        nids=[]
	        way.elements.each("nd") { |nd|
	            nid = nd.attributes["ref"].to_i
	            nids << osmid.index(nid)
	        }
	        if nids
	            pts=[]
	            nids.each{|nid|
	                utm=osmll[nid].to_utm
	                pts<<[utm.x.m,utm.y.m,height[0].m] 
	            }
	            self.add_building(pts,height)
	            bids+=1
	        end
	    end
	    if isway
	        nids=[]
	        way.elements.each("nd") { |nd|
	            nid = nd.attributes["ref"].to_i
	            nids << osmid.index(nid)
	        }
	        if nids
	            pts=[]
	            nids.each{|nid|
	                utm=osmll[nid].to_utm
	                pts<<[utm.x.m,utm.y.m,height[0].m] 
	            }
	            self.add_way(pts)
	            wids+=1
	        end
	    end
	    wcount+=1
	    progress=((wcount*100/wlength)).round
	    Sketchup.status_text = "Loading \"#{file}\", #{progress}%, #{bids} buildings, #{wids} ways!"

	}
	xml.close
	@view.zoom_extents
	Sketchup.status_text = "Loading \"#{file}\" successed, #{bids} buildings!"
	self.resorte_layer
end
######
unless file_loaded?(__FILE__)
	UI.menu('Plugins').add_item('OSMBI'){
		file = nil
		file = UI.openpanel("Select Open Street Map File", "", "OSM|*.osm|XML|*.xml|Any|*|")
		if file
			self.import_osm_file(file) 
		end 
	}
	file_loaded(__FILE__)
end
#####################
end # module TRONMAKE
end # module OSMBI