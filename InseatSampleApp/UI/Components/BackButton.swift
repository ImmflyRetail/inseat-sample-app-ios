import SwiftUI

struct BackButton: View {

    let action: @MainActor () -> Void

    init(action: @escaping @MainActor () -> Void) {
        self.action = action
    }

    var body: some View {
        Button(action: {
            action()
        }, label: {
            Image("Back")
        })
    }
}
