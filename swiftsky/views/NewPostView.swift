//
//  NewPostView.swift
//  swiftsky
//

import SwiftUI

struct NewPostView: View {
  @Binding var isPresented: Bool
  @State var text = ""
  @State var disablebuttons: Bool = false
  @State var erroralert: Bool = false
  func post() {
    disablebuttons = true
    Task {
      do {
        let _ = try await makePost(text: text)
        isPresented = false
      } catch {
        erroralert = true
      }
      disablebuttons = false
    }
  }
  var body: some View {
    VStack {
      HStack {
        Button("Cancel") {
          isPresented = false
        }
        .buttonStyle(.plain)
        .padding([.leading, .top], 20)
        .foregroundColor(.accentColor)
        .disabled(disablebuttons)
        Spacer()
        Button("Post") {
          post()
        }
        .buttonStyle(.borderedProminent)
        .tint(.accentColor)
        .disabled(text.count > 256 || disablebuttons)
        .padding([.trailing, .top], 20)
      }
      Divider()
        .padding(.vertical, 5)
      HStack(alignment: .top) {
        Image(systemName: "person.crop.circle.fill")
          .resizable()
          .foregroundColor(.accentColor)
          .frame(width: 50, height: 50)
          .cornerRadius(20)

        ZStack(alignment: .leading) {
          if text.isEmpty {
            VStack {
              Text("What's up?")
                .padding(.leading, 6)
                .opacity(0.7)
              Spacer()
            }
          }

          VStack {
            TextEditor(text: $text)
            Spacer()
          }
        }
        .scrollContentBackground(.hidden)
        .font(.system(size: 20))
        Spacer()
      }
      .padding([.leading], 20)
      Divider()
        .padding(.vertical, 5)
      HStack {
        Spacer()
        let replycount = 256 - text.count
        Text("\(replycount)")
          .padding(.trailing, 20)
          .foregroundColor(replycount < 0 ? .red : .primary)

      }
      Spacer()

    }
    .alert("Failed to create post, please try again", isPresented: $erroralert, actions: {})
  }
}
