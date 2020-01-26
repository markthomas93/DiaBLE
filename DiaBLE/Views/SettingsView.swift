import Foundation
import SwiftUI


struct SettingsView: View {
    @EnvironmentObject var app: App
    @EnvironmentObject var settings: Settings

    var body: some View {

        NavigationView {
            VStack {

                Spacer()

                VStack(spacing: 20) {
                    VStack {
                        HStack {
                            Button(action: {} ) { Image("Bluetooth").resizable().frame(width: 32, height: 32).foregroundColor(.accentColor)
                            }
                            Picker(selection: $settings.preferredTransmitter, label: Text("Preferred")) {
                                ForEach(TransmitterType.allCases) { t in
                                    Text(t.name).tag(t)
                                }
                            }.pickerStyle(SegmentedPickerStyle())
                        }
                        TextField("device name pattern", text: $settings.preferredDevicePattern).foregroundColor(.accentColor)
                        }

                    HStack  {
                        Image(systemName: "clock.fill").foregroundColor(.white)
                        Picker(selection: $settings.preferredWatch, label: Text("Preferred")) {
                            ForEach(WatchType.allCases) { t in
                                Text(t.name).tag(t)
                            }
                        }.pickerStyle(SegmentedPickerStyle())
                }
                        Button(action: {
                            _ = self.settings.preferredWatch
                        }) {
                            Text(" Details ").bold().padding(2).overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.accentColor, lineWidth: 2))
                        }.disabled(self.settings.preferredWatch == .none)
                    }

                Spacer()

                HStack {
                    Stepper(value: $settings.readingInterval,
                            in: settings.preferredTransmitter == .miaomiao || (settings.preferredTransmitter == .none && app.transmitter != nil && app.transmitter.type == .transmitter(.miaomiao)) ?
                                1 ... 5 : 1 ... 15,
                            step: settings.preferredTransmitter == .miaomiao || (settings.preferredTransmitter == .none && app.transmitter != nil && app.transmitter.type == .transmitter(.miaomiao)) ?
                                2 : 1,
                            label: {
                                Image(systemName: "timer").resizable().frame(width: 32, height: 32)
                                Text(" \(settings.readingInterval) min") })
                }
                .foregroundColor(.orange)
                .padding(.horizontal, 80)

                Spacer()

                Button(action: {
                    let transmitter = self.app.transmitter
                    self.app.selectedTab = self.settings.preferredDevicePattern.isEmpty ? .monitor : .log
                    let centralManager = self.app.main.centralManager
                    if transmitter != nil {
                        centralManager.cancelPeripheralConnection(transmitter!.peripheral!)
                    }
                    if centralManager.state == .poweredOn {
                        centralManager.scanForPeripherals(withServices: nil, options: nil)
                    }
                    if let healthKit = self.app.main.healthKit { healthKit.read() }
                }
                ) { Text(" Rescan ").bold().padding(2).overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.accentColor, lineWidth: 2)) }

                Spacer()

                VStack {
                    VStack(spacing: 0) {
                        Image(systemName: "hand.thumbsup.fill").foregroundColor(.green).padding(4)
                        Text("\(String(format: "%3d", Int(settings.targetLow))) - \(Int(settings.targetHigh))").foregroundColor(.green)
                        HStack {
                            Slider(value: $settings.targetLow,  in: 40 ... 99, step: 1)
                            Slider(value: $settings.targetHigh, in: 140 ... 299, step: 1)
                        }
                    }.accentColor(.green)

                    VStack(spacing: 0) {
                        Image(systemName: "bell.fill").foregroundColor(.red).padding(4)
                        Text("<\(String(format: "%3d", Int(settings.alarmLow)))   > \(Int(settings.alarmHigh))").foregroundColor(.red)
                        HStack {
                            Slider(value: $settings.alarmLow,  in: 40 ... 99, step: 1)
                            Slider(value: $settings.alarmHigh, in: 140 ... 299, step: 1)
                        }
                    }.accentColor(.red)
                }.padding(.horizontal, 40)

                Button(action: {
                    self.settings.mutedAudio.toggle()
                }) {
                    Image(systemName: settings.mutedAudio ? "speaker.slash.fill" : "speaker.2.fill").resizable().frame(width: 24, height: 24).foregroundColor(.accentColor)
                }

                Spacer()

            }
            .font(Font.body.monospacedDigit())
            .navigationBarTitle("DiaBLE  \(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String)  -  Settings", displayMode: .inline)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}


struct SettingsView_Previews: PreviewProvider {
    @EnvironmentObject var app: App
    @EnvironmentObject var info: Info
    @EnvironmentObject var log: Log
    @EnvironmentObject var history: History
    @EnvironmentObject var settings: Settings
    static var previews: some View {
        Group {
            ContentView()
                .environmentObject(App.test(tab: .settings))
                .environmentObject(Info.test)
                .environmentObject(Log())
                .environmentObject(History.test)
                .environmentObject(Settings())
                .environment(\.colorScheme, .dark)
        }
    }
}