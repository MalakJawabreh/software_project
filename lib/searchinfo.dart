// To parse this JSON data, do
//
//     final searchinfo = searchinfoFromJson(jsonString);

import 'dart:convert';

List<Searchinfo> searchinfoFromJson(String str) => List<Searchinfo>.from(json.decode(str).map((x) => Searchinfo.fromJson(x)));

String searchinfoToJson(List<Searchinfo> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Searchinfo {
  Geometry? geometry;
  String? type;
  Properties? properties;

  Searchinfo({
    this.geometry,
    this.type,
    this.properties,
  });

  factory Searchinfo.fromJson(Map<String, dynamic> json) => Searchinfo(
    geometry: json["geometry"] == null ? null : Geometry.fromJson(json["geometry"]),
    type: json["type"],
    properties: json["properties"] == null ? null : Properties.fromJson(json["properties"]),
  );

  Map<String, dynamic> toJson() => {
    "geometry": geometry?.toJson(),
    "type": type,
    "properties": properties?.toJson(),
  };
}

class Geometry {
  List<double>? coordinates;
  String? type;

  Geometry({
    this.coordinates,
    this.type,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
    coordinates: json["coordinates"] == null ? [] : List<double>.from(json["coordinates"]!.map((x) => x?.toDouble())),
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "coordinates": coordinates == null ? [] : List<dynamic>.from(coordinates!.map((x) => x)),
    "type": type,
  };
}

class Properties {
  String? osmType;
  int? osmId;
  List<double>? extent;
  String? country;
  String? osmKey;
  String? countrycode;
  String? osmValue;
  String? name;
  String? state;
  String? type;
  String? city;

  Properties({
    this.osmType,
    this.osmId,
    this.extent,
    this.country,
    this.osmKey,
    this.countrycode,
    this.osmValue,
    this.name,
    this.state,
    this.type,
    this.city,
  });

  factory Properties.fromJson(Map<String, dynamic> json) => Properties(
    osmType: json["osm_type"],
    osmId: json["osm_id"],
    extent: json["extent"] == null ? [] : List<double>.from(json["extent"]!.map((x) => x?.toDouble())),
    country: json["country"],
    osmKey: json["osm_key"],
    countrycode: json["countrycode"],
    osmValue: json["osm_value"],
    name: json["name"],
    state: json["state"],
    type: json["type"],
    city: json["city"],
  );

  Map<String, dynamic> toJson() => {
    "osm_type": osmType,
    "osm_id": osmId,
    "extent": extent == null ? [] : List<dynamic>.from(extent!.map((x) => x)),
    "country": country,
    "osm_key": osmKey,
    "countrycode": countrycode,
    "osm_value": osmValue,
    "name": name,
    "state": state,
    "type": type,
    "city": city,
  };
}
