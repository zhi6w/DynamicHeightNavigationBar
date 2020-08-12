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
    
    public let navigationBarContentView = UIView()
    
    /// 导航栏自定义内容视图的显示模式
    public enum NavigationBarContentViewDistributionMode: Int, CaseIterable {
        
        /// 继续添加新的视图
        case new = 0
        
        /// 覆盖老的视图
        case replace = 1
    }
    
    open var mode: NavigationBarContentViewDistributionMode = .new
    
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
        navigationBar?.addContentSubview(navigationBarContentView)
    }
    
}

extension DynamicNavigationRootViewController {
    
    /// 设定导航栏自定义内容视图
    /// - parameter view: 自定义视图。
    /// - parameter expandedView: 在展开状态下的自定义视图（默认为空）。
    /// - parameter mode: expandedView 视图的显示模式。
    open func setNavigationBarContentView(_ view: UIView, expandedView: UIView? = nil, mode: NavigationBarContentViewDistributionMode = .new) {
        
        self.mode = mode
        self.compactView = view
        self.expandedView = expandedView
        
        navigationBarContentView.translatesAutoresizingMaskIntoConstraints = false
        navigationBarContentView.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        expandedView?.translatesAutoresizingMaskIntoConstraints = false
        
        compactHeight = view.bounds.height
                
        switch mode {
        case .new:
            if let expandedView = expandedView {
                                
                NSLayoutConstraint.activate([
                    view.topAnchor.constraint(equalTo: navigationBarContentView.topAnchor),
                    view.leftAnchor.constraint(equalTo: navigationBarContentView.leftAnchor),
                    view.rightAnchor.constraint(equalTo: navigationBarContentView.rightAnchor),
                    view.heightAnchor.constraint(equalToConstant: view.bounds.height),
                    navigationBarContentView.heightAnchor.constraint(equalToConstant: view.bounds.height)
                ])
                                
                /* ---------- */
                
                navigationBarContentView.addSubview(expandedView)
                                
                expandedView.alpha = 0
                
                NSLayoutConstraint.activate([
                    expandedView.leftAnchor.constraint(equalTo: navigationBarContentView.leftAnchor),
                    expandedView.rightAnchor.constraint(equalTo: navigationBarContentView.rightAnchor),
                    expandedView.topAnchor.constraint(equalTo: view.bottomAnchor)
                ])
                
                expandedHeight = view.bounds.height + expandedView.bounds.height
            }
            else {
                NSLayoutConstraint.activate([
                    view.leftAnchor.constraint(equalTo: navigationBarContentView.leftAnchor),
                    view.rightAnchor.constraint(equalTo: navigationBarContentView.rightAnchor),
                    view.topAnchor.constraint(equalTo: navigationBarContentView.topAnchor),
                    view.bottomAnchor.constraint(equalTo: navigationBarContentView.bottomAnchor),
                    navigationBarContentView.heightAnchor.constraint(equalToConstant: view.bounds.height)
                ])
            }
                        
        case .replace:
            // 选择覆盖，那么 expandedView 必须不能为空，否则仅设定 view。
            guard let expandedView = expandedView else {
                NSLayoutConstraint.activate([
                    view.leftAnchor.constraint(equalTo: navigationBarContentView.leftAnchor),
                    view.rightAnchor.constraint(equalTo: navigationBarContentView.rightAnchor),
                    view.topAnchor.constraint(equalTo: navigationBarContentView.topAnchor),
                    view.bottomAnchor.constraint(equalTo: navigationBarContentView.bottomAnchor),
                    navigationBarContentView.heightAnchor.constraint(equalToConstant: view.bounds.height)
                ])
                                
                break
            }
                        
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: navigationBarContentView.topAnchor),
                view.leftAnchor.constraint(equalTo: navigationBarContentView.leftAnchor),
                view.rightAnchor.constraint(equalTo: navigationBarContentView.rightAnchor),
                view.heightAnchor.constraint(equalToConstant: view.bounds.height),
                navigationBarContentView.heightAnchor.constraint(equalToConstant: view.bounds.height)
            ])
                            
            /* ---------- */
        
            navigationBarContentView.addSubview(expandedView)
            
            expandedView.alpha = 0
            
            NSLayoutConstraint.activate([
                expandedView.topAnchor.constraint(equalTo: navigationBarContentView.topAnchor),
                expandedView.leftAnchor.constraint(equalTo: navigationBarContentView.leftAnchor),
                expandedView.rightAnchor.constraint(equalTo: navigationBarContentView.rightAnchor)
            ])
            
            expandedHeight = expandedView.bounds.height
        }
    }
    
    /// 修改导航栏展开状态
    open func changeNavigationBarActiveDisplayMode() {
        
        isExpanded.toggle()
                        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.expandedView?.alpha = self.isExpanded ? 1 : 0
            
            if self.mode == .replace {
                self.compactView?.alpha = self.isExpanded ? 0 : 1
            }
            
            self.navigationBar?.setContentViewHeight(self.isExpanded ? self.expandedHeight : self.compactHeight)
            self.navigationBar?.layoutIfNeeded()
            
            // 设定顶部偏移量，防止遮挡。
//            self.additionalSafeAreaInsets.top = self.isExpanded ? self.expandedHeight :  self.compactHeight
        })
    }
    
}




































