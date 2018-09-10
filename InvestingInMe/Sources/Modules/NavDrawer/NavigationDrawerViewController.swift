//
//  NavigationDrawerViewController.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-02-02.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxGesture
import GoogleSignIn

public final class NavigationDrawerViewController: UIViewController {
  
  // MARK: ViewControllers
  private var rootViewController: PageNavigationViewController!
  private var leftViewController: LeftViewController!
  private var shadowView: UIView!
  
  // MARK: Navigation Drawers
  private var drawerConstraint: Constraint!
  private var isOpen: Bool = false
  private var isStatusBarHidden: Bool = false
  
  private let disposeBag = DisposeBag()
  
  // our actual initializer when we launch
  public convenience init(rootViewController: PageNavigationViewController, leftViewController: LeftViewController) {
    self.init(nibName: nil, bundle: nil)
    self.rootViewController = rootViewController
    self.leftViewController = leftViewController
  }
  
  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  public override var prefersStatusBarHidden: Bool {
    return isStatusBarHidden
  }
  
  // MARK: Begin Viewing
  public override func viewDidLoad() {
    super.viewDidLoad()
    prepareView()
  }
  
  private func prepareView() {
    prepareRoot()
    prepareShadowView()
    prepareMenu()
    prepareViewEvents()
  }
  
  private func prepareMenu() {
    leftViewController.view.frame = view.frame
    view.addSubview(leftViewController.view)
    addChildViewController(leftViewController)
    leftViewController.didMove(toParentViewController: self)
    
    leftViewController.view.snp.makeConstraints { make in
      make.width.equalTo(300)
      drawerConstraint = make.left.equalTo(view).offset(-300).constraint
      make.bottom.equalTo(view)
      make.top.equalTo(view)
    }
  }
  
  private func prepareRoot() {
    rootViewController.willMove(toParentViewController: self)
    rootViewController.view.frame = view.frame
    view.addSubview(rootViewController.view)
    addChildViewController(rootViewController)
    rootViewController.didMove(toParentViewController: self)

    rootViewController.view.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
  }
  
  private func prepareShadowView() {
    shadowView = UIView()
    shadowView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    shadowView.alpha = 0
    view.addSubview(shadowView)
    
    shadowView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    shadowView.rx.tapGesture()
      .asObservable()
      .when(.recognized)
      .filter { [unowned self] _ in return self.shadowView.alpha == 0.75 }
      .subscribe(onNext: { [weak self] _ in
        guard let this = self else { return }
        this.close()
      })
      .disposed(by: disposeBag)
  }
  
  private func prepareViewEvents() {
    // we'll just put the bindings for the superview here
    // TODO: Refactoring at a later point
    view.rx
      .screenEdgePanGesture(edges: .left, configuration: { gestureRecognizer, delegate in
        gestureRecognizer.delegate = self
      })
      .asControlEvent()
      .filter { [weak self] _ in return !(self?.isOpen ?? false) }
      .subscribe(onNext: { [weak self] gesture in
        guard let this = self else { return }
        switch gesture.state {
        case .changed:
          if let view = gesture.view, (gesture.translation(in: view).x - 300) < 0 {
            let translation = gesture.translation(in: view).x
            // we'll just translate it over until it hits 300, which we open
            
            // the 400 is 300 / 0.75, because we want to get the 75% of the alpha
            let shadowOffset = translation / 400
            this.shadowView.alpha = shadowOffset
            this.drawerConstraint.update(offset: translation - 300)
            this.view.layoutIfNeeded()
          }
        case .ended:
          let isPastOffset = this.drawerConstraint.layoutConstraints[0].constant > -150
          if isPastOffset {
            this.open()
          } else {
            this.close()
          }
          break
        default:
          break
        }
      })
      .disposed(by: disposeBag)
    
    shadowView.rx
      .panGesture()
      .asControlEvent()
      .filter { [unowned self] _ in return self.isOpen }
      .subscribe(onNext: { [unowned self] gesture in
        switch gesture.state {
        case .changed:
          if let view = gesture.view, gesture.translation(in: view).x < 0 {
            let translation = gesture.translation(in: view).x
            // get the inverse
            let shadowOffset = 0.75 - (abs(translation) / 400)
            self.shadowView.alpha = shadowOffset
            self.drawerConstraint.update(offset: translation)
            self.view.layoutIfNeeded()
          }
        case .ended:
          let isPastOffset = self.drawerConstraint.layoutConstraints[0].constant < -150
          
          if isPastOffset {
            self.close()
          } else {
            self.open()
          }
          break
        default:
          break
        }
      })
      .disposed(by: disposeBag)
  }

  /// Opens up the menu
  public func open() {
    UIView.animate(withDuration: 0.25, animations: {
      self.drawerConstraint.update(offset: 0)
      self.shadowView.alpha = 0.75
      self.isOpen = true
      self.isStatusBarHidden = true
      self.setNeedsStatusBarAppearanceUpdate()
      self.view.layoutIfNeeded()
    })
  }
  
  /// Closes the menu
  public func close() {
    UIView.animate(withDuration: 0.25, animations: {
      self.drawerConstraint.update(offset: -300)
      self.shadowView.alpha = 0
      self.isOpen = false
      self.isStatusBarHidden = false
      self.setNeedsStatusBarAppearanceUpdate()
      self.view.layoutIfNeeded()
    })
  }
  
  /// Sets view controller
  public func setViewController(_ viewController: UIViewController, animated: Bool = true) {
    rootViewController.setViewControllers([viewController], animated: animated)
    rootViewController.view.layoutIfNeeded()
    self.close()
  }
  
  /// Pushes the viewcontroller
  public func presentViewController(_ viewController: UIViewController, animated: Bool = true) {
    rootViewController.pushViewController(viewController, animated: animated)
  }
  
  /// Checks if the view controller is on the stack
  public func isViewControllerInNavStack(_ viewController: UIViewController) -> Bool {
    return rootViewController.viewControllers.contains(viewController) && rootViewController.viewControllers[0] != viewController
  }
  
  /// Pops the stack view controller for us
  public func popViewController(animated: Bool = true) {
    rootViewController.popViewController(animated: animated)
  }
}

extension NavigationDrawerViewController: UIGestureRecognizerDelegate {
  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    if gestureRecognizer.isKind(of: UISwipeGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UIScreenEdgePanGestureRecognizer.self) {
      return true
    }
    return false
  }
}
