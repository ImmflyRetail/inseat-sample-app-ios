import UIKit
import SwiftUI
import Inseat

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        setupUI(window: window)
        setupInseat()
    }

    private func setupUI(window: UIWindow) {
        window.rootViewController = UIHostingController(rootView: MainView())
        self.window = window

        window.makeKeyAndVisible()
    }

    private func setupInseat() {
        let configuration = Configuration(
            apiKey: "{API_KEY}",
            supportedICAOs: ["{ICAO_UPPERCASED}"],
            environment: Configuration.Environment.test
        )

        Task {
            do {
                try await InseatAPI.shared.initialize(configuration: configuration)
                try await InseatAPI.shared.start()

                InseatAPI.shared.syncProductData { result in
                    print("[DEBUG]: did sync data with result='\(result)'")
                }
            } catch {
                print("[DEBUG]: Inseat API failed with an error: '\(error)'")
            }
        }
    }
}
