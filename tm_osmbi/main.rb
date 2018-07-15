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
######
def self.skpupdate
	@mod = Sketchup.active_model
	@ent = @mod.entities
	@sel = @mod.selection
	@view = @mod.active_view
end
######
def self.add_building(nids,height)
	pts=[]
	nids.each{|nid|
		utm=@LL[nid].to_utm
		pts<<[utm.x.m,utm.y.m,height[0].m] 
	}
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
def self.import_osm_file(file)
	self.skpupdate
	xml = File.new(file)
	if !xml 
		return nil
	end
	doc = REXML::Document.new xml
	if !doc 
		return nil
	end
	if !doc.elements['osm'] 
		return nil
	end
	Sketchup.status_text = "Loading \"#{file}\", please wait..."
	@ID=[]
	@LL=[]
	doc.elements.each("osm/node") { |node| 
		@ID << node.attributes["id"].to_i
		@LL << Geom::LatLong.new(node.attributes["lat"].to_f,node.attributes["lon"].to_f)
	}
	bids=0
	wcount=0
	progress=0
	wlength = REXML::XPath.first(doc, "count(osm/way)")
	doc.elements.each("osm/way") { |way|
		height=[0,0]
		isbuilding=false
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
		}
		if isbuilding
			nids=[]
			way.elements.each("nd") { |nd|
				nid = nd.attributes["ref"].to_i
				nids << @ID.index(nid)
			}
			if nids
				self.add_building(nids,height)
				bids+=1
			end
		end
		wcount+=1
		progress=((wcount*100/wlength)).round
		Sketchup.status_text = "Loading \"#{file}\", #{progress}% #{bids} buildings!"
	}
	@view.zoom_extents
	xml.close
	Sketchup.status_text = "Loading \"#{file}\" successed, #{bids} buildings!"
end
######
unless file_loaded?(__FILE__)
	UI.menu('Plugins').add_item('OSMBI'){
		file = nil
		file = UI.openpanel("Open OSM File", "", "OSM|*.osm|XML|*.xml|Any|*|")
		if file
			self.import_osm_file(file) 
		end 
	}
	file_loaded(__FILE__)
end
#####################
end # module TRONMAKE
end # module OSMBI