// Copyright 2026 Skip
// SPDX-License-Identifier: MPL-2.0

#if !SKIP_BRIDGE
import SwiftUI
import Foundation

#if SKIP
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.BitmapDescriptorFactory
import com.google.maps.android.compose.__
#endif

// MARK: - Coordinate

/// A geographic coordinate (latitude/longitude pair).
public struct GoogleMapCoordinate: Hashable, Sendable {
    public var latitude: Double
    public var longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    #if SKIP
    func toLatLng() -> LatLng {
        LatLng(latitude, longitude)
    }
    #endif
}

// MARK: - Map Type

/// The type of map tiles to display.
public enum GoogleMapType: Int, Sendable {
    case normal = 0
    case satellite = 1
    case terrain = 2
    case hybrid = 3
    case none = 4
}

// MARK: - Camera Position

/// Describes a camera viewpoint on the map.
public struct GoogleMapCameraPosition: Sendable {
    public var target: GoogleMapCoordinate
    public var zoom: Float
    public var tilt: Float
    public var bearing: Float

    public init(target: GoogleMapCoordinate, zoom: Float = Float(10.0), tilt: Float = Float(0.0), bearing: Float = Float(0.0)) {
        self.target = target
        self.zoom = zoom
        self.tilt = tilt
        self.bearing = bearing
    }
}

// MARK: - Marker

/// A marker (pin) to display on the map.
public struct GoogleMapMarker: Identifiable, Sendable {
    public let id: String
    public var position: GoogleMapCoordinate
    public var title: String?
    public var snippet: String?
    public var hue: Float?
    public var opacity: Float
    public var draggable: Bool
    public var flat: Bool

    public init(
        id: String = UUID().uuidString,
        position: GoogleMapCoordinate,
        title: String? = nil,
        snippet: String? = nil,
        hue: Float? = nil,
        opacity: Float = Float(1.0),
        draggable: Bool = false,
        flat: Bool = false
    ) {
        self.id = id
        self.position = position
        self.title = title
        self.snippet = snippet
        self.hue = hue
        self.opacity = opacity
        self.draggable = draggable
        self.flat = flat
    }
}

// MARK: - Polyline

/// A polyline (series of connected line segments) to draw on the map.
public struct GoogleMapPolyline: Identifiable, Sendable {
    public let id: String
    public var points: [GoogleMapCoordinate]
    public var strokeColorHex: String
    public var strokeWidth: Float

    public init(id: String = UUID().uuidString, points: [GoogleMapCoordinate], strokeColorHex: String = "#0000FF", strokeWidth: Float = Float(5.0)) {
        self.id = id
        self.points = points
        self.strokeColorHex = strokeColorHex
        self.strokeWidth = strokeWidth
    }
}

// MARK: - Polygon

/// A polygon (closed shape) to draw on the map.
public struct GoogleMapPolygon: Identifiable, Sendable {
    public let id: String
    public var points: [GoogleMapCoordinate]
    public var strokeColorHex: String
    public var fillColorHex: String
    public var strokeWidth: Float

    public init(id: String = UUID().uuidString, points: [GoogleMapCoordinate], strokeColorHex: String = "#000000", fillColorHex: String = "#40000000", strokeWidth: Float = Float(2.0)) {
        self.id = id
        self.points = points
        self.strokeColorHex = strokeColorHex
        self.fillColorHex = fillColorHex
        self.strokeWidth = strokeWidth
    }
}

// MARK: - Circle

/// A circle overlay on the map.
public struct GoogleMapCircle: Identifiable, Sendable {
    public let id: String
    public var center: GoogleMapCoordinate
    public var radius: Double
    public var strokeColorHex: String
    public var fillColorHex: String
    public var strokeWidth: Float

    public init(id: String = UUID().uuidString, center: GoogleMapCoordinate, radius: Double, strokeColorHex: String = "#000000", fillColorHex: String = "#40000000", strokeWidth: Float = Float(2.0)) {
        self.id = id
        self.center = center
        self.radius = radius
        self.strokeColorHex = strokeColorHex
        self.fillColorHex = fillColorHex
        self.strokeWidth = strokeWidth
    }
}

// MARK: - Map Configuration

/// Configuration for the Google Map view.
public struct GoogleMapConfiguration: Sendable {
    public var mapType: GoogleMapType
    public var isMyLocationEnabled: Bool
    public var isMapToolbarEnabled: Bool
    public var isZoomControlsEnabled: Bool
    public var isZoomGesturesEnabled: Bool
    public var isScrollGesturesEnabled: Bool
    public var isTiltGesturesEnabled: Bool
    public var isRotateGesturesEnabled: Bool
    public var isCompassEnabled: Bool
    public var isMyLocationButtonEnabled: Bool
    public var isIndoorEnabled: Bool
    public var isTrafficEnabled: Bool
    public var isBuildingEnabled: Bool

    public init(
        mapType: GoogleMapType = .normal,
        isMyLocationEnabled: Bool = false,
        isMapToolbarEnabled: Bool = true,
        isZoomControlsEnabled: Bool = true,
        isZoomGesturesEnabled: Bool = true,
        isScrollGesturesEnabled: Bool = true,
        isTiltGesturesEnabled: Bool = true,
        isRotateGesturesEnabled: Bool = true,
        isCompassEnabled: Bool = true,
        isMyLocationButtonEnabled: Bool = true,
        isIndoorEnabled: Bool = true,
        isTrafficEnabled: Bool = false,
        isBuildingEnabled: Bool = true
    ) {
        self.mapType = mapType
        self.isMyLocationEnabled = isMyLocationEnabled
        self.isMapToolbarEnabled = isMapToolbarEnabled
        self.isZoomControlsEnabled = isZoomControlsEnabled
        self.isZoomGesturesEnabled = isZoomGesturesEnabled
        self.isScrollGesturesEnabled = isScrollGesturesEnabled
        self.isTiltGesturesEnabled = isTiltGesturesEnabled
        self.isRotateGesturesEnabled = isRotateGesturesEnabled
        self.isCompassEnabled = isCompassEnabled
        self.isMyLocationButtonEnabled = isMyLocationButtonEnabled
        self.isIndoorEnabled = isIndoorEnabled
        self.isTrafficEnabled = isTrafficEnabled
        self.isBuildingEnabled = isBuildingEnabled
    }
}

// MARK: - Marker Hue Constants

/// Standard marker color hues for use with `GoogleMapMarker.hue`.
public struct GoogleMapMarkerHue {
    public static let red: Float = Float(0.0)
    public static let orange: Float = Float(30.0)
    public static let yellow: Float = Float(60.0)
    public static let green: Float = Float(120.0)
    public static let cyan: Float = Float(180.0)
    public static let azure: Float = Float(210.0)
    public static let blue: Float = Float(240.0)
    public static let violet: Float = Float(270.0)
    public static let magenta: Float = Float(300.0)
    public static let rose: Float = Float(330.0)
}

// MARK: - GoogleMapView

/// A SwiftUI view that displays a Google Map.
///
/// On iOS, this shows a placeholder (integrate Google Maps iOS SDK directly for full support).
/// On Android, this wraps `com.google.maps.android:maps-compose` via Jetpack Compose.
public struct GoogleMapView: View {
    let initialCamera: GoogleMapCameraPosition
    let configuration: GoogleMapConfiguration
    let markers: [GoogleMapMarker]
    let polylines: [GoogleMapPolyline]
    let polygons: [GoogleMapPolygon]
    let circles: [GoogleMapCircle]
    let onMapTap: ((GoogleMapCoordinate) -> Void)?
    let onMarkerTap: ((GoogleMapMarker) -> Bool)?

    public init(
        initialCamera: GoogleMapCameraPosition = GoogleMapCameraPosition(target: GoogleMapCoordinate(latitude: 37.7749, longitude: -122.4194)),
        configuration: GoogleMapConfiguration = GoogleMapConfiguration(),
        markers: [GoogleMapMarker] = [],
        polylines: [GoogleMapPolyline] = [],
        polygons: [GoogleMapPolygon] = [],
        circles: [GoogleMapCircle] = [],
        onMapTap: ((GoogleMapCoordinate) -> Void)? = nil,
        onMarkerTap: ((GoogleMapMarker) -> Bool)? = nil
    ) {
        self.initialCamera = initialCamera
        self.configuration = configuration
        self.markers = markers
        self.polylines = polylines
        self.polygons = polygons
        self.circles = circles
        self.onMapTap = onMapTap
        self.onMarkerTap = onMarkerTap
    }

    #if !SKIP
    public var body: some View {
        #if os(iOS)
        Text("Google Maps requires the Google Maps iOS SDK. See SkipGMaps README for setup.")
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        #else
        Text("Google Maps is not available on macOS.")
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        #endif
    }
    #else
    // SKIP @nobridge
    @Composable override func ComposeContent(context: ComposeContext) {
        let cameraPositionState = rememberCameraPositionState {
            position = CameraPosition.fromLatLngZoom(
                LatLng(initialCamera.target.latitude, initialCamera.target.longitude),
                initialCamera.zoom
            )
        }

        let mapProperties = MapProperties(
            isBuildingEnabled: configuration.isBuildingEnabled,
            isIndoorEnabled: configuration.isIndoorEnabled,
            isMyLocationEnabled: configuration.isMyLocationEnabled,
            isTrafficEnabled: configuration.isTrafficEnabled,
            mapType: toComposeMapType(configuration.mapType)
        )

        let mapUiSettings = MapUiSettings(
            compassEnabled: configuration.isCompassEnabled,
            mapToolbarEnabled: configuration.isMapToolbarEnabled,
            myLocationButtonEnabled: configuration.isMyLocationButtonEnabled,
            rotationGesturesEnabled: configuration.isRotateGesturesEnabled,
            scrollGesturesEnabled: configuration.isScrollGesturesEnabled,
            tiltGesturesEnabled: configuration.isTiltGesturesEnabled,
            zoomControlsEnabled: configuration.isZoomControlsEnabled,
            zoomGesturesEnabled: configuration.isZoomGesturesEnabled
        )

        // The Google Map composable and its content must be emitted as raw Kotlin
        // because it uses the GoogleMapComposable content lambda pattern
        // SKIP INSERT:
        // GoogleMap(
        //     modifier = context.modifier,
        //     cameraPositionState = cameraPositionState,
        //     properties = mapProperties,
        //     uiSettings = mapUiSettings,
        //     onMapClick = { latLng -> onMapTap?.invoke(GoogleMapCoordinate(latitude = latLng.latitude, longitude = latLng.longitude)); Unit }
        // ) {
        //     for (marker in markers) {
        //         val markerState = MarkerState(position = com.google.android.gms.maps.model.LatLng(marker.position.latitude, marker.position.longitude))
        //         val icon = marker.hue?.let { com.google.android.gms.maps.model.BitmapDescriptorFactory.defaultMarker(it) }
        //         Marker(
        //             state = markerState,
        //             title = marker.title,
        //             snippet = marker.snippet,
        //             alpha = marker.opacity,
        //             draggable = marker.draggable,
        //             flat = marker.flat,
        //             icon = icon,
        //             onClick = { onMarkerTap?.invoke(marker) ?: false }
        //         )
        //     }
        //     for (polyline in polylines) {
        //         Polyline(
        //             points = polyline.points.map { com.google.android.gms.maps.model.LatLng(it.latitude, it.longitude) }.toList(),
        //             color = androidx.compose.ui.graphics.Color(android.graphics.Color.parseColor(polyline.strokeColorHex)),
        //             width = polyline.strokeWidth
        //         )
        //     }
        //     for (polygon in polygons) {
        //         Polygon(
        //             points = polygon.points.map { com.google.android.gms.maps.model.LatLng(it.latitude, it.longitude) }.toList(),
        //             strokeColor = androidx.compose.ui.graphics.Color(android.graphics.Color.parseColor(polygon.strokeColorHex)),
        //             fillColor = androidx.compose.ui.graphics.Color(android.graphics.Color.parseColor(polygon.fillColorHex)),
        //             strokeWidth = polygon.strokeWidth
        //         )
        //     }
        //     for (circle in circles) {
        //         Circle(
        //             center = com.google.android.gms.maps.model.LatLng(circle.center.latitude, circle.center.longitude),
        //             radius = circle.radius,
        //             strokeColor = androidx.compose.ui.graphics.Color(android.graphics.Color.parseColor(circle.strokeColorHex)),
        //             fillColor = androidx.compose.ui.graphics.Color(android.graphics.Color.parseColor(circle.fillColorHex)),
        //             strokeWidth = circle.strokeWidth
        //         )
        //     }
        // }
    }

    private func toComposeMapType(_ mapType: GoogleMapType) -> MapType {
        switch mapType {
        case .normal: return MapType.NORMAL
        case .satellite: return MapType.SATELLITE
        case .terrain: return MapType.TERRAIN
        case .hybrid: return MapType.HYBRID
        case .none: return MapType.NONE
        }
    }
    #endif
}

#endif
