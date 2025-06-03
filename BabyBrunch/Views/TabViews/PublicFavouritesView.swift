//
//  PublicFavouritesView.swift
//  BabyBrunch
//
//  Created by KiwiComp on 2025-06-03.
//

import SwiftUI

struct PublicFavouritesView: View {
    @State private var searchTerm = ""
    @StateObject var favVM = FavoritesViewModel()
    @State var showEmptySearchAlert = false

    var body: some View {
        NavigationStack {
            VStack {
                CustomTitle(title: "Public Lists")
                
                HStack {
                    CustomTextField(input: $searchTerm, hint: "Type list name to search", type: .normal)
                        .padding(.leading, 30)
                    Button(action: {
                        // Call function in FavouritesViewModel to fetch public list(s) matching searchterm.
                        if searchTerm.isEmpty {
                            print("Search term is empty.")
                            showEmptySearchAlert = true
                        } else {
                            favVM.fetchPublicListFromSearch(for: searchTerm)
                        }
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
                .alert(isPresented: $showEmptySearchAlert) {
                    Alert(
                        title: Text("Empty search"),
                        message: Text("Please type a search term."),
                        dismissButton: .cancel(Text("OK")))
                }
//                List(testList, id: \.self) { item in
                List(favVM.publicList, id: \.self) { item in
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
    let item : PublicListData
    var body : some View {
        HStack {
            Text(item.name)
        }
    }
}


struct PublicListDetailView : View {
    let item : PublicListData
    
    var body : some View {
        VStack {
            CustomTitle(title: item.name)
            List(item.pins, id: \.self) { pin in
                DetailView(pin: pin)
            }.scrollContentBackground(.hidden)
        }.background(Color(.lavenderBlush))
    }
}

struct DetailView : View {
    let pin : Pin
    @State private var selectedPin: Pin? = nil
    var body : some View {
        HStack {
            Button(action: {
                selectedPin = pin
            }){
                Text(pin.name)
            }
        }
        .sheet(item: $selectedPin) { pin in
            VenueDetailView(pin: pin, mapViewRef: nil)
        }
    }
}

struct PublicListData : Hashable {
    var name : String
    var pins : [Pin] = []
}

struct RawPublicListData : Codable {
    var name : String
    var pins : [String] = []
}
