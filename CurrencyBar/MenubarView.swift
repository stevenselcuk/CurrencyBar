//
//  MenubarView.swift
//  YouBar
//
//  Created by Steven J. Selcuk on 16.08.2022.
//

import SwiftUI

struct MenubarView: View {
    @ObservedObject var manager = Manager.share
    let timer = Timer.publish(every: TimeInterval(Manager.share.checkInterval), on: .main, in: .common).autoconnect()
    var data = PersistenceProvider.default

    @FetchRequest(sortDescriptors: [SortDescriptor(\.lastUpdate)], predicate: NSPredicate(format: "addMenubar == %@", NSNumber(value: true)))
    var assets: FetchedResults<Asset>

    @State var isConnected: Bool = true
    @State var updateID: UUID = UUID()
    var body: some View {
        if assets.count < 1 {
            Text("🍸 CurrencyBar")
                .fontRegular(size: 14)
                .padding(.all, 3)
                .frame(width: 115, height: 20, alignment: .center)
        } else if isConnected == true {
            LazyHStack(alignment: .center, spacing: 0) {
                ForEach(assets, id: \.self) { asset in
                    HStack(alignment: .center, spacing: 6) {
                        HStack(alignment: .center, spacing: 3) {
                            Image(systemName: asset.trend ?? "circle.fill")
                                .resizable()
                                .foregroundColor(asset.trend == "arrowtriangle.up.fill" ? .green : asset.trend == "arrowtriangle.down.fill" ? .red : .yellow)
                                .frame(width: 8, height: 8)
                            Text(asset.targetAmount.formattedString ?? "$0.0")
                                .fontMonoMedium(color: .white, size: 12)
                                
                        }.padding(.all, 3)
                            .background(Color.gray.opacity(0.4))
                            .cornerRadius(3)
                            .padding(.vertical, 3)
                      /*  Text(asset.originalAmount.formattedString ?? "£0.0")
                            .fontMonoMedium(color: .white, size: 8)
                            .truncationMode(.tail)
                            .lineLimit(1)
                            .fixedSize(horizontal: false, vertical: false)*/
                    }.padding(.horizontal, 5)
                   
                    /*  if index < assets.count - 1 {
                       Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 4, height: 4)
                        Text("")
                            .opacity(0.3)
                    }*/
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
            .id(updateID)
           // .frame(width: CGFloat(assets.count) * 100, height: 20, alignment: .center)
                .onReceive(timer) { _ in
                    isConnected = Reachability.isConnectedToNetwork()
                    for asset in assets {
                        CurrencyConverter.default.convert(baseCurrency: asset.originalCurrencyRaw!, toConvert: asset.targetCurrencyRaw!, amount: asset.originAmountRaw as! Double, completion: { val in
                            if asset.targetAmountRaw!.doubleValue > val {
                                asset.trend = "arrowtriangle.down.fill"
                            } else if asset.targetAmountRaw!.doubleValue < val {
                                asset.trend = "arrowtriangle.up.fill"
                            } else {
                                asset.trend = "circle.fill"
                            }
                            try? data.context.save()
                            asset.oldTargetAmount = Money(amount: asset.targetAmountRaw as! Double, in: asset.targetCurrency)
                            asset.targetAmountRaw = Decimal(val).asDecimalNumber
                            asset.targetAmount = Money(amount: val, in: asset.targetCurrency)
                            try? data.context.save()
                            updateID = UUID()
                        })
                        try? data.context.save()
                    }
                    try? data.context.save()
                    updateID = UUID()
                }
        } else {
            Text("🔌 No connection")
                .fontMonoMedium(color: .white, size: 10)
                .frame(width: 120, height: 20, alignment: .leading)
        }
    }
}
