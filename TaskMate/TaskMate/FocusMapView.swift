
import SwiftUI
import MapKit

struct FocusMapView: View {
    @State private var searchText = ""
    @State private var mapItems: [MKMapItem] = []
    @State private var isSearching = false
    @State private var errorMessage: String?

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 6.9271,
                longitude: 79.8612
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.08,
                longitudeDelta: 0.08
            )
        )
    )

    private let blue = Color(
        red: 0.20,
        green: 0.40,
        blue: 0.90
    )

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Find your focus spot.")
                        .font(.title2.bold())

                    Text("Discover places to study, work or take a break.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)

                        TextField(
                            "Search libraries, cafés...",
                            text: $searchText
                        )
                        .submitLabel(.search)
                        .onSubmit {
                            searchPlaces()
                        }

                        Button(action: searchPlaces) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title2)
                                .foregroundStyle(blue)
                        }
                        .disabled(
                            searchText.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            ).isEmpty || isSearching
                        )
                    }
                    .padding(14)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(16)

                ZStack {
                    Map(position: $cameraPosition) {
                        ForEach(
                            Array(mapItems.enumerated()),
                            id: \.offset
                        ) { entry in
                            Marker(
                                entry.element.name ?? "Place",
                                coordinate:
                                    entry.element.placemark.coordinate
                            )
                        }
                    }
                    .mapStyle(.standard(elevation: .flat))

                    if isSearching {
                        ProgressView("Searching places...")
                            .padding(18)
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding()
                }

                if !mapItems.isEmpty {
                    List {
                        ForEach(
                            Array(mapItems.enumerated()),
                            id: \.offset
                        ) { entry in
                            Button {
                                let coordinate =
                                    entry.element.placemark.coordinate

                                cameraPosition = .region(
                                    MKCoordinateRegion(
                                        center: coordinate,
                                        span: MKCoordinateSpan(
                                            latitudeDelta: 0.015,
                                            longitudeDelta: 0.015
                                        )
                                    )
                                )
                            } label: {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(
                                        entry.element.name ?? "Place"
                                    )
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                    Text(
                                        entry.element.placemark.title
                                        ?? "Address unavailable"
                                    )
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .frame(maxHeight: 200)
                }
            }
            .background(
                Color(red: 0.95, green: 0.96, blue: 0.99)
            )
            .navigationTitle("Focus Map")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func searchPlaces() {
        let query = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !query.isEmpty else { return }

        isSearching = true
        errorMessage = nil

        var request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query

        if let region = cameraPosition.region {
            request.region = region
        } else {
            request.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: 6.9271,
                    longitude: 79.8612
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: 0.15,
                    longitudeDelta: 0.15
                )
            )
        }

        MKLocalSearch(request: request).start { response, error in
            DispatchQueue.main.async {
                isSearching = false

                if let error {
                    errorMessage = error.localizedDescription
                    return
                }

                mapItems = response?.mapItems ?? []

                if mapItems.isEmpty {
                    errorMessage = "No places found. Try another search."
                }

                if let first = mapItems.first {
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: first.placemark.coordinate,
                            span: MKCoordinateSpan(
                                latitudeDelta: 0.06,
                                longitudeDelta: 0.06
                            )
                        )
                    )
                }
            }
        }
    }
}
