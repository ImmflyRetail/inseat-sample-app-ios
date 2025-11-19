import SwiftUI

public struct NavigationBar<Content: View, Leading: View, Trailing: View, SubHeader: View>: View {
    @State private var title: String?
    @State private var leading: AnyView?
    @State private var trailing: AnyView?

    private let defaultTitle: String?
    private let defaultLeading: Leading?
    private let leadingPadding: Double?
    private let defaultTrailing: Trailing?
    private let trailingPadding: Double?
    private let defaultSubheader: SubHeader?
    private let content: Content

    public init(
        title: String?,
        leading: Leading?,
        leadingPadding: Double? = nil,
        trailing: Trailing?,
        trailingPadding: Double? = nil,
        subheader: SubHeader?,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.defaultTitle = title
        self.defaultLeading = leading
        self.leadingPadding = leadingPadding
        self.defaultTrailing = trailing
        self.trailingPadding = trailingPadding
        self.defaultSubheader = subheader
        self.content = content()
    }

    public init(
        title: String?,
        leading: Leading?,
        leadingPadding: Double? = nil,
        trailingPadding: Double? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) where Trailing == NavigationBarPlaceholderView, SubHeader == NavigationBarPlaceholderView {
        self.init(
            title: title,
            leading: leading,
            leadingPadding: leadingPadding,
            trailing: nil,
            trailingPadding: trailingPadding,
            subheader: nil,
            content: content
        )
    }

    public init(
        title: String?,
        trailing: Trailing?,
        leadingPadding: Double? = nil,
        trailingPadding: Double? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) where Leading == NavigationBarPlaceholderView, SubHeader == NavigationBarPlaceholderView {
        self.init(
            title: title,
            leading: nil,
            leadingPadding: leadingPadding,
            trailing: trailing,
            trailingPadding: trailingPadding,
            subheader: nil,
            content: content
        )
    }

    public init(
        title: String? = nil,
        leadingPadding: Double? = nil,
        trailingPadding: Double? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) where Leading == NavigationBarPlaceholderView, Trailing == NavigationBarPlaceholderView, SubHeader == NavigationBarPlaceholderView {
        self.init(
            title: title,
            leading: nil,
            leadingPadding: leadingPadding,
            trailing: nil,
            trailingPadding: trailingPadding,
            subheader: nil,
            content: content
        )
    }

    public var body: some View {
        VStack(spacing: .zero) {
            ZStack {
                HStack {
                    if let leading = leading {
                        leading
                    } else {
                        defaultLeading
                    }
                    Spacer()
                    if let trailing = trailing {
                        trailing
                    } else {
                        defaultTrailing
                    }
                }
                Text(title ?? defaultTitle ?? "")
                    .font(Font.appFont(size: 18, weight: .regular))
                    .foregroundColor(Color.foregroundDark)
            }
            .padding(.leading, leadingPadding ?? 16)
            .padding(.trailing, trailingPadding ?? 16)
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: 60)

            if let defaultSubheader = defaultSubheader {
                defaultSubheader
            }
            Divider()
            content
        }
        .background(Color.backgroundLight)
        .onPreferenceChange(NavigationBarTitleKey.self) { title in
            self.title = title
        }
        .onPreferenceChange(NavigationBarLeadingKey.self) { container in
            self.leading = container?.view
        }
        .onPreferenceChange(NavigationBarTrailingKey.self) { container in
            self.trailing = container?.view
        }
    }
}

// MARK: - Placeholder

public struct NavigationBarPlaceholderView: View {

    private init() { }

    public var body: some View {
        return Group { }
    }
}

// MARK: - Preferences

private struct NavigationBarTitleKey: PreferenceKey {
    static var defaultValue: String?

    static func reduce(value: inout String?, nextValue: () -> String?) {
        value = value ?? nextValue()
    }
}

private struct NavigationBarLeadingKey: PreferenceKey {
    static var defaultValue: EquatableView?

    static func reduce(value: inout EquatableView?, nextValue: () -> EquatableView?) {
        value = value ?? nextValue()
    }
}

private struct NavigationBarTrailingKey: PreferenceKey {
    static var defaultValue: EquatableView?

    static func reduce(value: inout EquatableView?, nextValue: () -> EquatableView?) {
        value = value ?? nextValue()
    }
}

extension View {
    public func inseatNavigationBarTitle(_ title: String) -> some View {
        return preference(key: NavigationBarTitleKey.self, value: title)
    }

    public func inseatNavigationBarItems(leading: some View) -> some View {
        return preference(key: NavigationBarLeadingKey.self, value: EquatableView(view: AnyView(leading)))
    }

    public func inseatNavigationBarItems(trailing: some View) -> some View {
        return preference(key: NavigationBarTrailingKey.self, value: EquatableView(view: AnyView(trailing)))
    }

    public func inseatNavigationBarItems(leading: some View, trailing: some View) -> some View {
        return inseatNavigationBarItems(leading: leading)
            .inseatNavigationBarItems(trailing: trailing)
    }
}

private struct EquatableView: Equatable {

    static func == (lhs: EquatableView, rhs: EquatableView) -> Bool {
        return lhs.id == rhs.id
    }

    let id = UUID().uuidString
    let view: AnyView

    init(view: AnyView = AnyView(EmptyView())) {
        self.view = view
    }
}
