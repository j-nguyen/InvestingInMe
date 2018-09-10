//
//  AppDelegate.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-01-22.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import UIKit
import GoogleSignIn
import Moya
import RxSwift
import JWTDecode
import MaterialComponents
import Fabric
import Crashlytics
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, OSSubscriptionObserver {
  // MARK: Properties
  var window: UIWindow?
  let disposeBag = DisposeBag()
  // this checks for the login of the token
  var isLoggedIn: Variable<Bool> = Variable(false)
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    //Configure Google ID Sign In components
    GIDSignIn.sharedInstance().clientID = Constants.clientID
    GIDSignIn.sharedInstance().delegate = self
    
    prepareFabric()
    prepareOneSignal(launchOptions)
    
    // Override point for customization after application launch.
    window = UIWindow(frame: UIScreen.main.bounds)
    guard let window = self.window else { fatalError("no window") }
    window.backgroundColor = .white
    window.makeKeyAndVisible()
   
    // Tests to see if the user is logged in before proceeding
    if let token = UserDefaults.standard.string(forKey: "token"), let jwt = try? decode(jwt: token) {
      if jwt.expired {
        // create an alert
        let alertController = ModuleFactoryAssembler.makeLoginExpiredDialog()
        window.rootViewController = LoginAssembler.make()
        window.rootViewController?.present(alertController, animated: true)
      } else {
        self.isLoggedIn.value = true
        window.rootViewController = NavigationDrawerViewController(rootViewController: PageNavigationViewController(), leftViewController: LeftViewAssembler.make())
      }
    } else {
      window.rootViewController = LoginAssembler.make()
    }

    return true
  }
  
  // Add this new method
  func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
    if !stateChanges.from.subscribed && stateChanges.to.subscribed {
      print("Subscribed for OneSignal push notifications!")
      // get player ID
      UserDefaults.standard.set(stateChanges.to.userId, forKey: "player_id")
    }
    print("SubscriptionStateChange: \n\(stateChanges)")
  }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
  }
  
  func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
    if let error = error {
      print("\(error.localizedDescription)")
    } else {
      let idToken = user.authentication.idToken
      let provider = ModuleFactoryAssembler.makeMoya()

      if let idToken = idToken {
        provider.rx.request(.login(idToken))
          .asObservable()
          .filter(statusCode: 200)
          .filter { [weak self] _ in return !(self?.isLoggedIn.value ?? false ) }
          .map(Token.self)
          .subscribe(onNext: { [weak self] response in
            guard let this = self else { return }
            // set the value to true
            this.isLoggedIn.value = true
            UserDefaults.standard.setValue(response.token, forKey: "token")
            // we want to check if the current VC is already in the nav drawer
            this.window?.rootViewController = NavigationDrawerViewController(rootViewController: PageNavigationViewController(), leftViewController: LeftViewAssembler.make())
          }).disposed(by: disposeBag)
      }
    }
  }
  
  func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
    // Perform any operations when the user disconnects from app here
    // remove the token
    UserDefaults.standard.removeObject(forKey: "token")
    self.isLoggedIn.value = false
    // now we want to change to the login assembler as well
    window?.rootViewController = LoginAssembler.make()
  }
  
  private func prepareFabric() {
    #if DEBUG
    #else
      print("~*~*~*~*~*~* PREPARING FABRIC ~*~*~*~*~*~*~*~*~*")
      Fabric.with([Crashlytics.self])
    #endif
  }
  
  private func prepareOneSignal(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
    // Add your AppDelegate as an obsserver
    OneSignal.add(self as OSSubscriptionObserver)
    
    // Setup one signal launch options
    OneSignal.initWithLaunchOptions(
      launchOptions,
      appId: Constants.ONESIGNAL_APP_ID,
      handleNotificationAction: nil,
      settings: [kOSSettingsKeyAutoPrompt: false]
    )
    
    OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
    
    // Recommend moving the below line to prompt for push after informing the user about
    //   how your app will use them.
    OneSignal.promptForPushNotifications(userResponse: { accepted in
      if accepted && UserDefaults.standard.string(forKey: "player_id") == nil {
        guard let userId = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId else {
          return
        }
        
        UserDefaults.standard.set(userId, forKey: "player_id")
      }
    })
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
}
