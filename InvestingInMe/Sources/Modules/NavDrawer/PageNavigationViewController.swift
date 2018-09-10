//
//  PageNavigationViewController.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-02-10.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit

public class PageNavigationViewController: UINavigationController {
  public convenience init() {
    self.init(nibName: nil, bundle: nil)
    setViewControllers([FeaturedProjectAssembler.make()], animated: false)
  }
  
  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    isNavigationBarHidden = true
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  public override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  public override var childViewControllerForStatusBarStyle: UIViewController? {
    return topViewController
  }

  public override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
    super.setViewControllers(viewControllers, animated: animated)
  }
  
  public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
    super.pushViewController(viewController, animated: animated)
  }
}
