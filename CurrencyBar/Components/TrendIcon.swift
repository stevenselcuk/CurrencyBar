//
//  TrendIcon.swift
//  Ticker
//
//  Created by Steven J. Selcuk on 18.08.2022.
//

import SwiftUI

struct TrendIcon: View {
    var name: String
    var body: some View {
        if name ==  "arrowtriangle.up.fill" {
            Image(systemName: "arrowtriangle.up.fill")
                .resizable()
                .foregroundColor(.green)
                .frame(width: 8, height: 8)
        } else if name ==  "arrowtriangle.down.fill" {
            Image(systemName: "arrowtriangle.down.fill" )
                .resizable()
                .foregroundColor(.red)
                .frame(width: 8, height: 8)
        } else {
        Image(systemName: "circle.fill")
            .resizable()
            .foregroundColor(.yellow)
            .frame(width: 8, height: 8)
        }
    }
}

