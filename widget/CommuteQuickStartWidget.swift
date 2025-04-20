//
//  CommuteQuickStartWidget.swift
//  commute
//
//  Created by Drew Goldstein on 4/20/25.
//

import WidgetKit
import SwiftUI

/// A minimal timeline provider that never refreshes – the widget is only a launch button.
struct QuickStartProvider: TimelineProvider {
    struct Entry: TimelineEntry { let date: Date }

    func placeholder(in context: Context) -> Entry {
        Entry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        completion(Entry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        completion(Timeline(entries: [Entry(date: .now)], policy: .never))
    }
}

struct CommuteQuickStartWidget: Widget {
    let kind = "quickStart"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuickStartProvider()) { _ in
            // iOS 17 interactive button
            Button(intent: StartCommuteIntent()) {
                Image(systemName: "chevron.up.right.dotted.2")
                    .font(.system(size: 32))
                    .symbolRenderingMode(.hierarchical)
            }
            .buttonStyle(.plain)
            .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Start Commute")
        .description("Tap to launch the Live Activity.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular])
    }
}

// MARK: - Previews
#if DEBUG
import ActivityKit   // needed for StartCommuteIntent in preview

#Preview("Quick‑Start", as: .accessoryCircular) {
    CommuteQuickStartWidget()
} timeline: {
    QuickStartProvider.Entry(date: .now)
}
#endif
