//
//  PublicFavouritesView.swift
//  BabyBrunch
//
//  Created by KiwiComp on 2025-06-03.
//

import SwiftUI
import MapKit

struct PublicFavouritesView: View {
    @State private var searchTerm = ""
    @Binding var mapViewRef: MKMapView?
    var testList = [
        PublicList(name: "Test 1", pins: ["pin1", "pin2", "pin3", "pin4"]),
        PublicList(name: "Test 2", pins: ["pin1", "pin2", "pin3", "pin4"]),
        PublicList(name: "Test 3", pins: ["pin1", "pin2", "pin3", "pin4"])
    ]
    var body: some View {
        NavigationStack {
            VStack {
                CustomTitle(title: "Public Lists")
                
                HStack {
                    CustomTextField(input: $searchTerm, hint: "Type list name to search", type: .normal)
                        .padding(.leading, 30)
                    Button(action: {
                        // Call function in FavouritesViewModel to fetch public list(s) matching searchterm.
                    }){
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color(.oldRose))
                    }
                    .padding(.trailing, 20)
                    .padding(.leading, 5)
                }
                List(testList, id: \.self) { item in
                    NavigationLink(destination: PublicListDetailView(item: item)) {
                        PublicListItem(item: item)
                    }
                }.scrollContentBackground(.hidden)
            }.background(Color(.lavenderBlush))
        }
    }
}

#Preview {
    PublicFavouritesView()
}

struct PublicListItem : View {
    let item : PublicList
    var body : some View {
        HStack {
            Text(item.name)
        }
    }
}


struct PublicListDetailView : View {
    let item : PublicList
    var body : some View {
        VStack {
            CustomTitle(title: item.name)
            List(item.pins, id: \.self) { pin in
                DetailView(item: pin)
            }.scrollContentBackground(.hidden)
        }.background(Color(.lavenderBlush))
    }
}

struct DetailView : View {
    let item : String
    var body : some View {
        HStack {
            Text(item)
        }
    }
}

struct PublicList : Hashable {
    var name : String
    var pins : [String] = []
}
