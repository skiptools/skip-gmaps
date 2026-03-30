# SkipGMaps

Google Maps for [Skip](https://skip.dev) apps on both iOS and Android.

On Android, this wraps the [Maps Compose](https://github.com/googlemaps/android-maps-compose) library (v8.2) for Jetpack Compose. On iOS, the view displays a placeholder — integrate the [Google Maps iOS SDK](https://github.com/googlemaps/ios-maps-sdk) directly for native iOS maps, or use the built-in `Map` view from MapKit for Apple Maps.

## Setup

Add the dependency to your `Package.swift` file:

```swift
let package = Package(
    name: "my-package",
    products: [
        .library(name: "MyProduct", targets: ["MyTarget"]),
    ],
    dependencies: [
        .package(url: "https://source.skip.dev/skip-gmaps.git", "0.0.0"..<"2.0.0"),
    ],
    targets: [
        .target(name: "MyTarget", dependencies: [
            .product(name: "SkipGMaps", package: "skip-gmaps")
        ])
    ]
)
```

### Android Configuration

Add your Google Maps API key to `AndroidManifest.xml`:

```xml
<application>
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
</application>
```

Get an API key from the [Google Cloud Console](https://console.cloud.google.com/google/maps-apis/credentials) with the Maps SDK for Android enabled.

### iOS Configuration

On iOS, SkipGMaps shows a placeholder. For full Google Maps support on iOS, add the [Google Maps iOS SDK](https://developers.google.com/maps/documentation/ios-sdk/overview) directly to your project and use it via `#if !SKIP` blocks, or use Apple's built-in `Map` view from MapKit.

## Usage

### Basic Map

```swift
import SwiftUI
import SkipGMaps

struct MapScreen: View {
    var body: some View {
        GoogleMapView(
            initialCamera: GoogleMapCameraPosition(
                target: GoogleMapCoordinate(latitude: 37.7749, longitude: -122.4194),
                zoom: Float(12.0)
            )
        )
    }
}
```

### Map with Markers

```swift
GoogleMapView(
    initialCamera: GoogleMapCameraPosition(
        target: GoogleMapCoordinate(latitude: 48.8566, longitude: 2.3522),
        zoom: Float(13.0)
    ),
    markers: [
        GoogleMapMarker(
            position: GoogleMapCoordinate(latitude: 48.8584, longitude: 2.2945),
            title: "Eiffel Tower",
            snippet: "Champ de Mars, Paris",
            hue: GoogleMapMarkerHue.blue
        ),
        GoogleMapMarker(
            position: GoogleMapCoordinate(latitude: 48.8606, longitude: 2.3376),
            title: "Louvre Museum",
            hue: GoogleMapMarkerHue.green
        ),
    ],
    onMarkerTap: { marker in
        print("Tapped: \(marker.title ?? marker.id)")
        return true
    }
)
```

### Drawing Shapes

```swift
GoogleMapView(
    initialCamera: GoogleMapCameraPosition(
        target: GoogleMapCoordinate(latitude: 37.4220, longitude: -122.0841),
        zoom: Float(14.0)
    ),
    polylines: [
        GoogleMapPolyline(
            points: [
                GoogleMapCoordinate(latitude: 37.4220, longitude: -122.0841),
                GoogleMapCoordinate(latitude: 37.4250, longitude: -122.0800),
                GoogleMapCoordinate(latitude: 37.4280, longitude: -122.0860),
            ],
            strokeColorHex: "#FF0000",
            strokeWidth: Float(8.0)
        )
    ],
    polygons: [
        GoogleMapPolygon(
            points: [
                GoogleMapCoordinate(latitude: 37.42, longitude: -122.09),
                GoogleMapCoordinate(latitude: 37.42, longitude: -122.08),
                GoogleMapCoordinate(latitude: 37.43, longitude: -122.08),
                GoogleMapCoordinate(latitude: 37.43, longitude: -122.09),
            ],
            strokeColorHex: "#0000FF",
            fillColorHex: "#400000FF"
        )
    ],
    circles: [
        GoogleMapCircle(
            center: GoogleMapCoordinate(latitude: 37.4220, longitude: -122.0841),
            radius: 200.0,
            strokeColorHex: "#00FF00",
            fillColorHex: "#4000FF00"
        )
    ]
)
```

### Map Configuration

```swift
GoogleMapView(
    initialCamera: GoogleMapCameraPosition(
        target: GoogleMapCoordinate(latitude: 37.7749, longitude: -122.4194),
        zoom: Float(15.0),
        tilt: Float(45.0),
        bearing: Float(90.0)
    ),
    configuration: GoogleMapConfiguration(
        mapType: .hybrid,
        isMyLocationEnabled: true,
        isTrafficEnabled: true,
        isZoomControlsEnabled: true,
        isCompassEnabled: true,
        isBuildingEnabled: true,
        isIndoorEnabled: true
    )
)
```

### Handling Map and Marker Taps

```swift
@State var tappedLocation: GoogleMapCoordinate?

GoogleMapView(
    initialCamera: GoogleMapCameraPosition(
        target: GoogleMapCoordinate(latitude: 37.7749, longitude: -122.4194)
    ),
    markers: myMarkers,
    onMapTap: { coordinate in
        tappedLocation = coordinate
    },
    onMarkerTap: { marker in
        print("Marker: \(marker.title ?? "unknown")")
        return true
    }
)
```

### Marker Colors

```swift
GoogleMapMarker(position: coord, title: "Red", hue: GoogleMapMarkerHue.red)
GoogleMapMarker(position: coord, title: "Blue", hue: GoogleMapMarkerHue.blue)
GoogleMapMarker(position: coord, title: "Green", hue: GoogleMapMarkerHue.green)
GoogleMapMarker(position: coord, title: "Yellow", hue: GoogleMapMarkerHue.yellow)
GoogleMapMarker(position: coord, title: "Orange", hue: GoogleMapMarkerHue.orange)
GoogleMapMarker(position: coord, title: "Cyan", hue: GoogleMapMarkerHue.cyan)
GoogleMapMarker(position: coord, title: "Violet", hue: GoogleMapMarkerHue.violet)
```

## API Reference

### GoogleMapView

| Parameter | Type | Description |
|---|---|---|
| `initialCamera` | `GoogleMapCameraPosition` | Initial camera viewpoint |
| `configuration` | `GoogleMapConfiguration` | Map display and interaction settings |
| `markers` | `[GoogleMapMarker]` | Markers (pins) to display |
| `polylines` | `[GoogleMapPolyline]` | Lines to draw |
| `polygons` | `[GoogleMapPolygon]` | Filled polygons to draw |
| `circles` | `[GoogleMapCircle]` | Circle overlays |
| `onMapTap` | `((GoogleMapCoordinate) -> Void)?` | Called when the map is tapped |
| `onMarkerTap` | `((GoogleMapMarker) -> Bool)?` | Called when a marker is tapped |

### GoogleMapCameraPosition

| Property | Type | Default | Description |
|---|---|---|---|
| `target` | `GoogleMapCoordinate` | — | Center of the camera |
| `zoom` | `Float` | 10.0 | Zoom level (0=world, ~20=building) |
| `tilt` | `Float` | 0.0 | Tilt in degrees |
| `bearing` | `Float` | 0.0 | Bearing clockwise from north |

### GoogleMapConfiguration

| Property | Type | Default | Description |
|---|---|---|---|
| `mapType` | `GoogleMapType` | `.normal` | Tile type (.normal, .satellite, .terrain, .hybrid, .none) |
| `isMyLocationEnabled` | `Bool` | `false` | Show user location (requires permission) |
| `isTrafficEnabled` | `Bool` | `false` | Show traffic layer |
| `isZoomControlsEnabled` | `Bool` | `true` | Zoom buttons |
| `isCompassEnabled` | `Bool` | `true` | Compass indicator |
| `isBuildingEnabled` | `Bool` | `true` | 3D buildings |
| `isIndoorEnabled` | `Bool` | `true` | Indoor maps |

### GoogleMapMarker

| Property | Type | Default | Description |
|---|---|---|---|
| `position` | `GoogleMapCoordinate` | — | Marker location |
| `title` | `String?` | `nil` | Info window title |
| `snippet` | `String?` | `nil` | Info window subtitle |
| `hue` | `Float?` | `nil` | Color hue (0–360), nil for default red |
| `opacity` | `Float` | 1.0 | Opacity (0.0–1.0) |
| `draggable` | `Bool` | `false` | Allow dragging |
| `flat` | `Bool` | `false` | Flat against map surface |

### GoogleMapMarkerHue

Predefined hues: `red` (0), `orange` (30), `yellow` (60), `green` (120), `cyan` (180), `azure` (210), `blue` (240), `violet` (270), `magenta` (300), `rose` (330).

## Limitations

> [!WARNING]
> **iOS**: `GoogleMapView` displays a placeholder on iOS. Integrate the [Google Maps iOS SDK](https://developers.google.com/maps/documentation/ios-sdk/overview) directly via `#if !SKIP` blocks, or use Apple's MapKit `Map` view.

> [!NOTE]
> **Other limitations:**
> - Colors use hex strings (e.g. `"#FF0000"`) for cross-platform compatibility.
> - `Float` values require explicit `Float(value)` syntax for Skip Lite compatibility.
> - Custom marker icons (images) are not yet supported — use the `hue` property for color-coded markers.
> - Camera animation and programmatic camera movement are not yet exposed.
> - Info window customization beyond title/snippet is not yet supported.
> - Ground overlays and tile overlays are not yet wrapped.
> - Clustering (Maps Compose Utils) is not yet exposed.

## Building

This project is a Swift Package Manager module that uses the
[Skip](https://skip.dev) plugin to build the package for both iOS and Android.

Building the module requires that Skip be installed using
[Homebrew](https://brew.sh) with `brew install skiptools/skip/skip`.
This will also install the necessary build prerequisites:
Kotlin, Gradle, and the Android build tools.

## Testing

The module can be tested using the standard `swift test` command
or by running the test target for the macOS destination in Xcode,
which will run the Swift tests as well as the transpiled
Kotlin JUnit tests in the Robolectric Android simulation environment.

Parity testing can be performed with `skip test`,
which will output a table of the test results for both platforms.

## License

This software is licensed under the
[Mozilla Public License 2.0](https://www.mozilla.org/MPL/).
