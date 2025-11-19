import SwiftUI

public extension View {

    @ViewBuilder func when<Result: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Result) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
}
