#!/usr/bin/env ruby

class GIS_JSON
  def initialize
    super
  end

  def get_track_json(name, segments)
    j = '{'
    j += '"type": "Feature", '
    if name != nil
      j+= '"properties": {'
      j += '"title": "' + name + '"'
      j += '},'
    end
    j += '"geometry": {'
    j += '"type": "MultiLineString",'
    j +='"coordinates": ['
    # Loop through all the segment objects
    segments.each_with_index do |s, index|
      if index > 0
        j += ","
      end
      j += '['
      # Loop through all the coordinates in the segment
      tsj = ''
      s.each do |c|
        if tsj != ''
          tsj += ','
        end
        # Add the coordinate
        tsj += '['
        tsj += "#{c.lon},#{c.lat}"
        if c.ele != nil
          tsj += ",#{c.ele}"
        end
        tsj += ']'
      end
      j+=tsj
      j+=']'
    end
    j + ']}}'
  end

  def get_waypoint_json(lon, lat, ele, name, type)
    j = '{"type": "Feature",'
    j += '"geometry": {"type": "Point","coordinates": '
    j += "[#{lon},#{lat}"
    if ele != nil
      j += ",#{ele}"
    end
    j += ']},'
    if name != nil or type != nil
      j += '"properties": {'
      if name != nil
        j += '"title": "' + name + '"'
      end
      if type != nil  # if type is not nil
        if name != nil
          j += ','
        end
        j += '"icon": "' + type + '"'  # type is the icon
      end
      j += '}'
    end
    j + "}"
  end

end

class Track
  attr_reader :name, :segments
  def initialize(segments:, name:nil)
    @name = name
    @segments = segments
  end

  def get_json(json)
    json.get_track_json(name, segments)
  end
end


class Point
  attr_reader :lat, :lon, :ele
  def initialize(lon:, lat:, ele:nil)
    @lon = lon
    @lat = lat
    @ele = ele
  end
end


class Waypoint < Point
  attr_reader :name, :type
  def initialize(lon:, lat:, ele:nil, name:nil, type:nil)
    super(lon:lon, lat:lat, ele:ele)
    @name = name
    @type = type
  end

  def get_json(json)
    json.get_waypoint_json(@lon, @lat, @ele, @name, @type)
  end
end


class World
  def initialize(name:, things:)
    @name = name
    @features = things
  end

  def add_feature(f)
    @features.append(f)
  end

  def to_geojson(indent=0)
    # TODO REMOVE
    json = GIS_JSON.new
    # Write stuff
    s = '{"type": "FeatureCollection","features": ['
    @features.each_with_index do |f,i|
      if i != 0
        s +=","
      end
      s += f.get_json(json)
    end
    s + "]}"
  end
end

def main()
  w = Waypoint.new(lon: -121.5, lat: 45.5, ele: 30, name: "home", type: "flag")
  w2 = Waypoint.new(lon: -121.5, lat: 45.6, ele: nil, name: "store", type: "dot")

  ts1 = [
    Point.new(lon: -122, lat: 45),
    Point.new(lon: -122, lat: 46),
    Point.new(lon: -121, lat: 46),
  ]

  ts2 = [
    Point.new(lon: -121, lat: 45),
    Point.new(lon: -121, lat: 46),
  ]

  ts3 = [
    Point.new(lon: -121, lat: 45.5),
    Point.new(lon: -122, lat: 45.5),
  ]

  t = Track.new(segments: [ts1, ts2], name: "track 1")
  t2 = Track.new(segments: [ts3], name: "track 2")

  world = World.new(name: "My Data", things: [w, w2, t, t2])

  puts world.to_geojson
end

if File.identical?(__FILE__, $0)
  main
end

