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
#elseif canImport(GoogleMaps)
import GoogleMaps
#endif

// MARK: - API Key Configuration

/// Provides the Google Maps API key to the underlying SDK.
public enum GoogleMapsConfiguration {
    public static func provideAPIKey(_ apiKey: String) {
        #if SKIP
        let context = ProcessInfo.processInfo.androidContext
        let appInfo = context.getPackageManager().getApplicationInfo(context.getPackageName(), android.content.pm.PackageManager.GET_META_DATA)
        if appInfo.metaData == nil {
            appInfo.metaData = android.os.Bundle()
        }
        appInfo.metaData.putString("com.google.android.geo.API_KEY", apiKey)
        #elseif canImport(GoogleMaps)
        GMSServices.provideAPIKey(apiKey)
        #endif
    }
}

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

/// Describes a camera viewpoint on the map (used for the initial position).
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

// MARK: - Map Position (Bindable)

/// A live, two-way observable map camera position.
public struct GoogleMapPosition: Equatable {
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

    public init(_ camera: GoogleMapCameraPosition) {
        self.target = camera.target
        self.zoom = camera.zoom
        self.tilt = camera.tilt
        self.bearing = camera.bearing
    }

    public static func == (lhs: GoogleMapPosition, rhs: GoogleMapPosition) -> Bool {
        lhs.target == rhs.target && lhs.zoom == rhs.zoom && lhs.tilt == rhs.tilt && lhs.bearing == rhs.bearing
    }
}

// MARK: - Stroke Pattern

/// A pattern segment for dashed/dotted lines.
public enum GoogleMapStrokePatternItem: Sendable {
    /// A solid dash of the given length in points.
    case dash(Float)
    /// A gap of the given length in points.
    case gap(Float)
    /// A dot.
    case dot
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
    /// Clockwise rotation of the marker in degrees around the anchor.
    public var rotation: Double
    /// Z-index for draw ordering. Higher values are drawn on top.
    public var zIndex: Int
    /// The anchor point (0,0 = top-left, 0.5,0.5 = center, 0.5,1.0 = bottom-center default).
    public var anchorX: Float
    public var anchorY: Float

    public init(
        id: String = UUID().uuidString,
        position: GoogleMapCoordinate,
        title: String? = nil,
        snippet: String? = nil,
        hue: Float? = nil,
        opacity: Float = Float(1.0),
        draggable: Bool = false,
        flat: Bool = false,
        rotation: Double = 0.0,
        zIndex: Int = 0,
        anchorX: Float = Float(0.5),
        anchorY: Float = Float(1.0)
    ) {
        self.id = id
        self.position = position
        self.title = title
        self.snippet = snippet
        self.hue = hue
        self.opacity = opacity
        self.draggable = draggable
        self.flat = flat
        self.rotation = rotation
        self.zIndex = zIndex
        self.anchorX = anchorX
        self.anchorY = anchorY
    }
}

// MARK: - Polyline

/// A polyline (series of connected line segments) to draw on the map.
public struct GoogleMapPolyline: Identifiable, Sendable {
    public let id: String
    public var points: [GoogleMapCoordinate]
    public var strokeColorHex: String
    public var strokeWidth: Float
    /// Whether the polyline is geodesic (curved along the earth's surface).
    public var geodesic: Bool
    /// Z-index for draw ordering.
    public var zIndex: Int
    /// Whether the polyline is tappable.
    public var tappable: Bool
    /// Stroke pattern segments (nil = solid).
    public var pattern: [GoogleMapStrokePatternItem]?

    public init(
        id: String = UUID().uuidString,
        points: [GoogleMapCoordinate],
        strokeColorHex: String = "#0000FF",
        strokeWidth: Float = Float(5.0),
        geodesic: Bool = false,
        zIndex: Int = 0,
        tappable: Bool = false,
        pattern: [GoogleMapStrokePatternItem]? = nil
    ) {
        self.id = id
        self.points = points
        self.strokeColorHex = strokeColorHex
        self.strokeWidth = strokeWidth
        self.geodesic = geodesic
        self.zIndex = zIndex
        self.tappable = tappable
        self.pattern = pattern
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
    /// Whether the polygon edges are geodesic.
    public var geodesic: Bool
    /// Z-index for draw ordering.
    public var zIndex: Int
    /// Whether the polygon is tappable.
    public var tappable: Bool
    /// Holes (exclusion zones) within the polygon.
    public var holes: [[GoogleMapCoordinate]]

    public init(
        id: String = UUID().uuidString,
        points: [GoogleMapCoordinate],
        strokeColorHex: String = "#000000",
        fillColorHex: String = "#40000000",
        strokeWidth: Float = Float(2.0),
        geodesic: Bool = false,
        zIndex: Int = 0,
        tappable: Bool = false,
        holes: [[GoogleMapCoordinate]] = []
    ) {
        self.id = id
        self.points = points
        self.strokeColorHex = strokeColorHex
        self.fillColorHex = fillColorHex
        self.strokeWidth = strokeWidth
        self.geodesic = geodesic
        self.zIndex = zIndex
        self.tappable = tappable
        self.holes = holes
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
    /// Z-index for draw ordering.
    public var zIndex: Int
    /// Whether the circle is tappable.
    public var tappable: Bool

    public init(
        id: String = UUID().uuidString,
        center: GoogleMapCoordinate,
        radius: Double,
        strokeColorHex: String = "#000000",
        fillColorHex: String = "#40000000",
        strokeWidth: Float = Float(2.0),
        zIndex: Int = 0,
        tappable: Bool = false
    ) {
        self.id = id
        self.center = center
        self.radius = radius
        self.strokeColorHex = strokeColorHex
        self.fillColorHex = fillColorHex
        self.strokeWidth = strokeWidth
        self.zIndex = zIndex
        self.tappable = tappable
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
    /// Minimum zoom level the camera can be set to.
    public var minZoom: Float?
    /// Maximum zoom level the camera can be set to.
    public var maxZoom: Float?

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
        isBuildingEnabled: Bool = true,
        minZoom: Float? = nil,
        maxZoom: Float? = nil
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
        self.minZoom = minZoom
        self.maxZoom = maxZoom
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

// MARK: - Color Parsing

#if canImport(UIKit) && !SKIP
import UIKit

private func colorFromHex(_ hex: String) -> UIColor {
    var hexStr = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    if hexStr.hasPrefix("#") { hexStr.removeFirst() }
    var rgba: UInt64 = 0
    Scanner(string: hexStr).scanHexInt64(&rgba)
    if hexStr.count == 8 {
        let a = CGFloat((rgba >> 24) & 0xFF) / 255.0
        let r = CGFloat((rgba >> 16) & 0xFF) / 255.0
        let g = CGFloat((rgba >> 8) & 0xFF) / 255.0
        let b = CGFloat(rgba & 0xFF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: a)
    } else {
        let r = CGFloat((rgba >> 16) & 0xFF) / 255.0
        let g = CGFloat((rgba >> 8) & 0xFF) / 255.0
        let b = CGFloat(rgba & 0xFF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}
#endif

// MARK: - GoogleMapView

/// A SwiftUI view that displays a Google Map with markers, polylines, polygons, and circles.
public struct GoogleMapView: View {
    let initialCamera: GoogleMapCameraPosition
    var positionBinding: Binding<GoogleMapPosition>?
    let configuration: GoogleMapConfiguration
    let markers: [GoogleMapMarker]
    let polylines: [GoogleMapPolyline]
    let polygons: [GoogleMapPolygon]
    let circles: [GoogleMapCircle]
    let onMapTap: ((GoogleMapCoordinate) -> Void)?
    let onMapLongPress: ((GoogleMapCoordinate) -> Void)?
    let onMarkerTap: ((GoogleMapMarker) -> Bool)?
    let onMarkerDragEnd: ((GoogleMapMarker, GoogleMapCoordinate) -> Void)?
    let onPolylineTap: ((GoogleMapPolyline) -> Void)?
    let onPolygonTap: ((GoogleMapPolygon) -> Void)?
    let onCircleTap: ((GoogleMapCircle) -> Void)?

    public init(
        initialCamera: GoogleMapCameraPosition = GoogleMapCameraPosition(target: GoogleMapCoordinate(latitude: 37.7749, longitude: -122.4194)),
        position: Binding<GoogleMapPosition>? = nil,
        configuration: GoogleMapConfiguration = GoogleMapConfiguration(),
        markers: [GoogleMapMarker] = [],
        polylines: [GoogleMapPolyline] = [],
        polygons: [GoogleMapPolygon] = [],
        circles: [GoogleMapCircle] = [],
        onMapTap: ((GoogleMapCoordinate) -> Void)? = nil,
        onMapLongPress: ((GoogleMapCoordinate) -> Void)? = nil,
        onMarkerTap: ((GoogleMapMarker) -> Bool)? = nil,
        onMarkerDragEnd: ((GoogleMapMarker, GoogleMapCoordinate) -> Void)? = nil,
        onPolylineTap: ((GoogleMapPolyline) -> Void)? = nil,
        onPolygonTap: ((GoogleMapPolygon) -> Void)? = nil,
        onCircleTap: ((GoogleMapCircle) -> Void)? = nil
    ) {
        self.initialCamera = initialCamera
        self.positionBinding = position
        self.configuration = configuration
        self.markers = markers
        self.polylines = polylines
        self.polygons = polygons
        self.circles = circles
        self.onMapTap = onMapTap
        self.onMapLongPress = onMapLongPress
        self.onMarkerTap = onMarkerTap
        self.onMarkerDragEnd = onMarkerDragEnd
        self.onPolylineTap = onPolylineTap
        self.onPolygonTap = onPolygonTap
        self.onCircleTap = onCircleTap
    }

    #if !SKIP
    public var body: some View {
        #if canImport(GoogleMaps) && os(iOS)
        GoogleMapViewRepresentable(
            initialCamera: initialCamera,
            positionBinding: positionBinding,
            configuration: configuration,
            markers: markers,
            polylines: polylines,
            polygons: polygons,
            circles: circles,
            onMapTap: onMapTap,
            onMapLongPress: onMapLongPress,
            onMarkerTap: onMarkerTap,
            onMarkerDragEnd: onMarkerDragEnd,
            onPolylineTap: onPolylineTap,
            onPolygonTap: onPolygonTap,
            onCircleTap: onCircleTap
        )
        #elseif os(iOS)
        Text("Google Maps iOS SDK not found. Add GoogleMaps to your project dependencies.")
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

        // Sync binding -> camera
        // SKIP INSERT: if (positionBinding != null) {
        // SKIP INSERT:     val boundPos = positionBinding!!.wrappedValue
        // SKIP INSERT:     val ct = cameraPositionState.position.target
        // SKIP INSERT:     if (boundPos.target.latitude != ct.latitude || boundPos.target.longitude != ct.longitude || boundPos.zoom != cameraPositionState.position.zoom) {
        // SKIP INSERT:         cameraPositionState.position = com.google.android.gms.maps.model.CameraPosition.Builder()
        // SKIP INSERT:             .target(com.google.android.gms.maps.model.LatLng(boundPos.target.latitude, boundPos.target.longitude))
        // SKIP INSERT:             .zoom(boundPos.zoom).tilt(boundPos.tilt).bearing(boundPos.bearing).build()
        // SKIP INSERT:     }
        // SKIP INSERT: }

        // Sync camera -> binding
        // SKIP INSERT: if (positionBinding != null && !cameraPositionState.isMoving) {
        // SKIP INSERT:     val cp = cameraPositionState.position
        // SKIP INSERT:     val np = GoogleMapPosition(target = GoogleMapCoordinate(latitude = cp.target.latitude, longitude = cp.target.longitude), zoom = cp.zoom, tilt = cp.tilt, bearing = cp.bearing)
        // SKIP INSERT:     if (np != positionBinding!!.wrappedValue) { positionBinding!!.wrappedValue = np }
        // SKIP INSERT: }

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

        // SKIP INSERT:
        // GoogleMap(
        //     modifier = context.modifier,
        //     cameraPositionState = cameraPositionState,
        //     properties = mapProperties,
        //     uiSettings = mapUiSettings,
        //     onMapClick = { latLng -> onMapTap?.invoke(GoogleMapCoordinate(latitude = latLng.latitude, longitude = latLng.longitude)); Unit },
        //     onMapLongClick = { latLng -> onMapLongPress?.invoke(GoogleMapCoordinate(latitude = latLng.latitude, longitude = latLng.longitude)); Unit }
        // ) {
        //     for (marker in markers) {
        //         val ms = MarkerState(position = com.google.android.gms.maps.model.LatLng(marker.position.latitude, marker.position.longitude))
        //         val icon = marker.hue?.let { com.google.android.gms.maps.model.BitmapDescriptorFactory.defaultMarker(it) }
        //         Marker(
        //             state = ms,
        //             title = marker.title,
        //             snippet = marker.snippet,
        //             alpha = marker.opacity,
        //             draggable = marker.draggable,
        //             flat = marker.flat,
        //             rotation = marker.rotation.toFloat(),
        //             zIndex = marker.zIndex.toFloat(),
        //             anchor = com.google.android.gms.maps.model.LatLng(marker.anchorX.toDouble(), marker.anchorY.toDouble()).let { androidx.compose.ui.geometry.Offset(marker.anchorX, marker.anchorY) },
        //             icon = icon,
        //             onClick = { onMarkerTap?.invoke(marker) ?: false },
        //             onInfoWindowLongClick = { },
        //             tag = marker.id
        //         )
        //     }
        //     for (polyline in polylines) {
        //         Polyline(
        //             points = polyline.points.map { com.google.android.gms.maps.model.LatLng(it.latitude, it.longitude) }.toList(),
        //             color = androidx.compose.ui.graphics.Color(android.graphics.Color.parseColor(polyline.strokeColorHex)),
        //             width = polyline.strokeWidth,
        //             geodesic = polyline.geodesic,
        //             clickable = polyline.tappable,
        //             zIndex = polyline.zIndex.toFloat(),
        //             onClick = { onPolylineTap?.invoke(polyline); Unit }
        //         )
        //     }
        //     for (polygon in polygons) {
        //         Polygon(
        //             points = polygon.points.map { com.google.android.gms.maps.model.LatLng(it.latitude, it.longitude) }.toList(),
        //             holes = polygon.holes.map { hole -> hole.map { com.google.android.gms.maps.model.LatLng(it.latitude, it.longitude) }.toList() }.toList(),
        //             strokeColor = androidx.compose.ui.graphics.Color(android.graphics.Color.parseColor(polygon.strokeColorHex)),
        //             fillColor = androidx.compose.ui.graphics.Color(android.graphics.Color.parseColor(polygon.fillColorHex)),
        //             strokeWidth = polygon.strokeWidth,
        //             geodesic = polygon.geodesic,
        //             clickable = polygon.tappable,
        //             zIndex = polygon.zIndex.toFloat(),
        //             onClick = { onPolygonTap?.invoke(polygon); Unit }
        //         )
        //     }
        //     for (circle in circles) {
        //         Circle(
        //             center = com.google.android.gms.maps.model.LatLng(circle.center.latitude, circle.center.longitude),
        //             radius = circle.radius,
        //             strokeColor = androidx.compose.ui.graphics.Color(android.graphics.Color.parseColor(circle.strokeColorHex)),
        //             fillColor = androidx.compose.ui.graphics.Color(android.graphics.Color.parseColor(circle.fillColorHex)),
        //             strokeWidth = circle.strokeWidth,
        //             clickable = circle.tappable,
        //             zIndex = circle.zIndex.toFloat(),
        //             onClick = { onCircleTap?.invoke(circle); Unit }
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

// MARK: - View Modifiers for Composability

extension GoogleMapView {
    /// Return a new GoogleMapView with additional markers appended.
    public func mapMarkers(_ newMarkers: [GoogleMapMarker]) -> GoogleMapView {
        var copy = self
        // SKIP REPLACE: val combined = copy.markers.toMutableList(); combined.addAll(newMarkers.toList()); return GoogleMapView(initialCamera = copy.initialCamera, position = copy.positionBinding, configuration = copy.configuration, markers = skip.lib.Array(combined), polylines = copy.polylines, polygons = copy.polygons, circles = copy.circles, onMapTap = copy.onMapTap, onMapLongPress = copy.onMapLongPress, onMarkerTap = copy.onMarkerTap, onMarkerDragEnd = copy.onMarkerDragEnd, onPolylineTap = copy.onPolylineTap, onPolygonTap = copy.onPolygonTap, onCircleTap = copy.onCircleTap)
        return GoogleMapView(initialCamera: copy.initialCamera, position: copy.positionBinding, configuration: copy.configuration, markers: copy.markers + newMarkers, polylines: copy.polylines, polygons: copy.polygons, circles: copy.circles, onMapTap: copy.onMapTap, onMapLongPress: copy.onMapLongPress, onMarkerTap: copy.onMarkerTap, onMarkerDragEnd: copy.onMarkerDragEnd, onPolylineTap: copy.onPolylineTap, onPolygonTap: copy.onPolygonTap, onCircleTap: copy.onCircleTap)
    }

    /// Return a new GoogleMapView with additional polylines appended.
    public func mapPolylines(_ newPolylines: [GoogleMapPolyline]) -> GoogleMapView {
        return GoogleMapView(initialCamera: initialCamera, position: positionBinding, configuration: configuration, markers: markers, polylines: polylines + newPolylines, polygons: polygons, circles: circles, onMapTap: onMapTap, onMapLongPress: onMapLongPress, onMarkerTap: onMarkerTap, onMarkerDragEnd: onMarkerDragEnd, onPolylineTap: onPolylineTap, onPolygonTap: onPolygonTap, onCircleTap: onCircleTap)
    }

    /// Return a new GoogleMapView with additional polygons appended.
    public func mapPolygons(_ newPolygons: [GoogleMapPolygon]) -> GoogleMapView {
        return GoogleMapView(initialCamera: initialCamera, position: positionBinding, configuration: configuration, markers: markers, polylines: polylines, polygons: polygons + newPolygons, circles: circles, onMapTap: onMapTap, onMapLongPress: onMapLongPress, onMarkerTap: onMarkerTap, onMarkerDragEnd: onMarkerDragEnd, onPolylineTap: onPolylineTap, onPolygonTap: onPolygonTap, onCircleTap: onCircleTap)
    }

    /// Return a new GoogleMapView with additional circles appended.
    public func mapCircles(_ newCircles: [GoogleMapCircle]) -> GoogleMapView {
        return GoogleMapView(initialCamera: initialCamera, position: positionBinding, configuration: configuration, markers: markers, polylines: polylines, polygons: polygons, circles: circles + newCircles, onMapTap: onMapTap, onMapLongPress: onMapLongPress, onMarkerTap: onMarkerTap, onMarkerDragEnd: onMarkerDragEnd, onPolylineTap: onPolylineTap, onPolygonTap: onPolygonTap, onCircleTap: onCircleTap)
    }
}

// MARK: - iOS UIViewRepresentable Implementation

#if canImport(GoogleMaps) && os(iOS) && !SKIP

struct GoogleMapViewRepresentable: UIViewRepresentable {
    let initialCamera: GoogleMapCameraPosition
    var positionBinding: Binding<GoogleMapPosition>?
    let configuration: GoogleMapConfiguration
    let markers: [GoogleMapMarker]
    let polylines: [GoogleMapPolyline]
    let polygons: [GoogleMapPolygon]
    let circles: [GoogleMapCircle]
    let onMapTap: ((GoogleMapCoordinate) -> Void)?
    let onMapLongPress: ((GoogleMapCoordinate) -> Void)?
    let onMarkerTap: ((GoogleMapMarker) -> Bool)?
    let onMarkerDragEnd: ((GoogleMapMarker, GoogleMapCoordinate) -> Void)?
    let onPolylineTap: ((GoogleMapPolyline) -> Void)?
    let onPolygonTap: ((GoogleMapPolygon) -> Void)?
    let onCircleTap: ((GoogleMapCircle) -> Void)?

    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition(
            latitude: initialCamera.target.latitude,
            longitude: initialCamera.target.longitude,
            zoom: initialCamera.zoom,
            bearing: CLLocationDirection(initialCamera.bearing),
            viewingAngle: Double(initialCamera.tilt)
        )
        let mapView = GMSMapView(frame: .zero, camera: camera)
        mapView.delegate = context.coordinator
        if let minZoom = configuration.minZoom, let maxZoom = configuration.maxZoom {
            mapView.setMinZoom(minZoom, maxZoom: maxZoom)
        }
        applyConfiguration(to: mapView)
        addOverlays(to: mapView, coordinator: context.coordinator)
        return mapView
    }

    func updateUIView(_ mapView: GMSMapView, context: Context) {
        context.coordinator.parent = self
        applyConfiguration(to: mapView)
        mapView.clear()
        context.coordinator.overlayMap.removeAll()
        addOverlays(to: mapView, coordinator: context.coordinator)

        if let positionBinding = positionBinding {
            let pos = positionBinding.wrappedValue
            let current = mapView.camera
            let targetChanged = abs(pos.target.latitude - current.target.latitude) > 0.00001
                || abs(pos.target.longitude - current.target.longitude) > 0.00001
            let zoomChanged = abs(pos.zoom - current.zoom) > 0.01
            if targetChanged || zoomChanged {
                let newCamera = GMSCameraPosition(
                    latitude: pos.target.latitude,
                    longitude: pos.target.longitude,
                    zoom: pos.zoom,
                    bearing: CLLocationDirection(pos.bearing),
                    viewingAngle: Double(pos.tilt)
                )
                mapView.animate(to: newCamera)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    private func applyConfiguration(to mapView: GMSMapView) {
        switch configuration.mapType {
        case .normal: mapView.mapType = .normal
        case .satellite: mapView.mapType = .satellite
        case .terrain: mapView.mapType = .terrain
        case .hybrid: mapView.mapType = .hybrid
        case .none: mapView.mapType = .none
        }

        mapView.isMyLocationEnabled = configuration.isMyLocationEnabled
        mapView.isTrafficEnabled = configuration.isTrafficEnabled
        mapView.isBuildingsEnabled = configuration.isBuildingEnabled
        mapView.isIndoorEnabled = configuration.isIndoorEnabled

        mapView.settings.compassButton = configuration.isCompassEnabled
        mapView.settings.myLocationButton = configuration.isMyLocationButtonEnabled
        mapView.settings.scrollGestures = configuration.isScrollGesturesEnabled
        mapView.settings.zoomGestures = configuration.isZoomGesturesEnabled
        mapView.settings.tiltGestures = configuration.isTiltGesturesEnabled
        mapView.settings.rotateGestures = configuration.isRotateGesturesEnabled
    }

    private func addOverlays(to mapView: GMSMapView, coordinator: Coordinator) {
        for marker in markers {
            let gmsMarker = GMSMarker()
            gmsMarker.position = CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude)
            gmsMarker.title = marker.title
            gmsMarker.snippet = marker.snippet
            gmsMarker.opacity = marker.opacity
            gmsMarker.isDraggable = marker.draggable
            gmsMarker.isFlat = marker.flat
            gmsMarker.rotation = marker.rotation
            gmsMarker.zIndex = Int32(marker.zIndex)
            gmsMarker.groundAnchor = CGPoint(x: CGFloat(marker.anchorX), y: CGFloat(marker.anchorY))
            gmsMarker.userData = marker.id
            gmsMarker.map = mapView
        }

        for polyline in polylines {
            let path = GMSMutablePath()
            for point in polyline.points {
                path.add(CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude))
            }
            let gmsPolyline = GMSPolyline(path: path)
            gmsPolyline.strokeColor = colorFromHex(polyline.strokeColorHex)
            gmsPolyline.strokeWidth = CGFloat(polyline.strokeWidth)
            gmsPolyline.geodesic = polyline.geodesic
            gmsPolyline.zIndex = Int32(polyline.zIndex)
            gmsPolyline.isTappable = polyline.tappable
            gmsPolyline.map = mapView
            coordinator.overlayMap[ObjectIdentifier(gmsPolyline)] = polyline.id
        }

        for polygon in polygons {
            let path = GMSMutablePath()
            for point in polygon.points {
                path.add(CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude))
            }
            let gmsPolygon = GMSPolygon(path: path)
            gmsPolygon.strokeColor = colorFromHex(polygon.strokeColorHex)
            gmsPolygon.fillColor = colorFromHex(polygon.fillColorHex)
            gmsPolygon.strokeWidth = CGFloat(polygon.strokeWidth)
            gmsPolygon.geodesic = polygon.geodesic
            gmsPolygon.zIndex = Int32(polygon.zIndex)
            gmsPolygon.isTappable = polygon.tappable
            if !polygon.holes.isEmpty {
                gmsPolygon.holes = polygon.holes.map { hole in
                    let holePath = GMSMutablePath()
                    for point in hole {
                        holePath.add(CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude))
                    }
                    return holePath
                }
            }
            gmsPolygon.map = mapView
            coordinator.overlayMap[ObjectIdentifier(gmsPolygon)] = polygon.id
        }

        for circle in circles {
            let gmsCircle = GMSCircle(
                position: CLLocationCoordinate2D(latitude: circle.center.latitude, longitude: circle.center.longitude),
                radius: circle.radius
            )
            gmsCircle.strokeColor = colorFromHex(circle.strokeColorHex)
            gmsCircle.fillColor = colorFromHex(circle.fillColorHex)
            gmsCircle.strokeWidth = CGFloat(circle.strokeWidth)
            gmsCircle.zIndex = Int32(circle.zIndex)
            gmsCircle.isTappable = circle.tappable
            gmsCircle.map = mapView
            coordinator.overlayMap[ObjectIdentifier(gmsCircle)] = circle.id
        }
    }

    class Coordinator: NSObject, @preconcurrency GMSMapViewDelegate {
        var parent: GoogleMapViewRepresentable
        var overlayMap: [ObjectIdentifier: String] = [:]

        init(parent: GoogleMapViewRepresentable) {
            self.parent = parent
        }

        @MainActor func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
            parent.onMapTap?(GoogleMapCoordinate(latitude: coordinate.latitude, longitude: coordinate.longitude))
        }

        @MainActor func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
            parent.onMapLongPress?(GoogleMapCoordinate(latitude: coordinate.latitude, longitude: coordinate.longitude))
        }

        @MainActor func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            guard let markerId = marker.userData as? String else { return false }
            if let matchedMarker = parent.markers.first(where: { $0.id == markerId }) {
                return parent.onMarkerTap?(matchedMarker) ?? false
            }
            return false
        }

        @MainActor func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
            guard let markerId = marker.userData as? String else { return }
            if let matchedMarker = parent.markers.first(where: { $0.id == markerId }) {
                let newCoord = GoogleMapCoordinate(latitude: marker.position.latitude, longitude: marker.position.longitude)
                parent.onMarkerDragEnd?(matchedMarker, newCoord)
            }
        }

        @MainActor func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
            guard let overlayId = overlayMap[ObjectIdentifier(overlay)] else { return }
            if overlay is GMSPolyline {
                if let matched = parent.polylines.first(where: { $0.id == overlayId }) {
                    parent.onPolylineTap?(matched)
                }
            } else if overlay is GMSPolygon {
                if let matched = parent.polygons.first(where: { $0.id == overlayId }) {
                    parent.onPolygonTap?(matched)
                }
            } else if overlay is GMSCircle {
                if let matched = parent.circles.first(where: { $0.id == overlayId }) {
                    parent.onCircleTap?(matched)
                }
            }
        }

        @MainActor func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
            guard let binding = parent.positionBinding else { return }
            let newPos = GoogleMapPosition(
                target: GoogleMapCoordinate(latitude: position.target.latitude, longitude: position.target.longitude),
                zoom: position.zoom,
                tilt: Float(position.viewingAngle),
                bearing: Float(position.bearing)
            )
            if newPos != binding.wrappedValue {
                binding.wrappedValue = newPos
            }
        }
    }
}

#endif

#endif
