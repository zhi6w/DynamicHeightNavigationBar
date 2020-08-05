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
    
    /// 返回时，显示的那个 View Controller。
    private var pushedViewController: UIViewController?
    
    /// 返回时，消失的那个 View Controller。
    private var popViewController: UIViewController?

    open var animationDuration: TimeInterval = 0.35
        
    /// 根视图控制器
    open var rootViewController: UIViewController? {
        return viewControllers.first
    }
    
    /// 发起 push 的 View Controller
    open var visiblePushedViewController: UIViewController? {
        
        guard !viewControllers.isEmpty else { return nil }
        
        let index = (viewControllers.count - 2 >= 0) ? (viewControllers.count - 2) : 0

        return viewControllers[index]
    }
    
    /// 是否完成了滑动返回手势
    open var isEndingInteractivePopGestureRecognizer = true
    
        
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
        
        delegate = self
        
        // Optional(<UIScreenEdgePanGestureRecognizer: 0x7fc83df02e40; state = Possible; delaysTouchesBegan = YES; view = <UILayoutContainerView 0x7fc83df01ca0>; target= <(action=handleNavigationTransition:, target=<_UINavigationInteractiveTransition 0x7fc83df02d00>)>>)
        
        interactivePopGestureRecognizer?.addTarget(self, action: #selector(handleTransition(_:)))
    }
    
}

extension DynamicNavigationController {
    
    // MARK: - push
    override open func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        
        isEndingInteractivePopGestureRecognizer = true
        
        // 获取系统默认转场动画时长
        animationDuration = transitionCoordinator?.transitionDuration ?? 0.35
                
        guard let navBar = navigationBar as? DynamicNavigationBar else { return }
                
        guard let visiblePushedViewController = visiblePushedViewController, let topViewController = topViewController else { return }
        
        // visiblePushedVC：即将消失的那个视图控制器
        guard let visiblePushedVC = visiblePushedViewController as? DynamicNavigationRootViewController
              else {
            // 即将消失的 View Controller 不是 DynamicNavigationRootViewController 类型，保存默认高度。
            contentViewHeightCache[visiblePushedViewController] = navBar.bounds.height
            return
        }
                 
        contentViewHeightCache[visiblePushedVC] = navBar.contentView.bounds.height

        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
            visiblePushedVC.navigationContentView?.alpha = 0
        }, completion: { _ in
//            visiblePushedVC.navigationContentView?.removeFromSuperview()
        })
        
        if !topViewController.isKind(of: DynamicNavigationRootViewController.self) {
            // push 到的 View Controller 不是 DynamicNavigationRootViewController 类型，则设定 navBar 高度为默认值。
            navBar.setContentViewHeight(.zero)
        }
    }
    
    // MARK: - pop
    override open func popViewController(animated: Bool) -> UIViewController? {
        
        guard let navBar = navigationBar as? DynamicNavigationBar else {
            return super.popViewController(animated: animated)
        }
        
        guard let visiblePushedViewController = visiblePushedViewController, let topViewController = topViewController else {
            return super.popViewController(animated: animated)
        }

        let height = contentViewHeightCache[visiblePushedViewController] ?? 0
        
        if !topViewController.isKind(of: DynamicNavigationRootViewController.self) {
            navBar.setContentViewHeight(0)
        }
        
        switch interactivePopGestureRecognizer?.state {
        case .began:
            // 滑动返回
            if #available(iOS 13.0, *) {} else {
                UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
                    navBar.contentViewHeightLayoutConstraint?.constant = height
                }, completion: nil)
            }
                                    
            popViewController = topViewController
            pushedViewController = visiblePushedViewController
                                    
        case .possible:
            // 点击返回
            
            isEndingInteractivePopGestureRecognizer = true
            
            // visiblePushedVC：点击返回时显示的那个视图控制器
            // 如果 visiblePushedVC 不是 DynamicNavigationRootViewController 类型，则返回 nil。
            let visiblePushedVC = visiblePushedViewController as? DynamicNavigationRootViewController
            
            if #available(iOS 13.0, *) {} else {
                UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
                    navBar.contentViewHeightLayoutConstraint?.constant = height
                    
                    // 点击返回没问题，滑动返回不能使用 layoutIfNeeded。
                    self.navigationBar.layoutIfNeeded()
                }, completion: nil)
            }
                        
            // topVC：点击返回时关闭的那个视图控制器。
            // 如果 topVC 不是 DynamicNavigationRootViewController 类型，则返回 nil。
            let topVC = topViewController as? DynamicNavigationRootViewController
                        
            // 点击返回时，将要隐藏的视图渐渐变淡。
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
                topVC?.navigationContentView?.alpha = 0
                visiblePushedVC?.navigationContentView?.alpha = 1
            }, completion: { (_) in
                /* 这里移除“关闭的那个视图控制器”的 contentView。
                   是为了防止 contentView 重复在 DynamicNavigationRootViewController 的 viewWillLayoutSubviews 方法内创建。
                 */
                topVC?.navigationContentView?.removeFromSuperview()
            })
            
            // 如果 visiblePushedVC 不是 DynamicNavigationRootViewController 类型，则恢复 navBar 高度为默认值。
            if visiblePushedVC == nil {
                navBar.setContentViewHeight(.zero)
            }
            
        default:
            break
        }
        
        return super.popViewController(animated: animated)
    }
    
    open override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        
        isEndingInteractivePopGestureRecognizer = true
        
        guard let navBar = navigationBar as? DynamicNavigationBar else {
            return super.popToViewController(viewController, animated: animated)
        }
        
        guard let topViewController = topViewController else {
            return super.popToViewController(viewController, animated: animated)
        }

        let height = contentViewHeightCache[viewController] ?? 0
        
        // 点击返回
        
        // visiblePushedVC：点击返回时显示的那个视图控制器
        // 如果 visiblePushedVC 不是 DynamicNavigationRootViewController 类型，则返回 nil。
        let visiblePushedVC = viewController as? DynamicNavigationRootViewController
        
        if #available(iOS 13.0, *) {} else {
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
                navBar.contentViewHeightLayoutConstraint?.constant = height
                
                // 点击返回没问题，滑动返回不能使用 layoutIfNeeded。
                self.navigationBar.layoutIfNeeded()
            }, completion: nil)
        }
                    
        // topVC：点击返回时关闭的那个视图控制器。
        // 如果 topVC 不是 DynamicNavigationRootViewController 类型，则返回 nil。
        let topVC = topViewController as? DynamicNavigationRootViewController
                    
        // 点击返回时，将要隐藏的视图渐渐变淡。
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
            topVC?.navigationContentView?.alpha = 0
            visiblePushedVC?.navigationContentView?.alpha = 1
        }, completion: { (_) in
            /* 这里移除“关闭的那个视图控制器”的 contentView。
               是为了防止 contentView 重复在 DynamicNavigationRootViewController 的 viewWillLayoutSubviews 方法内创建。
             */
            topVC?.navigationContentView?.removeFromSuperview()
        })
        
        // 如果 visiblePushedVC 不是 DynamicNavigationRootViewController 类型，则恢复 navBar 高度为默认值。
        if visiblePushedVC == nil {
            navBar.setContentViewHeight(.zero)
        }
        
        return super.popToViewController(viewController, animated: animated)
    }
    
    open override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        
        isEndingInteractivePopGestureRecognizer = true
        
        guard let navBar = navigationBar as? DynamicNavigationBar else {
            return super.popToRootViewController(animated: animated)
        }
        
        guard let topViewController = topViewController, let rootViewController = rootViewController else {
            return super.popToRootViewController(animated: animated)
        }
        
        let height = contentViewHeightCache[rootViewController] ?? 0

        // 点击返回
        if #available(iOS 13.0, *) {} else {
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
                navBar.contentViewHeightLayoutConstraint?.constant = height

                // 点击返回没问题，滑动返回不能使用 layoutIfNeeded。
                self.navigationBar.layoutIfNeeded()
            }, completion: nil)
        }
        
        // topVC：点击返回时关闭的那个视图控制器。
        // 如果 topVC 不是 DynamicNavigationRootViewController 类型，则返回 nil。
        let topVC = topViewController as? DynamicNavigationRootViewController
        
        // rootVC：根视图控制器
        // 如果 rootVC 不是 DynamicNavigationRootViewController 类型，则返回 nil。
        let rootVC = visiblePushedViewController as? DynamicNavigationRootViewController

        // 点击返回时，将要隐藏的视图渐渐变淡。
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
            topVC?.navigationContentView?.alpha = 0
            rootVC?.navigationContentView?.alpha = 1
        }, completion: { (_) in
            /* 这里移除“关闭的那个视图控制器”的 contentView。
               是为了防止 contentView 重复在 DynamicNavigationRootViewController 的 viewWillLayoutSubviews 方法内创建。
             */
            topVC?.navigationContentView?.removeFromSuperview()
        })
        
        // 如果 rootVC 不是 DynamicNavigationRootViewController 类型，则恢复 navBar 高度为默认值。
        if rootVC == nil {
            navBar.setContentViewHeight(.zero)
        }

        return super.popToRootViewController(animated: animated)
    }
    
    // MARK: - setViewControllers
    open override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        super.setViewControllers(viewControllers, animated: animated)
        
        isEndingInteractivePopGestureRecognizer = true
        
        guard let navBar = navigationBar as? DynamicNavigationBar else { return }
        
        // 在设定新的视图控制器数组时，记录一下老的导航堆栈顶部的视图控制器。
        let oldTopVC = topViewController
        
        guard oldTopVC != nil else { return }
        
        guard let topViewController = topViewController else { return }
        
        // 在原有的基础上，同时处理 iOS 14 长按返回按钮的跳转情况。
                        
        let height = contentViewHeightCache[topViewController] ?? 0
        
        // 点击返回
        if #available(iOS 13.0, *) {} else {
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
                navBar.contentViewHeightLayoutConstraint?.constant = height
                
                // 点击返回没问题，滑动返回不能使用 layoutIfNeeded。
                self.navigationBar.layoutIfNeeded()
            }, completion: nil)
        }
                    
        // topVC：点击返回关闭的那个视图控制器。
        // visiblePushedVC：点击返回时，显示的那个视图控制器。
        let topVC = oldTopVC as? DynamicNavigationRootViewController
        let visiblePushedVC = topViewController as? DynamicNavigationRootViewController
        
        // 点击返回时，将要隐藏的视图渐渐变淡。
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
            topVC?.navigationContentView?.alpha = 0
            visiblePushedVC?.navigationContentView?.alpha = 1
        }, completion: { (_) in
            /* 这里移除“关闭的那个视图控制器”的 contentView。
               是为了防止 contentView 重复在 DynamicNavigationRootViewController 的 viewWillLayoutSubviews 方法内创建。
             */
            topVC?.navigationContentView?.removeFromSuperview()
        })
        
        if visiblePushedVC == nil {
            navBar.setContentViewHeight(.zero)
        }
    }
    
}

// MARK: - 事件
extension DynamicNavigationController {
    
    @objc private func handleTransition(_ gr: UIGestureRecognizer) {
        
        guard let navBar = navigationBar as? DynamicNavigationBar else { return }
        
        guard let popViewController = popViewController, let pushedViewController = pushedViewController
            else { return }
        
        // pushedVC：返回显示的那个视图控制器
        let pushedVC = pushedViewController as? DynamicNavigationRootViewController
        
        // popVC：返回关闭的那个视图控制器
        let popVC = popViewController as? DynamicNavigationRootViewController
                
        
        // 滑动返回的触控坐标
        let location = gr.location(in: view)

        let factor = location.x / view.bounds.width
        
        // 滑动返回时，将要隐藏的视图渐渐变淡。
        popVC?.navigationContentView?.alpha = 1 - factor

        // 滑动返回时，将要显示的视图渐渐显现。
        pushedVC?.navigationContentView?.alpha = factor
                
        switch gr.state {
        case .ended:
            guard navBar.contentView.subviews.count > 1 else { return }
            
            let popX = popViewController.view.convert(popViewController.view.frame.origin, to: view).x
            
            // 确定将要返回
            if popX > 0 {
                popVC?.navigationContentView?.alpha = 0
                pushedVC?.navigationContentView?.alpha = 1
                isEndingInteractivePopGestureRecognizer = true
                
                /* 这里移除“关闭的那个视图控制器”的 contentView。
                   是为了防止 contentView 重复在 DynamicNavigationRootViewController 的 viewWillLayoutSubviews 方法内创建。
                 */
                popVC?.navigationContentView?.removeFromSuperview()
            } else {
                // 滑动未超过屏幕宽度的一半，取消滑动返回。
                popVC?.navigationContentView?.alpha = 1
                pushedVC?.navigationContentView?.alpha = 0
                isEndingInteractivePopGestureRecognizer = false
            }
            
            self.popViewController = nil
            self.pushedViewController = nil
            
        default:
            break
        }
    }
    
}

extension DynamicNavigationController: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
                
        guard let vc = viewController as? DynamicNavigationRootViewController else { return }

        // 动画渐渐显现 push 到的页面的 navigationContentView。而非直接生硬的显示。
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
            vc.navigationContentView?.alpha = 1
        }, completion: nil)
    }
    
}
