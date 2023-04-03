//
//  DynamicNavigationRootViewController.swift
//  DynamicHeightNavigationBar
//
//  Created by Zhi Zhou on 2019/8/26.
//  Copyright © 2019 Zhi Zhou. All rights reserved.
//

import UIKit

open class DynamicNavigationRootViewController: UIViewController {
    
    open var navigationBar: DynamicNavigationBar? {
        
        guard let navigationBar = navigationController?.navigationBar as? DynamicNavigationBar else { return nil }
        
        return navigationBar
    }
    
    public let navigationBarContentView = DynamicNavigationBarContentView()
        
    open var mode: DynamicNavigationBar.ContentViewDistributionMode = .new
        
    /// 紧缩状态下的高度
    private var compactHeight: CGFloat = 0
    
    /// 扩展状态下的高度
    private var expandedHeight: CGFloat = 0
    
    open var isExpanded = false
    
    private var compactView: UIView?
    private var expandedView: UIView?
            

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        initializeNavigationBarStatus()
        setupNavigationBarHeight()
    }

    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
                
        setupNavigationContentView()
    }
    
}

extension DynamicNavigationRootViewController {
    
    private func initializeNavigationBarStatus() {
        // 设定顶部偏移量，防止遮挡。
        additionalSafeAreaInsets.top = compactHeight
        
        if !isExpanded {
            compactView?.alpha = 1
            expandedView?.alpha = 0
        }
    }
    
    private func setupNavigationBarHeight() {
        
        guard let navigationController = navigationController as? DynamicNavigationController else { return }
                
        // 根据滑动返回手势是否完成，来设定 navigationContentView 的透明度。
        // 以此在进行 push 操作时，下一个 VC 的 navigationContentView 渐渐动画显现。
        navigationBarContentView.alpha = navigationController.isEndingInteractivePopGestureRecognizer ? 0 : 1
                
        navigationBarContentView.layoutIfNeeded()
                        
        navigationBar?.setContentViewHeight(isExpanded ? expandedHeight : compactHeight)
    }
    
    private func setupNavigationContentView() {
        // 防止多次调用，添加多次 navigationBarContentView。
        navigationBarContentView.removeFromSuperview()
        navigationBar?.addContentSubview(navigationBarContentView)
    }
    
}

extension DynamicNavigationRootViewController {
    
    /// 设定导航栏自定义内容视图
    /// - parameter view: 自定义视图。
    /// - parameter expandedView: 在展开状态下的自定义视图（默认为空）。
    /// - parameter mode: expandedView 视图的显示模式。
    public func setNavigationBarContentView(_ view: UIView, expandedView: UIView? = nil, mode: DynamicNavigationBar.ContentViewDistributionMode = .new) {
        
        self.mode = mode
        self.compactView = view
        self.expandedView = expandedView

        navigationBarContentView.translatesAutoresizingMaskIntoConstraints = false
        navigationBarContentView.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        expandedView?.translatesAutoresizingMaskIntoConstraints = false
                
        let compactIntrinsicHeight = (view.bounds.height > 0) ? view.bounds.height : ((view.intrinsicContentSize.height > 0) ? view.intrinsicContentSize.height : view.bounds.height)
            
        compactHeight = compactIntrinsicHeight
                        
        switch mode {
        case .new:
            if let expandedView = expandedView {
                                
                NSLayoutConstraint.activate([
                    view.topAnchor.constraint(equalTo: navigationBarContentView.topAnchor),
                    view.leftAnchor.constraint(equalTo: navigationBarContentView.leftAnchor),
                    view.rightAnchor.constraint(equalTo: navigationBarContentView.rightAnchor),
                    navigationBarContentView.heightAnchor.constraint(equalToConstant: compactIntrinsicHeight),
                    
                    // 强制 view 使用正确的高度
                    view.heightAnchor.constraint(equalToConstant: compactIntrinsicHeight)
                ])
                                
                /* ---------- */
                
                navigationBarContentView.addSubview(expandedView)
                                
                expandedView.alpha = 0
                
                let expandedIntrinsicHeight = (expandedView.bounds.height > 0) ? expandedView.bounds.height : ((expandedView.intrinsicContentSize.height > 0) ? expandedView.intrinsicContentSize.height : expandedView.bounds.height)
                
                NSLayoutConstraint.activate([
                    expandedView.leftAnchor.constraint(equalTo: navigationBarContentView.leftAnchor),
                    expandedView.rightAnchor.constraint(equalTo: navigationBarContentView.rightAnchor),
                    expandedView.topAnchor.constraint(equalTo: view.bottomAnchor),
                    
                    // 强制 view 使用正确的高度
                    expandedView.heightAnchor.constraint(equalToConstant: expandedIntrinsicHeight)
                ])
                                                
                expandedHeight = compactIntrinsicHeight + expandedIntrinsicHeight
            }
            else {
                NSLayoutConstraint.activate([
                    view.leftAnchor.constraint(equalTo: navigationBarContentView.leftAnchor),
                    view.rightAnchor.constraint(equalTo: navigationBarContentView.rightAnchor),
                    view.topAnchor.constraint(equalTo: navigationBarContentView.topAnchor),
                    navigationBarContentView.heightAnchor.constraint(equalToConstant: compactIntrinsicHeight),
                ])
            }
                        
        case .replace:
            // 选择覆盖，那么 expandedView 必须不能为空，否则仅设定 view。
            guard let expandedView = expandedView else {
                NSLayoutConstraint.activate([
                    view.leftAnchor.constraint(equalTo: navigationBarContentView.leftAnchor),
                    view.rightAnchor.constraint(equalTo: navigationBarContentView.rightAnchor),
                    view.topAnchor.constraint(equalTo: navigationBarContentView.topAnchor),
                    navigationBarContentView.heightAnchor.constraint(equalToConstant: compactIntrinsicHeight)
                ])
                                
                break
            }

            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: navigationBarContentView.topAnchor),
                view.leftAnchor.constraint(equalTo: navigationBarContentView.leftAnchor),
                view.rightAnchor.constraint(equalTo: navigationBarContentView.rightAnchor),
                navigationBarContentView.heightAnchor.constraint(equalToConstant: compactIntrinsicHeight),
                
                // 强制 view 使用正确的高度
                view.heightAnchor.constraint(equalToConstant: compactIntrinsicHeight)
            ])
                            
            /* ---------- */
        
            navigationBarContentView.addSubview(expandedView)
            
            expandedView.alpha = 0
            
            let expandedIntrinsicHeight = (expandedView.bounds.height > 0) ? expandedView.bounds.height : ((expandedView.intrinsicContentSize.height > 0) ? expandedView.intrinsicContentSize.height : expandedView.bounds.height)
            
            NSLayoutConstraint.activate([
                expandedView.topAnchor.constraint(equalTo: navigationBarContentView.topAnchor),
                expandedView.leftAnchor.constraint(equalTo: navigationBarContentView.leftAnchor),
                expandedView.rightAnchor.constraint(equalTo: navigationBarContentView.rightAnchor),
                
                // 强制 view 使用正确的高度
                expandedView.heightAnchor.constraint(equalToConstant: expandedIntrinsicHeight)
            ])
                        
            expandedHeight = expandedIntrinsicHeight
        }
    }
    
    /// 修改导航栏展开状态
    public func changeNavigationBarActiveDisplayMode() {
        
        isExpanded.toggle()
                        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.expandedView?.alpha = self.isExpanded ? 1 : 0
            
            if self.mode == .replace {
                self.compactView?.alpha = self.isExpanded ? 0 : 1
            }
            
            self.navigationBar?.setContentViewHeight(self.isExpanded ? self.expandedHeight : self.compactHeight)
            self.navigationBar?.layoutIfNeeded()
            
            // 设定顶部偏移量，防止遮挡。
//            self.additionalSafeAreaInsets.top = self.isExpanded ? self.expandedHeight : self.compactHeight
        })
    }
    
}




































