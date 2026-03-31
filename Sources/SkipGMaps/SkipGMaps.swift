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
///
/// Call this once in your app's initialization, before any `GoogleMapView` is displayed.
///
/// - **iOS**: Calls `GMSServices.provideAPIKey()`.
/// - **Android**: Sets the API key in the application's manifest metadata so the Maps SDK can read it.
///   Alternatively, you can set the key directly in your `AndroidManifest.xml` and skip this call on Android.
///
/// ```swift
/// // In your App.init():
/// GoogleMapsConfiguration.provideAPIKey("YOUR_API_KEY")
/// ```
public enum GoogleMapsConfiguration {
    /// Provide the Google Maps API key for the current platform.
    ///
    /// - Parameter apiKey: Your Google Maps API key.
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
///
/// Use with `@State` and pass as a `Binding` to `GoogleMapView(position:)` to
/// observe the camera as the user pans/zooms, and to programmatically move the camera.
public struct GoogleMapPosition: Equatable {
    /// The center coordinate the camera is pointing at.
    public var target: GoogleMapCoordinate
    /// The zoom level.
    public var zoom: Float
    /// The tilt angle in degrees.
    public var tilt: Float
    /// The bearing (rotation) in degrees clockwise from north.
    public var bearing: Float

    public init(target: GoogleMapCoordinate, zoom: Float = Float(10.0), tilt: Float = Float(0.0), bearing: Float = Float(0.0)) {
        self.target = target
        self.zoom = zoom
        self.tilt = tilt
        self.bearing = bearing
    }

    /// Create from a `GoogleMapCameraPosition`.
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

// MARK: - Color Parsing

#if canImport(UIKit) && !SKIP
import UIKit

/// Parse a hex color string (e.g. "#FF0000" or "#80FF0000") to a UIColor.
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

/// A SwiftUI view that displays a Google Map.
///
/// On iOS, this wraps the Google Maps iOS SDK via UIViewRepresentable.
/// On Android, this wraps `com.google.maps.android:maps-compose` via Jetpack Compose.
///
/// **iOS**: Requires the Google Maps iOS SDK. Add it to your project and call
/// `GMSServices.provideAPIKey("YOUR_API_KEY")` in your app's initialization.
/// If the SDK is not available, a placeholder is shown.
///
/// **Android**: Requires a Google Maps API key in `AndroidManifest.xml`.
public struct GoogleMapView: View {
    let initialCamera: GoogleMapCameraPosition
    var positionBinding: Binding<GoogleMapPosition>?
    let configuration: GoogleMapConfiguration
    let markers: [GoogleMapMarker]
    let polylines: [GoogleMapPolyline]
    let polygons: [GoogleMapPolygon]
    let circles: [GoogleMapCircle]
    let onMapTap: ((GoogleMapCoordinate) -> Void)?
    let onMarkerTap: ((GoogleMapMarker) -> Bool)?

    /// Create a Google Map view.
    ///
    /// - Parameters:
    ///   - initialCamera: The initial camera position (used only on first display).
    ///   - position: An optional binding to a `GoogleMapPosition` that tracks the camera.
    ///     When the user pans/zooms, the binding is updated. When you change the binding
    ///     externally, the camera animates to the new position.
    ///   - configuration: Map display and interaction settings.
    ///   - markers: Markers to display.
    ///   - polylines: Lines to draw.
    ///   - polygons: Filled polygons to draw.
    ///   - circles: Circle overlays.
    ///   - onMapTap: Called when the map background is tapped.
    ///   - onMarkerTap: Called when a marker is tapped. Return `true` to consume.
    public init(
        initialCamera: GoogleMapCameraPosition = GoogleMapCameraPosition(target: GoogleMapCoordinate(latitude: 37.7749, longitude: -122.4194)),
        position: Binding<GoogleMapPosition>? = nil,
        configuration: GoogleMapConfiguration = GoogleMapConfiguration(),
        markers: [GoogleMapMarker] = [],
        polylines: [GoogleMapPolyline] = [],
        polygons: [GoogleMapPolygon] = [],
        circles: [GoogleMapCircle] = [],
        onMapTap: ((GoogleMapCoordinate) -> Void)? = nil,
        onMarkerTap: ((GoogleMapMarker) -> Bool)? = nil
    ) {
        self.initialCamera = initialCamera
        self.positionBinding = position
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
            onMarkerTap: onMarkerTap
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

        // Sync binding -> camera: when the external binding changes, move the camera
        // SKIP INSERT: if (positionBinding != null) {
        // SKIP INSERT:     val boundPos = positionBinding!!.wrappedValue
        // SKIP INSERT:     val currentTarget = cameraPositionState.position.target
        // SKIP INSERT:     val currentZoom = cameraPositionState.position.zoom
        // SKIP INSERT:     if (boundPos.target.latitude != currentTarget.latitude || boundPos.target.longitude != currentTarget.longitude || boundPos.zoom != currentZoom) {
        // SKIP INSERT:         val newCamPos = com.google.android.gms.maps.model.CameraPosition.Builder()
        // SKIP INSERT:             .target(com.google.android.gms.maps.model.LatLng(boundPos.target.latitude, boundPos.target.longitude))
        // SKIP INSERT:             .zoom(boundPos.zoom)
        // SKIP INSERT:             .tilt(boundPos.tilt)
        // SKIP INSERT:             .bearing(boundPos.bearing)
        // SKIP INSERT:             .build()
        // SKIP INSERT:         cameraPositionState.position = newCamPos
        // SKIP INSERT:     }
        // SKIP INSERT: }

        // Sync camera -> binding: when the user moves the camera, update the binding
        // SKIP INSERT: if (positionBinding != null && !cameraPositionState.isMoving) {
        // SKIP INSERT:     val camPos = cameraPositionState.position
        // SKIP INSERT:     val newPos = GoogleMapPosition(
        // SKIP INSERT:         target = GoogleMapCoordinate(latitude = camPos.target.latitude, longitude = camPos.target.longitude),
        // SKIP INSERT:         zoom = camPos.zoom,
        // SKIP INSERT:         tilt = camPos.tilt,
        // SKIP INSERT:         bearing = camPos.bearing
        // SKIP INSERT:     )
        // SKIP INSERT:     if (newPos != positionBinding!!.wrappedValue) {
        // SKIP INSERT:         positionBinding!!.wrappedValue = newPos
        // SKIP INSERT:     }
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
    let onMarkerTap: ((GoogleMapMarker) -> Bool)?

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
        applyConfiguration(to: mapView)
        addOverlays(to: mapView)
        return mapView
    }

    func updateUIView(_ mapView: GMSMapView, context: Context) {
        context.coordinator.parent = self
        applyConfiguration(to: mapView)
        mapView.clear()
        addOverlays(to: mapView)

        // When the position binding changes externally, move the camera
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

    private func addOverlays(to mapView: GMSMapView) {
        for marker in markers {
            let gmsMarker = GMSMarker()
            gmsMarker.position = CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude)
            gmsMarker.title = marker.title
            gmsMarker.snippet = marker.snippet
            gmsMarker.opacity = marker.opacity
            gmsMarker.isDraggable = marker.draggable
            gmsMarker.isFlat = marker.flat
//            if let hue = marker.hue {
//                gmsMarker.icon = GMSMarker.markerImage(with: hue)
//            }
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
            gmsPolyline.map = mapView
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
            gmsPolygon.map = mapView
        }

        for circle in circles {
            let gmsCircle = GMSCircle(
                position: CLLocationCoordinate2D(latitude: circle.center.latitude, longitude: circle.center.longitude),
                radius: circle.radius
            )
            gmsCircle.strokeColor = colorFromHex(circle.strokeColorHex)
            gmsCircle.fillColor = colorFromHex(circle.fillColorHex)
            gmsCircle.strokeWidth = CGFloat(circle.strokeWidth)
            gmsCircle.map = mapView
        }
    }

    class Coordinator: NSObject, @preconcurrency GMSMapViewDelegate {
        var parent: GoogleMapViewRepresentable

        init(parent: GoogleMapViewRepresentable) {
            self.parent = parent
        }

        @MainActor func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
            parent.onMapTap?(GoogleMapCoordinate(latitude: coordinate.latitude, longitude: coordinate.longitude))
        }

        @MainActor func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            guard let markerId = marker.userData as? String else { return false }
            if let matchedMarker = parent.markers.first(where: { $0.id == markerId }) {
                return parent.onMarkerTap?(matchedMarker) ?? false
            }
            return false
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
