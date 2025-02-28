//
//  SceneDelegate.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 2/10/21.
//  Copyright © 2021 Eric Versteeg. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    var lastSaveTime: TimeInterval = 0

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        save()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        SessionSettings.instance.sceneDelegateDelegate?.sceneWillEnterForeground()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        save()
        
        SessionSettings.instance.interactiveCanvas?.cancelLatencyTask()
        InteractiveCanvasSocket.instance.disconnect()
    
        SessionSettings.instance.canvasPauseTime = NSDate().timeIntervalSince1970
        SessionSettings.instance.canvasPaused = true

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    func save() {
        if NSDate().timeIntervalSince1970 - lastSaveTime > 5 {
            StatTracker.instance.achievementListener = nil
            
            let interactiveCanvas = SessionSettings.instance.interactiveCanvas
            
            if interactiveCanvas != nil {
                if interactiveCanvas!.world {
                    InteractiveCanvasSocket.instance.disconnect()
                }
                else {
                    interactiveCanvas!.save()
                    
                }
                //interactiveCanvas!.saveDeviceViewport()
            }
            
            SessionSettings.instance.save()
            
            lastSaveTime = NSDate().timeIntervalSince1970
        }
    }
}

