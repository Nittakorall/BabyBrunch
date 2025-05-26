//
//  AddReviewView.swift
//  BabyBrunch
//
//  Created by test2 on 2025-05-25.
//

import SwiftUI

struct AddReviewView: View {
    @State private var reviewText = ""
    @State var rating = 0
    @State private var viewHeight: CGFloat = 0
    
    
    
    @Environment(\.dismiss) var dismiss
    
    @State var showAlert = false
    
    
    var body: some View {
        ZStack {
            Color("lavenderBlush")
                .edgesIgnoringSafeArea(.all)
            
            GeometryReader { geo in
                VStack {
                    CustomTitle(title: "Choose a star rating:")
                    //-15 padding so that title doesn't take all space in 0.3
                        .padding(.vertical, -15)
                    
                    
                    StarRatingView(rating: $rating)
                        .padding(.bottom, 10)
                    //if fraction of the view is more than 0.3, review field will be shown
                    
                    
                    if viewHeight > 300 {
                        //add review field
                        VStack{
                            CustomTitle(title : "Add your review:")
                            
                            TextEditor(text: $reviewText)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(.thistle), lineWidth: 2)
                                )
                                .padding(.horizontal, 20)
                            
                        }
                        //0.6 and 1 fraction is for some reason not centered without it
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    //button "add review"
                    CustomButton(label: "Add review", backgroundColor: "oldRose", width: 350) {
                        if rating == 0 {
                            print("Rating is 0, i.e. no star chosen.")
                            showAlert = true
                        } else {
                            // Call functions, e.g. to save rating to Firestore.
                            print("Chosen rating: \(rating)")
                            dismiss()
                        }
                    }
                    .padding(.bottom, 30)
                    .padding(.top, 5)
                }
                
                
                .frame(maxHeight: .infinity, alignment: .top)
                .onAppear {
                    viewHeight = geo.size.height
                    
                }
                
                //updates the view if fraction size changes
                .onChange(of: geo.size.height) { newValue in
                    viewHeight = newValue
                    
                }
                    
                    //button "add review"

                
                    .padding(.top, 50)
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("No rating"),
                            message: Text("Please choose a star for your rating."),
                            dismissButton: .cancel(Text("OK")))
                        
                    }
                }
            
            
        }
    }
    
    struct StarRatingView: View {
        @Binding var rating: Int
        
        var body: some View {
            HStack {
                // For each number 1-5:
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= rating ? "star.fill" : "star")
                    // Gradient colour instead of one colour.
                        .foregroundStyle( index <= rating ?
                                          AnyShapeStyle(LinearGradient(colors: [Color(.lightYellowStar), Color(.darkYellowStar)], startPoint: .top, endPoint: .bottom)) :
                                            AnyShapeStyle(.gray))
                        .font(.system(size: 30)) // Size of stars.
                        .offset(y: index <= rating ? -10 : 0) // Move stars up on y-axis.
                        .shadow(color: .black.opacity(0.3), radius: 3, x: -2, y: 5) // Shadow around image for more 3D effect.
                        .scaleEffect(index == rating ? 1.3 : 1.0) // Upon click, enlarge star slightly.
                        .animation(.spring(), value: rating) // Upon click, animate when star get larger.
                    // When a star is clicked, set its index to our rating variable.
                        .onTapGesture {
                            rating = index
                            print("Rating: \(rating)")
                        }
                }
            }
        }
    }
}

#Preview {
    AddReviewView()
}
