// Copyright 2026 Skip
// SPDX-License-Identifier: MPL-2.0

import Testing
import OSLog
import Foundation
@testable import SkipGMaps

let logger: Logger = Logger(subsystem: "SkipGMaps", category: "Tests")

@Suite struct SkipGMapsTests {

    @Test func testSkipGMaps() throws {
    }

    @Test func testCoordinate() throws {
        let coord = GoogleMapCoordinate(latitude: 37.7749, longitude: -122.4194)
        #expect(coord.latitude == 37.7749)
        #expect(coord.longitude == -122.4194)

        // Hashable
        let coord2 = GoogleMapCoordinate(latitude: 37.7749, longitude: -122.4194)
        #expect(coord == coord2)

        let coord3 = GoogleMapCoordinate(latitude: 40.7128, longitude: -74.0060)
        #expect(coord != coord3)
    }

    @Test func testCameraPosition() throws {
        let camera = GoogleMapCameraPosition(
            target: GoogleMapCoordinate(latitude: 37.7749, longitude: -122.4194),
            zoom: Float(15.0),
            tilt: Float(30.0),
            bearing: Float(90.0)
        )
        #expect(camera.target.latitude == 37.7749)
        #expect(camera.zoom == Float(15.0))
        #expect(camera.tilt == Float(30.0))
        #expect(camera.bearing == Float(90.0))

        // Default values
        let defaultCamera = GoogleMapCameraPosition(target: GoogleMapCoordinate(latitude: 0.0, longitude: 0.0))
        #expect(defaultCamera.zoom == Float(10.0))
        #expect(defaultCamera.tilt == Float(0.0))
        #expect(defaultCamera.bearing == Float(0.0))
    }

    @Test func testMarker() throws {
        let marker = GoogleMapMarker(
            position: GoogleMapCoordinate(latitude: 37.7749, longitude: -122.4194),
            title: "San Francisco",
            snippet: "The City by the Bay",
            hue: GoogleMapMarkerHue.blue,
            opacity: Float(0.8),
            draggable: true,
            flat: true
        )
        #expect(marker.title == "San Francisco")
        #expect(marker.snippet == "The City by the Bay")
        #expect(marker.hue == GoogleMapMarkerHue.blue)
        #expect(marker.opacity == Float(0.8))
        #expect(marker.draggable == true)
        #expect(marker.flat == true)
        #expect(!marker.id.isEmpty)

        // Default values
        let defaultMarker = GoogleMapMarker(position: GoogleMapCoordinate(latitude: 0.0, longitude: 0.0))
        #expect(defaultMarker.title == nil)
        #expect(defaultMarker.snippet == nil)
        #expect(defaultMarker.hue == nil)
        #expect(defaultMarker.opacity == Float(1.0))
        #expect(defaultMarker.draggable == false)
        #expect(defaultMarker.flat == false)
    }

    @Test func testPolyline() throws {
        let points = [
            GoogleMapCoordinate(latitude: 37.7749, longitude: -122.4194),
            GoogleMapCoordinate(latitude: 34.0522, longitude: -118.2437)
        ]
        let polyline = GoogleMapPolyline(points: points, strokeColorHex: "#FF0000", strokeWidth: Float(10.0), geodesic: true, zIndex: 5, tappable: true)
        #expect(polyline.points.count == 2)
        #expect(polyline.strokeColorHex == "#FF0000")
        #expect(polyline.strokeWidth == Float(10.0))
        #expect(polyline.geodesic == true)
        #expect(polyline.zIndex == 5)
        #expect(polyline.tappable == true)

        // Test with stroke pattern
        let dashed = GoogleMapPolyline(
            points: points,
            pattern: [.dash(Float(20.0)), .gap(Float(10.0)), .dot, .gap(Float(10.0))]
        )
        #expect(dashed.pattern != nil)
        #expect(dashed.pattern!.count == 4)
    }

    @Test func testPolygon() throws {
        let points = [
            GoogleMapCoordinate(latitude: 37.0, longitude: -122.0),
            GoogleMapCoordinate(latitude: 37.0, longitude: -121.0),
            GoogleMapCoordinate(latitude: 38.0, longitude: -121.0)
        ]
        let hole = [
            GoogleMapCoordinate(latitude: 37.3, longitude: -121.7),
            GoogleMapCoordinate(latitude: 37.3, longitude: -121.5),
            GoogleMapCoordinate(latitude: 37.5, longitude: -121.5)
        ]
        let polygon = GoogleMapPolygon(
            points: points,
            strokeColorHex: "#0000FF",
            fillColorHex: "#800000FF",
            geodesic: true,
            tappable: true,
            holes: [hole]
        )
        #expect(polygon.points.count == 3)
        #expect(polygon.strokeColorHex == "#0000FF")
        #expect(polygon.geodesic == true)
        #expect(polygon.tappable == true)
        #expect(polygon.holes.count == 1)
        #expect(polygon.holes[0].count == 3)
    }

    @Test func testCircle() throws {
        let circle = GoogleMapCircle(
            center: GoogleMapCoordinate(latitude: 37.7749, longitude: -122.4194),
            radius: 1000.0,
            strokeColorHex: "#FF0000",
            fillColorHex: "#40FF0000"
        )
        #expect(circle.center.latitude == 37.7749)
        #expect(circle.radius == 1000.0)
        #expect(circle.strokeColorHex == "#FF0000")
    }

    @Test func testConfiguration() throws {
        let config = GoogleMapConfiguration(
            mapType: .satellite,
            isMyLocationEnabled: true,
            isZoomControlsEnabled: false,
            isTrafficEnabled: true
        )
        #expect(config.mapType == .satellite)
        #expect(config.isMyLocationEnabled == true)
        #expect(config.isZoomControlsEnabled == false)
        #expect(config.isTrafficEnabled == true)
        // Defaults
        #expect(config.isCompassEnabled == true)
        #expect(config.isBuildingEnabled == true)
        #expect(config.isScrollGesturesEnabled == true)

        // Default config
        let defaultConfig = GoogleMapConfiguration()
        #expect(defaultConfig.mapType == .normal)
        #expect(defaultConfig.isMyLocationEnabled == false)
        #expect(defaultConfig.isTrafficEnabled == false)
    }

    @Test func testMapType() throws {
        let types: [GoogleMapType] = [.normal, .satellite, .terrain, .hybrid, .none]
        #expect(types.count == 5)
        #expect(GoogleMapType.normal.rawValue == 0)
        #expect(GoogleMapType.satellite.rawValue == 1)
        #expect(GoogleMapType.terrain.rawValue == 2)
        #expect(GoogleMapType.hybrid.rawValue == 3)
        #expect(GoogleMapType.none.rawValue == 4)
    }

    @Test func testProvideAPIKey() throws {
        // Verify the API exists and compiles; can't test actual initialization without a real key
        if false {
            GoogleMapsConfiguration.provideAPIKey("test-key")
        }
    }

    @Test func testMarkerHueConstants() throws {
        #expect(GoogleMapMarkerHue.red == Float(0.0))
        #expect(GoogleMapMarkerHue.green == Float(120.0))
        #expect(GoogleMapMarkerHue.blue == Float(240.0))
        #expect(GoogleMapMarkerHue.yellow == Float(60.0))
    }

    @Test @MainActor func testGoogleMapViewInit() async throws {
        // Verify the view can be constructed with defaults
        let view = GoogleMapView()
        _ = view

        // Verify full construction
        let fullView = GoogleMapView(
            initialCamera: GoogleMapCameraPosition(
                target: GoogleMapCoordinate(latitude: 48.8566, longitude: 2.3522),
                zoom: Float(12.0)
            ),
            configuration: GoogleMapConfiguration(mapType: .hybrid),
            markers: [
                GoogleMapMarker(position: GoogleMapCoordinate(latitude: 48.8584, longitude: 2.2945), title: "Eiffel Tower")
            ],
            polylines: [],
            polygons: [],
            circles: [
                GoogleMapCircle(center: GoogleMapCoordinate(latitude: 48.8566, longitude: 2.3522), radius: 500.0)
            ],
            onMapTap: { coord in },
            onMarkerTap: { marker in return true }
        )
        _ = fullView
    }

    @Test func testGoogleMapPosition() throws {
        var pos = GoogleMapPosition(
            target: GoogleMapCoordinate(latitude: 37.7749, longitude: -122.4194),
            zoom: Float(12.0),
            tilt: Float(30.0),
            bearing: Float(45.0)
        )
        #expect(pos.target.latitude == 37.7749)
        #expect(pos.zoom == Float(12.0))
        #expect(pos.tilt == Float(30.0))
        #expect(pos.bearing == Float(45.0))

        // Test equality
        let pos2 = GoogleMapPosition(
            target: GoogleMapCoordinate(latitude: 37.7749, longitude: -122.4194),
            zoom: Float(12.0),
            tilt: Float(30.0),
            bearing: Float(45.0)
        )
        #expect(pos == pos2)

        // Test inequality
        pos.zoom = Float(15.0)
        #expect(pos != pos2)

        // Test init from GoogleMapCameraPosition
        let camera = GoogleMapCameraPosition(
            target: GoogleMapCoordinate(latitude: 40.0, longitude: -74.0),
            zoom: Float(8.0)
        )
        let fromCamera = GoogleMapPosition(camera)
        #expect(fromCamera.target.latitude == 40.0)
        #expect(fromCamera.zoom == Float(8.0))

        // Default values
        let defaultPos = GoogleMapPosition(target: GoogleMapCoordinate(latitude: 0.0, longitude: 0.0))
        #expect(defaultPos.zoom == Float(10.0))
        #expect(defaultPos.tilt == Float(0.0))
        #expect(defaultPos.bearing == Float(0.0))
    }

    @Test func testMarkerAdvancedProperties() throws {
        let marker = GoogleMapMarker(
            position: GoogleMapCoordinate(latitude: 37.0, longitude: -122.0),
            rotation: 45.0,
            zIndex: 10,
            anchorX: Float(0.5),
            anchorY: Float(0.5)
        )
        #expect(marker.rotation == 45.0)
        #expect(marker.zIndex == 10)
        #expect(marker.anchorX == Float(0.5))
        #expect(marker.anchorY == Float(0.5))

        // Default anchor
        let defaultMarker = GoogleMapMarker(position: GoogleMapCoordinate(latitude: 0.0, longitude: 0.0))
        #expect(defaultMarker.rotation == 0.0)
        #expect(defaultMarker.zIndex == 0)
        #expect(defaultMarker.anchorX == Float(0.5))
        #expect(defaultMarker.anchorY == Float(1.0))
    }

    @Test func testCircleAdvancedProperties() throws {
        let circle = GoogleMapCircle(
            center: GoogleMapCoordinate(latitude: 37.0, longitude: -122.0),
            radius: 500.0,
            zIndex: 3,
            tappable: true
        )
        #expect(circle.zIndex == 3)
        #expect(circle.tappable == true)

        let defaultCircle = GoogleMapCircle(center: GoogleMapCoordinate(latitude: 0.0, longitude: 0.0), radius: 100.0)
        #expect(defaultCircle.zIndex == 0)
        #expect(defaultCircle.tappable == false)
    }

    @Test func testStrokePatternItems() throws {
        let pattern: [GoogleMapStrokePatternItem] = [
            .dash(Float(20.0)),
            .gap(Float(10.0)),
            .dot,
            .gap(Float(5.0))
        ]
        #expect(pattern.count == 4)
    }

    @Test func testConfigurationZoomLimits() throws {
        let minZ = Float(3.0)
        let maxZ = Float(18.0)
        let config = GoogleMapConfiguration(
            minZoom: minZ,
            maxZoom: maxZ
        )
        #expect(config.minZoom == minZ)
        #expect(config.maxZoom == maxZ)

        let defaultConfig = GoogleMapConfiguration()
        #expect(defaultConfig.minZoom == nil)
        #expect(defaultConfig.maxZoom == nil)
    }
}
