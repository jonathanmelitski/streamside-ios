//
//  WidgetSettingsView.swift
//  USGS
//
//  Created by Jonathan Melitski on 9/11/25.
//

import SwiftUI
import USGSShared

struct WidgetSettingsView: View {
    @Binding var location: Location
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Graph Settings")
                .font(.title2)
                .bold()
            Divider()
            ForEach(location.metrics, id: \.descriptor.code) { metric in
                let enabled = Binding(get: {
                    location.settings.graphSettings.series.contains { series in
                        series.usgsGraphedElement.code == metric.descriptor.code
                    }
                }, set: { new in
                    if new {
                        withAnimation {
                            location = location.withUpdatedSettings { settings in
                                settings.graphSettings.series.append(.init(usgsGraphedElement: metric.descriptor))
                            }
                        }
                    } else {
                        withAnimation {
                            location = location.withUpdatedSettings { settings in
                                settings.graphSettings.series.removeAll { el in
                                    el.usgsGraphedElement.code == metric.descriptor.code
                                }
                            }
                        }
                    }
                })
                
                let color = Binding<Color>(get: {
                    guard let series = location.settings.graphSettings.series.first(where: { series in
                        series.usgsGraphedElement.code == metric.descriptor.code
                    }) else { return Color.blue }
                    
                    return series.graphForegroundColor.toSwiftUIColor
                }, set: { new in
                    guard let series = location.settings.graphSettings.series.first(where: { series in
                        series.usgsGraphedElement.code == metric.descriptor.code
                    }) else { return }
                    
                    withAnimation {
                        location = location.withUpdatedSettings { settings in
                            let seriesIndex = settings.graphSettings.series.firstIndex(where: { $0.usgsGraphedElement.code == series.usgsGraphedElement.code })!
                            settings.graphSettings.series[seriesIndex].graphForegroundColor = GraphColor(from: new)
                        }
                    }
                })
                
                HStack {
                    Text(metric.descriptor.parsedLabel ?? "")
                    Spacer()
                    if enabled.wrappedValue {
                        ColorPicker("", selection: color)
                    }
                    Toggle(isOn: enabled, label: {})
                }
                .padding(.vertical, 4)
            }
            
            Text("Value Settings")
                .font(.title2)
                .bold()
            Divider()
            ForEach(location.metrics, id: \.descriptor.code) { metric in
                let enabled = Binding(get: {
                    return location.settings.displaySettings.valuesToShow.contains {
                        $0.code == metric.descriptor.code
                    }
                }, set: { new in
                    if new {
                        withAnimation {
                            location = location.withUpdatedSettings { settings in
                                settings.displaySettings.valuesToShow.append(metric.descriptor)
                            }
                        }
                    } else {
                        withAnimation {
                            location = location.withUpdatedSettings { settings in
                                settings.displaySettings.valuesToShow.removeAll {
                                    $0.code == metric.descriptor.code
                                }
                            }
                        }
                    }
                })
                
                HStack {
                    Text(metric.descriptor.parsedLabel ?? "")
                    Spacer()
                    Toggle(isOn: enabled, label: {})
                }
                .padding(.vertical, 4)
            }
        }
        .shadow(radius: 0)
    }
}
