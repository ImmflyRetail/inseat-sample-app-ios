import SwiftUI

struct XmarkButton: View {

    let action: @MainActor () -> Void

    init(action: @escaping @MainActor () -> Void) {
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            Image(systemName: "xmark")
                .foregroundStyle(Color.primary)
                .frame(width: 32, height: 32)
        })
    }
}
