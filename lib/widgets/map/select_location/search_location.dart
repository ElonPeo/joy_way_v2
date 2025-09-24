import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/general_specifications.dart';
import '../../../services/mapbox_services/mapbox_config.dart';
import '../../animated_container/animated_icon_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../notifications/show_notification.dart';

class SearchLocation extends StatefulWidget {

  final Function(GeoPoint?) onLonLatGeoPoint;
  const SearchLocation({
    super.key,

    required this.onLonLatGeoPoint,
  });

  @override
  State<SearchLocation> createState() => _SearchLocationState();
}

class _SearchLocationState extends State<SearchLocation> {
  Timer? _deb;

  void _debouncedSearch(String q) {
    _deb?.cancel();
    _deb = Timer(const Duration(milliseconds: 350), () => searchPlace(q));
  }

  List<Map<String, dynamic>> results = [];
  final TextEditingController _controller = TextEditingController();


  Future<void> searchPlace(String query, {bool searchPOI = true}) async {
    final q = Uri.encodeComponent(query.trim());
    const vnBbox = "102.144,8.179,109.469,23.392";
    if (q.isEmpty) {
      setState(() => results = []);
      return;
    }


    final url =
        "https://api.mapbox.com/geocoding/v5/mapbox.places/$q.json"
        "?access_token=${MapboxConfig.accessToken}"
        "&limit=8"
        "&language=vi"
        "&bbox=$vnBbox"
        "&country=VN"
        "&autocomplete=true"
        "&fuzzyMatch=true";

    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        results = List<Map<String, dynamic>>.from(data["features"]);
      });
    } else {
      debugPrint("Search failed: ${res.statusCode} ${res.body}");
    }
  }





  @override
  void dispose() {
    _deb?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // header
          Container(
            padding:
                const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 50),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(40),
                bottomLeft: Radius.circular(40),
              ),
              color: specs.black240,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 50,
                      child: AnimatedIconButton(
                          onTap: () async {
                            FocusScope.of(context).unfocus();
                            await Future.delayed(const Duration(milliseconds: 300));
                            Navigator.pop(context);
                          },
                        height: 30,
                        width: 20,
                        color: Colors.transparent,
                        shadowColor: Colors.transparent,
                        child: SizedBox(
                          height: 23,
                          width: 23,
                          child: Image.asset(
                              "assets/icons/other_icons/angle-left.png"),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                      width: specs.screenWidth - 130,
                      child: Center(
                          child: Text(
                        "Search Location",
                        style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      )),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 15),
                Container(
                  height: 45,
                  width: specs.screenWidth,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        height: 45,
                        width: 45,
                        child: Center(
                          child: Container(
                            height: 38,
                            width: 38,
                            decoration: const BoxDecoration(
                                color: Colors.black, shape: BoxShape.circle),
                            child: const Center(
                              child: ImageIcon(
                                  AssetImage(
                                      "assets/icons/other_icons/search.png"),
                                  color: Colors.white,
                                  size: 20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        height: 45,
                        width: specs.screenWidth - 110,
                        padding: const EdgeInsets.only(bottom: 12.5),
                        child: TextField(
                          controller: _controller,
                          autofocus: true,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Search for location",
                            hintStyle: GoogleFonts.outfit(color: specs.black80, fontSize: 14),
                          ),
                          onChanged: (t) => _debouncedSearch(t),
                          textInputAction: TextInputAction.search,
                          onSubmitted: (t) => searchPlace(t),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),

          // results
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: results.length,
              itemBuilder: (_, i) {
                final place = results[i];
                final text = place["place_name"] ?? "";
                return ListTile(
                  title: Text(text),
                  onTap: () async {
                    final coords = (place["geometry"]["coordinates"] as List);
                    // Mapbox trả [lon, lat] chuyển về [lat, lon] chuẩn định dạng GeoPoint
                    final lon = (coords[0] as num).toDouble();
                    final lat = (coords[1] as num).toDouble();
                    widget.onLonLatGeoPoint(GeoPoint(lat, lon));
                    FocusScope.of(context).unfocus();
                    await Future.delayed(const Duration(milliseconds: 300));
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
