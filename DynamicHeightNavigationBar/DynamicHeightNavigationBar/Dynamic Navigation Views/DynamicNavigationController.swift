//
//  DynamicNavigationController.swift
//  DynamicHeightNavigationBar
//
//  Created by Zhi Zhou on 2019/8/26.
//  Copyright © 2019 Zhi Zhou. All rights reserved.
//

import UIKit

open class DynamicNavigationController: UINavigationController {
            
    private var contentViewHeightCache: [UIViewController: CGFloat] = [:]
    
    /// 返回时，显示的那个视图控制器。
    private var pushedViewController: UIViewController?
    
    /// 返回时，消失的那个视图控制器。
    private var popViewController: UIViewController?
    
    /// push 时，最后一个 vc；pop 时，当前的 vc。（用于适配 iOS 14 长按返回情况）
    private var lastViewController: UIViewController?

    open var animationDuration: TimeInterval = 0.25
        
    /// 根视图控制器
    open var rootVC: UIViewController {
        return viewControllers[0]
    }
    
    /// 发起 push 的视图控制器
    open var backVC: UIViewController {
        
        let index = (viewControllers.count - 2 >= 0) ? (viewControllers.count - 2) : 0
        
        return viewControllers[index]
    }
    
    open var topVC: UIViewController {
        return viewControllers[viewControllers.count - 1]
    }
    
        
    convenience public init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?, rootViewController: UIViewController) {
        self.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
                
        self.viewControllers = [rootViewController]
    }
    

    override open func viewDidLoad() {
        super.viewDidLoad()

        setupInterface()
    }
    
}

extension DynamicNavigationController {
    
     private func setupInterface() {
        
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
                
        // Optional(<UIScreenEdgePanGestureRecognizer: 0x7fc83df02e40; state = Possible; delaysTouchesBegan = YES; view = <UILayoutContainerView 0x7fc83df01ca0>; target= <(action=handleNavigationTransition:, target=<_UINavigationInteractiveTransition 0x7fc83df02d00>)>>)
        
        interactivePopGestureRecognizer?.addTarget(self, action: #selector(handleTransition(_:)))
    }
    
}

extension DynamicNavigationController {
    
    // MARK: - push
    override open func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        
        guard let backVC = backVC as? DynamicNavigationRootViewController else { return }
        
        guard let navBar = backVC.navigationController?.navigationBar as? DynamicNavigationBar
            else { return }
                
        contentViewHeightCache[backVC] = navBar.contentView.bounds.height
        
        lastViewController = topViewController
                
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
            backVC.navigationContentView?.alpha = 0
        }, completion: nil)
    }
    
    // MARK: - pop
    override open func popViewController(animated: Bool) -> UIViewController? {
        
        // topVC：点击返回关闭的那个视图控制器
        // backVC：点击返回显示的那个视图控制器
        guard let topVC = topVC as? DynamicNavigationRootViewController,
              let backVC = backVC as? DynamicNavigationRootViewController
            else { return super.popViewController(animated: animated) }
        
        guard let navBar = navigationBar as? DynamicNavigationBar else {
            return super.popViewController(animated: animated)
        }
        
        let height = contentViewHeightCache[backVC] ?? 0
        
        lastViewController = backVC
        
        switch interactivePopGestureRecognizer?.state {
        case .began:
            // 滑动返回
            if #available(iOS 13.0, *) {} else {
                UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
                    navBar.contentViewHeightLayoutConstraint?.constant = height
                }, completion: nil)
            }
                                    
            popViewController = topVC
            pushedViewController = backVC
            
        case .possible:
            // 点击返回
            if #available(iOS 13.0, *) {} else {
                UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
                    navBar.contentViewHeightLayoutConstraint?.constant = height
                    
                    // 点击返回没问题，滑动返回不能使用 layoutIfNeeded。
                    self.navigationBar.layoutIfNeeded()
                }, completion: nil)
            }
                        
            // 点击返回时，将要隐藏的视图渐渐变淡。
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
                topVC.navigationContentView?.alpha = 0
                backVC.navigationContentView?.alpha = 1
            }, completion: { (_) in
                /* 这里移除“关闭的那个视图控制器”的 contentView。
                   是为了防止 contentView 重复在 DynamicNavigationRootViewController 的 viewWillLayoutSubviews 方法内创建。
                 */
                topVC.navigationContentView?.removeFromSuperview()
            })
            
        default:
            break
        }
        
        return super.popViewController(animated: animated)
    }
    
    open override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        return super.popToViewController(viewController, animated: animated)
    }
    
    open override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        super.setViewControllers(viewControllers, animated: animated)
        
        guard lastViewController != nil else { return }
        
        // 处理 iOS 14 长按返回按钮的跳转情况
        
        // topVC：点击返回关闭的那个视图控制器
        // backVC：点击返回显示的那个视图控制器
        guard let topVC = lastViewController as? DynamicNavigationRootViewController,
              let backVC = topViewController as? DynamicNavigationRootViewController
            else { return }
        
        guard let navBar = navigationBar as? DynamicNavigationBar else { return }
        
        let height = contentViewHeightCache[backVC] ?? 0
        
        // 点击返回
        if #available(iOS 13.0, *) {} else {
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
                navBar.contentViewHeightLayoutConstraint?.constant = height
                
                // 点击返回没问题，滑动返回不能使用 layoutIfNeeded。
                self.navigationBar.layoutIfNeeded()
            }, completion: nil)
        }
                    
        // 点击返回时，将要隐藏的视图渐渐变淡。
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
            topVC.navigationContentView?.alpha = 0
            backVC.navigationContentView?.alpha = 1
        }, completion: { (_) in
            /* 这里移除“关闭的那个视图控制器”的 contentView。
               是为了防止 contentView 重复在 DynamicNavigationRootViewController 的 viewWillLayoutSubviews 方法内创建。
             */
            topVC.navigationContentView?.removeFromSuperview()
        })
    }

    open override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        
        // topVC：点击返回关闭的那个视图控制器
        // backVC：点击返回显示的那个视图控制器
        guard let topVC = topVC as? DynamicNavigationRootViewController,
            let backVC = backVC as? DynamicNavigationRootViewController
            else { return super.popToRootViewController(animated: animated) }
        
        guard let navBar = navigationBar as? DynamicNavigationBar else {
            return super.popToRootViewController(animated: animated)
        }
        
        let height = contentViewHeightCache[backVC] ?? 0
        
        // 点击返回
        if #available(iOS 13.0, *) {} else {
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
                navBar.contentViewHeightLayoutConstraint?.constant = height
                
                // 点击返回没问题，滑动返回不能使用 layoutIfNeeded。
                self.navigationBar.layoutIfNeeded()
            }, completion: nil)
        }
        
        // 点击返回时，将要隐藏的视图渐渐变淡。
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
            topVC.navigationContentView?.alpha = 0
            backVC.navigationContentView?.alpha = 1
        }, completion: { (_) in
            /* 这里移除“关闭的那个视图控制器”的 contentView。
               是为了防止 contentView 重复在 DynamicNavigationRootViewController 的 viewWillLayoutSubviews 方法内创建。
             */
            topVC.navigationContentView?.removeFromSuperview()
        })
        
        return super.popToRootViewController(animated: animated)
    }
    
}

// MARK: - 事件
extension DynamicNavigationController {
    
    @objc private func handleTransition(_ gr: UIGestureRecognizer) {
        
        // pushedVC：点击返回显示的那个视图控制器
        // popVC：点击返回关闭的那个视图控制器
        guard let pushedVC = pushedViewController as? DynamicNavigationRootViewController,
              let popVC = popViewController as? DynamicNavigationRootViewController
            else { return }
        
        guard let navBar = navigationBar as? DynamicNavigationBar else { return }
        
        // 滑动返回的触控坐标
        let location = gr.location(in: view)

        let factor = location.x / view.bounds.width
        
        // 滑动返回时，将要隐藏的视图渐渐变淡。
        popVC.navigationContentView?.alpha = 1 - factor

        // 滑动返回时，将要显示的视图渐渐显现。
        pushedVC.navigationContentView?.alpha = factor
        
        switch gr.state {
        case .ended:
            guard navBar.contentView.subviews.count > 1 else { return }
                         
            let popX = popViewController?.view.convert(popViewController!.view.frame.origin, to: view).x ?? 0
            
            // 确定将要返回
            if popX > 0 {
                popVC.navigationContentView?.alpha = 0
                pushedVC.navigationContentView?.alpha = 1
            } else {
                // 滑动未超过屏幕宽度的一半，取消滑动返回。
                popVC.navigationContentView?.alpha = 1
                pushedVC.navigationContentView?.alpha = 0
            }

        default:
            break
        }
    }
    
}

