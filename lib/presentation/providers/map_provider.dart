import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MapViewType { standard, satellite, terrain }

class MapState {
  final MapViewType viewType;
  final bool showTraffic;
  final double zoom;

  const MapState({
    this.viewType = MapViewType.standard,
    this.showTraffic = false,
    this.zoom = 13,
  });

  MapState copyWith({
    MapViewType? viewType,
    bool? showTraffic,
    double? zoom,
  }) {
    return MapState(
      viewType: viewType ?? this.viewType,
      showTraffic: showTraffic ?? this.showTraffic,
      zoom: zoom ?? this.zoom,
    );
  }
}

final mapProvider = StateNotifierProvider<MapController, MapState>((ref) {
  return MapController();
});

class MapController extends StateNotifier<MapState> {
  MapController() : super(const MapState());

  void setMapViewType(MapViewType type) {
    state = state.copyWith(viewType: type);
  }

  void toggleTraffic() {
    state = state.copyWith(showTraffic: !state.showTraffic);
  }

  void setZoom(double zoom) {
    state = state.copyWith(zoom: zoom);
  }

  /// Retourne l'URL du tile provider en fonction du type de vue
  String getTileUrl() {
    switch (state.viewType) {
      case MapViewType.satellite:
        // Utiliser ESRI satellite
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case MapViewType.terrain:
        // Utiliser ESRI terrain
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}';
      case MapViewType.standard:
      default:
        // OpenStreetMap standard
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }
}
