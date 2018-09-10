//
//  LoginViewController.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-02-06.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import GoogleSignIn
import MaterialComponents

public class LoginViewController: UIViewController, GIDSignInUIDelegate {
  //MARK: ViewController Variables
  private var redRectangle: UIView!
  private var appTitle: UILabel!
  private var appLogo: UIImageView!
  private var loginButton: GIDSignInButton!

  public convenience init() {
    self.init(nibName: nil, bundle: nil)
  }
  
  public override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    //Set Google ui Delegate, and when possible sign in user silently to skip sign in
    GIDSignIn.sharedInstance().uiDelegate = self
    prepareView()
    prepareTerm()
  }
  
  private func prepareTerm() {
    if UserDefaults.standard.bool(forKey: "tos") == false {
      let url = URL(string: Constants.TERMS_OF_SERVICE_URL)!
      let documentViewController = DocumentAssembler.make(title: "Terms of Service", url: url, initial: true)
      self.present(documentViewController, animated: true)
    }
  }
  
  private func prepareView() {
    prepareRedRectangle()
    prepareTitle()
    prepareLoginButton()
    prepareAppLogo()
  }
  
  private func prepareRedRectangle() {
    redRectangle = UIView()
    view.addSubview(redRectangle)
    
    redRectangle.backgroundColor = MDCPalette.red.tint700
    
    redRectangle.snp.makeConstraints{ make in
      make.height.equalTo(view).dividedBy(3)
      make.width.equalTo(view)
      make.top.equalTo(view)
      make.centerX.equalTo(view)
    }
  }
  
  private func prepareTitle() {
    appTitle = UILabel()
    appTitle.text = "investingin.me"
    appTitle.textColor = MDCPalette.grey.tint100
    appTitle.font = MDCTypography.display2Font()
    view.addSubview(appTitle)
    
    appTitle.snp.makeConstraints{ make in
      make.centerY.equalTo(redRectangle)
      make.centerX.equalTo(view)
    }
  }
  
  private func prepareLoginButton() {
    loginButton = GIDSignInButton()
    loginButton.style = GIDSignInButtonStyle.wide
    
    view.addSubview(loginButton)
    
    loginButton.snp.makeConstraints{ make in
      make.centerX.equalTo(view)
      make.bottom.equalTo(view).offset(-60)
    }
  }
  
  private func prepareAppLogo() {
    appLogo = UIImageView()
    view.addSubview(appLogo)
    
    appLogo.image = UIImage(named: "Logo")?.withRenderingMode(.alwaysOriginal)
    appLogo.snp.makeConstraints{ make in
      make.height.equalTo(120)
      make.width.equalTo(120)
      make.center.equalTo(view)
    }
  }

}
