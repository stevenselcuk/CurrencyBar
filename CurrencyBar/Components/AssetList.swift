//
//  AssetList.swift
//  Ticker
//
//  Created by Steven J. Selcuk on 18.08.2022.
//

import SwiftUI

struct AssetList: View {
    var data = PersistenceProvider.default
    @FetchRequest(sortDescriptors: [SortDescriptor(\.lastUpdate)], predicate: nil)
    var assets: FetchedResults<Asset>

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                ForEach(Array(assets.enumerated()), id: \.element) { _, asset in
                    HStack(alignment: .center) {
                        HStack(alignment: .center, spacing: 3) {
                            TrendIcon(name:  asset.trend!)
                            Text(asset.targetAmount.formattedString ?? "$0.0")
                                .fontMonoMedium(color: .white, size: 12)

                        }.padding(.all, 3)
                            .background(Color.gray.opacity(0.4))
                            .cornerRadius(3)
                            .padding(.vertical, 3)
                        Spacer()
                        Text(asset.originalAmount.formattedString ?? "£0.0")
                            .fontMonoMedium(color: .white, size: 10)
                            .truncationMode(.tail)
                            .lineLimit(1)
                            .fixedSize(horizontal: false, vertical: false)

                    }.padding(.horizontal, 12)
                        .contextMenu {
                            Button {
                                data.context.delete(asset)
                                try? data.context.save()
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                }
            }
        }
    }
}
