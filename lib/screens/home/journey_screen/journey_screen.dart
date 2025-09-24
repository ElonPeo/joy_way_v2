import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../../config/general_specifications.dart';

class JourneyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Container(
      height: specs.screenHeight,
      width: specs.screenWidth,
      color: Colors.red,
      child: SimplePoiTap(),
    );
  }
}



class SimplePoiTap extends StatefulWidget {
  const SimplePoiTap({super.key});
  @override
  State<SimplePoiTap> createState() => _SimplePoiTapState();
}

class _SimplePoiTapState extends State<SimplePoiTap> {
  late MapboxMap _map;

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      onMapCreated: (c) async {
        _map = c;

        // Tap vào POI sẵn có (Mapbox Standard)
        final tapPOI = TapInteraction(StandardPOIs(), (feature, ctx) async {
          // Tên & toạ độ (tuỳ SDK, name/category có thể null)
          final name = feature.name ?? "POI";
          final cat  = feature.category ?? "";
          final lng  = ctx.point.coordinates.lng.toStringAsFixed(6);
          final lat  = ctx.point.coordinates.lat.toStringAsFixed(6);

          debugPrint('[POI] $name | $cat @ $lng,$lat');
          if (feature.properties != null) {
            debugPrint('[POI PROPS] ${feature.properties}');
          }

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$name${cat.isNotEmpty ? " ($cat)" : ""} @ $lng,$lat')),
            );
          }
        });

        _map.addInteraction(tapPOI, interactionID: "poiTap");
      },
    );
  }
}
