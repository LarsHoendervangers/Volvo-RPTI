import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:mbtiles/mbtiles.dart';
import 'package:vector_map_tiles_mbtiles/vector_map_tiles_mbtiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart';
import 'package:launcher/widgets/maps/themes/light_theme.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:latlong2/latlong.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<StatefulWidget> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final TileProviders _providers = TileProviders({
    'openmaptiles': MbTilesVectorTileProvider(
            mbtiles: MbTiles(mbtilesPath: 'assets/maps/osm-2020-02-10-v3.11_europe_netherlands.mbtiles', gzip: true),
            
          ),
  });
  final MapController _controller = MapController();
  late Style _style;
  
  @override
  void initState() {
    super.initState();
     _style = Style(theme: ThemeReader().read(lightStyle()), providers: _providers);
  }

  @override
  Widget build(BuildContext context) {
    return  FlutterMap(
      mapController: _controller,
      options: const MapOptions(
        initialCenter: LatLng(51.471947668137794, 4.660155052028216),
        minZoom: 5,
        maxZoom: 22,
        interactionOptions: InteractionOptions(flags: InteractiveFlag.drag | InteractiveFlag.flingAnimation),
        // interactiveFlags: InteractiveFlag.drag |
        //   InteractiveFlag.flingAnimation |
        //   InteractiveFlag.pinchMove |
        //   InteractiveFlag.pinchZoom |
        //   InteractiveFlag.doubleTapZoom
      ),
      children: [
        // normally you would see TileLayer which provides raster tiles
        // instead this vector tile layer replaces the standard tile layer
        VectorTileLayer(
          theme: _style.theme,
          sprites: _style.sprites,
          // tileOffset: TileOffset.mapbox, enable with mapbox
          tileProviders: _providers
        ),
      ],
    );
  }
}