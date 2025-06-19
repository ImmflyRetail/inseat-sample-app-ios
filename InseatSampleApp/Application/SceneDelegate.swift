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
            apiKey: "{INSEAT_API_KEY}",
            icaos: ["{ICAO_CODE}"],
            environment: .test
        )
        try! InseatAPI.shared.initialize(configuration: configuration)

        try! InseatAPI.shared.start()

        InseatAPI.shared.syncProductData { result in
            print("[DEBUG]: did sync data with result='\(result)'")
        }
    }
}
