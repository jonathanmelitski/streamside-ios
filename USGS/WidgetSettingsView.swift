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
    @State var editingLabelOverride: DisplaySeries? = nil
    
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
                            settings.graphSettings.series[seriesIndex].graphForegroundColor = CodableColor(from: new)
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
                    return location.settings.displaySettings.series.contains {
                        $0.metric.code == metric.descriptor.code
                    }
                }, set: { new in
                    if new {
                        withAnimation {
                            location = location.withUpdatedSettings { settings in
                                settings.displaySettings.series.append(.init(metric: metric.descriptor))
                            }
                        }
                    } else {
                        withAnimation {
                            location = location.withUpdatedSettings { settings in
                                settings.displaySettings.series.removeAll {
                                    $0.metric.code == metric.descriptor.code
                                }
                            }
                        }
                    }
                })
                
                let editingOverride = Binding<Bool>(get: {
                    guard let editing = self.editingLabelOverride else { return false }
                    return editing.metric.code == metric.descriptor.code
                }, set: { new in
                    guard let metric = location.settings.displaySettings.series.first(where: { $0.metric.code == metric.descriptor.code }), new else {
                        self.editingLabelOverride = nil
                        return
                    }
                    
                    self.editingLabelOverride = metric
                })
                
                let editOverrideText = Binding<String>(get: {
                    guard let series = location.settings.displaySettings.series.first(where: { $0.metric.code == metric.descriptor.code }) else { return metric.descriptorSpecificLabelShort }
                    
                    return series.labelOverride ?? metric.descriptorSpecificLabelShort
                }, set: { new in
                    withAnimation {
                        location = location.withUpdatedSettings { settings in
                            guard let seriesIdx = settings.displaySettings.series.firstIndex(where: { $0.metric.code == metric.descriptor.code }) else { return }
                            settings.displaySettings.series[seriesIdx].labelOverride = new
                        }
                    }
                })
                
                HStack {
                    Text(metric.descriptor.parsedLabel ?? metric.descriptor.name ?? "Unknown Metric")
                    if enabled.wrappedValue {
                        Spacer()
                        Button("Edit Label") {
                            editingOverride.wrappedValue.toggle()
                        }
                        .popover(isPresented: editingOverride) {
                            TextField(text: editOverrideText, prompt: Text("Label"), label: { Text("Label") })
                                .padding()
                                .presentationCompactAdaptation(.popover)
                        }
                    }
                    Toggle(isOn: enabled, label: {})
                }
                .padding(.vertical, 4)
            }
        }
        .shadow(radius: 0)
    }
}
