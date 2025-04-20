//
//  widget.swift
//  widget
//
//  Created by Drew Goldstein on 4/20/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

/// Widget‑bundle entry‑point (lower‑case “widget” as requested).
@main
struct widget: WidgetBundle {
    var body: some Widget {
        CommuteQuickStartWidget()
        widgetLiveActivity()
    }
}
