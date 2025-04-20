//
//  widget.swift
//  widget
//
//  Created by Drew Goldstein on 4/20/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

/// Lock‑screen / Dynamic‑Island UI for the commute Live Activity.
struct widgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: widgetAttributes.self) { ctx in
            VStack(alignment: .leading, spacing: 8) {
                // Big countdown left, icon right
                HStack(alignment: .top, spacing: 8) {
                    Text("\(ctx.state.minutes)m")
                        .font(.system(size: 56, weight: .semibold))
                        .monospacedDigit()
                    Spacer()
                    Image(systemName: "car.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .padding(.top, 10)
                }
                .padding(.top, 10)   // add top padding
                
                // Recommended speed row
                HStack(spacing: 4) {
                    Image(systemName: "speedometer")
                    Text("32 mph • ±2 min")   // TODO: replace with ctx.state.targetSpeed and buffer when model is ready
                        .font(.title3.weight(.semibold))
                }
                .padding(.top, 6)
                

                // Slim capsule progress bar (below speed row)
                ProgressView(value: Double(ctx.state.minutes), total: 20)
                    .progressViewStyle(.linear)
                    .tint(.accentColor)
                    .frame(height: 4)
                    .clipShape(Capsule())
                    .padding(.top, 2)   // moved up 8 px from previous position

                // Context row
                HStack {
                    Text(ctx.attributes.crossingName)
                    Spacer()
                    Text(ctx.state.summary)
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.bottom, 34)

            }
            .frame(maxWidth: .infinity, minHeight: 160)
            .padding(.top, 12)       // no bottom padding, so bar sits higher
            .padding(.horizontal)
        } dynamicIsland: { ctx in
            DynamicIsland {
                // Expanded presentation – replicate lock‑screen stack
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading, spacing: 6) {
                        // Countdown + icon
                        HStack(alignment: .top, spacing: 8) {
                            Text("\(ctx.state.minutes)m")
                                .font(.system(size: 40, weight: .semibold))
                                .monospacedDigit()
                            Spacer()
                            Image(systemName: "car.fill")
                                .font(.system(size: 18, weight: .semibold))
                        }

                        // Speed row
                        HStack(spacing: 4) {
                            Image(systemName: "speedometer")
                            Text("32 mph • ±2 min")
                                .font(.footnote.weight(.semibold))
                        }

                        // Progress bar
                        ProgressView(value: Double(ctx.state.minutes), total: 20)
                            .progressViewStyle(.linear)
                            .tint(.accentColor)
                            .frame(height: 3)
                            .clipShape(Capsule())

                        // Context row
                        HStack {
                            Text(ctx.attributes.crossingName)
                            Spacer()
                            Text(ctx.state.summary)
                        }
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        
                    }
                    .padding(.bottom, 12)
                }
            } compactLeading: {
                Image(systemName: "car.fill")
            } compactTrailing: {
                Text("\(ctx.state.minutes)m")
                    .monospacedDigit()
            } minimal: {
                Text("\(ctx.state.minutes)m")
                    .monospacedDigit()
            }
        }
    }
}
