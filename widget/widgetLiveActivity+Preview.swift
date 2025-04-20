//
//  widgetLiveActivity+Preview.swift
//  commute
//
//  Created by Drew Goldstein on 4/20/25.
//

#if DEBUG
import SwiftUI
import ActivityKit
import WidgetKit

// MARK: - Sample data for the canvas

extension widgetAttributes {
    /// A fixed sample you'll see in the preview canvas.
    static var preview: widgetAttributes {
        widgetAttributes(crossingName: "Broward Blvd")
    }
}

extension widgetAttributes.ContentState {
    static var sample: widgetAttributes.ContentState {
        .init(minutes: 4,
              summary: "⏱️ Broward Blvd in 4 min – clear")
    }
}

// MARK: - Previews

/// Lock‑screen / StandBy presentation
#Preview("Lock‑Screen", as: .content, using: widgetAttributes.preview) {
    widgetLiveActivity()
} contentStates: {
    widgetAttributes.ContentState.sample
}

/// Dynamic‑Island (expanded) presentation
#Preview("Dynamic Island", as: .dynamicIsland(.expanded), using: widgetAttributes.preview) {
    widgetLiveActivity()
} contentStates: {
    widgetAttributes.ContentState.sample
}
#endif
