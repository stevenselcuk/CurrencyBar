//
//  ManagementPanel.swift
//  YouBar
//
//  Created by Steven J. Selcuk on 16.08.2022.
//

import ServiceManagement
import SwiftUI

let storage = UserDefaults.standard

struct ManagementPanel: View {
    var data = PersistenceProvider.default
    @State private var observer1: Any? = nil
    @State private var observer2: Any? = nil
    @ObservedObject var manager = Manager.share

    var formatter: NumberFormatter = {
        let formatter = NumberFormatter()

        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    @State var addNewAsset: Bool = false
    @State var showingSettings: Bool = false

    @State var selectedBaseCountry: Country = Countries.all[235]
    @State var selectedTargetCountry: Country = Countries.all[234]

    @State var originCurrency: String = ""
    @State var targetCurrency: String = ""
    @State var amount: Decimal? = 0.0

    @State var showInMenubar: Bool = true

    @ObservedObject private var currencyManager = CurrencyManager(
        amount: 0,
        locale: .init(identifier: "en_US")
    )
    

    
    @State var launchAtLogin: Bool = storage.bool(forKey: "launchAtLogin")
   
    
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 0) {
                Text("🍸 CurrencyBar")
                    .fontRegular(size: 14)
                    .padding()
                Spacer()
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 12, height: 12, alignment: .center)
                    .padding()
                    .onTapGesture {
                        addNewAsset = true
                    }
                    .popover(isPresented: $addNewAsset) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Picker("Base", selection: $selectedBaseCountry) {
                                    ForEach(Countries.all, id: \.self) {
                                        Text("\(($0.flag ?? "") + $0.currency)")
                                    }
                                }
                                .onChange(of: selectedBaseCountry, perform: { newVal in
                                    currencyManager.formatter = NumberFormatter(numberStyle: .currency, locale: CountryHelper.locale(for: newVal.alpha2))
                                    currencyManager.updateID = UUID()
                                })
                                Picker("Target", selection: $selectedTargetCountry) {
                                    ForEach(Countries.all, id: \.self) {
                                        Text("\(($0.flag ?? "") + $0.currency)")
                                    }
                                }
                                Spacer()
                                Toggle("Add menubar", isOn: $showInMenubar)
                                    .fontRegular(size: 12)
                            }

                            Divider()
                            
                            TextField(currencyManager.string, text: $currencyManager.string)
                                .multilineTextAlignment(.leading)
                                .onChange(of: currencyManager.string, perform: currencyManager.valueChanged)
                                .textFieldStyle(PlainTextFieldStyle())
                                .background(.clear)
                                .fontRegular(size: 32)
                                .id(currencyManager.updateID)
                                .onSubmit {
                                    if selectedTargetCountry == selectedBaseCountry { return }
                                    if currencyManager.string.isEmpty || currencyManager.amount <= 0.0 { return }
                                    let asset = Asset(context: data.context)
                                    asset.id = UUID()

                                    asset.originalCurrencyRaw = selectedBaseCountry.currency
                                    asset.targetCurrencyRaw = selectedTargetCountry.currency

                                    asset.originalCurrency = Currency(code: selectedBaseCountry.currency)
                                    asset.targetCurrency = Currency(code: selectedTargetCountry.currency)
                                
                                   
                                    asset.originAmountRaw = (currencyManager.amount) as NSDecimalNumber
                                    asset.addMenubar = showInMenubar
                                    try? data.context.save()
                                    CurrencyConverter.default.convert(baseCurrency: selectedBaseCountry.currency, toConvert: selectedTargetCountry.currency, amount:  currencyManager.amount.doubleValue, completion: { val in
                                        asset.targetAmountRaw = Decimal(val).asDecimalNumber
                                        asset.oldTargetAmount = Money(amount: val, in: Currency(code: selectedTargetCountry.currency))
                                        asset.targetAmount = Money(amount: val, in: Currency(code: selectedTargetCountry.currency))
                                        try? data.context.save()
                                    })
                                    try? data.context.save()

                                    showInMenubar = true
                                }
                        }

                        .padding(.all, 10)
                        .frame(minWidth: 320, maxWidth: .infinity, minHeight: 90, maxHeight: .infinity, alignment: .topLeading)
                    }
            }

            AssetList()
            HStack {
                Image(systemName: "gear")
                    .padding()
                    .onTapGesture {
                        showingSettings = true
                    }
                    .popover(isPresented: $showingSettings) {
                        VStack(alignment: .leading, spacing: 20) {
                            HStack(alignment: .center, spacing: 0) {
                                Text("Check Every")
                                    .fontRegular(size: 12)
                                Spacer()
                                Stepper {
                                    Text("\(String(format: "%.0f", manager.checkInterval / 60 / 60)) hr. ")
                                } onIncrement: {
                                    manager.checkInterval += 60 * 60
                                    storage.set(manager.checkInterval, forKey: "checkInterval")
                                } onDecrement: {
                                    if manager.checkInterval > 60 * 60 * 1 {
                                        manager.checkInterval -= 60 * 60
                                        storage.set(manager.checkInterval, forKey: "checkInterval")
                                    }
                                }
                                .fontRegular(size: 12)
                            }

                            HStack(alignment: .center, spacing: 0) {
                                Text("Launch at login")
                                    .fontRegular(size: 12)
                                Spacer()
                                Toggle("", isOn: $launchAtLogin)
                                    .onChange(of: launchAtLogin) { newValue in
                                        SMLoginItemSetEnabled(Constants.helperBundleID as CFString,
                                                              launchAtLogin)
                                        print(newValue.description)
                                        print(launchAtLogin)
                                        storage.set(newValue.description, forKey: "launchAtLogin")
                                    }
                                    .fontRegular(size: 12)
                            }

                            HStack {
                                Text("Bug or feature?")
                                    .fontRegular(size: 12)
                                Spacer()
                                Button(action: {
                                    let uri = "https://twitter.com/hevalandsteven"
                                    if let url = URL(string: uri) {
                                        NSWorkspace.shared.open(url)
                                    }
                                }, label: {
                                    Text("Tell me")
                                        .fontRegular(size: 12)
                                })
                            }
                        }.padding(.all, 10)
                            .frame(minWidth: 160, maxWidth: .infinity, minHeight: 90, maxHeight: .infinity, alignment: .topLeading)
                    }
                Spacer()
                Text("")
                    .fontMonoMedium(size: 12)
                    .padding()

                Spacer()
                Image(systemName: "power")
                    .fontBold(size: 12)
                    .onTapGesture {
                        Manager.quitApp()
                    }
                    .padding()
            }.border(width: 1, edges: [.top], color: Color.gray.opacity(0.1))
        }
        .frame(width: 240, height: 380, alignment: .center)
        .onAppear(perform: {
            observer1 = NotificationCenter.default.addObserver(forName: NSWindow.didResignKeyNotification, object: nil, queue: OperationQueue.main) { _ in
                (NSApp.delegate as! AppDelegate).closeManagementPanelWindow()
            }

            observer2 = NotificationCenter.default.addObserver(forName: NSWindow.didResignMainNotification, object: nil, queue: OperationQueue.main) { _ in
                (NSApp.delegate as! AppDelegate).closeManagementPanelWindow()
            }
        })
        .onDisappear(perform: {
            NotificationCenter.default.removeObserver(observer1 as Any)
            NotificationCenter.default.removeObserver(observer2 as Any)
        })
    }
}
