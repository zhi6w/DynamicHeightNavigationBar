//
//  DynamicNavigationRootViewController.swift
//  DynamicHeightNavigationBar
//
//  Created by Zhi Zhou on 2019/8/26.
//  Copyright © 2019 Zhi Zhou. All rights reserved.
//

import UIKit

open class DynamicNavigationRootViewController: UIViewController {
    
    open override var navigationController: UINavigationController? {
                        
        guard let navigationController = super.navigationController as? DynamicNavigationController
            else { return super.navigationController }

        return navigationController
    }
    
    open var navigationBar: DynamicNavigationBar? {
        
        guard let navigationBar = navigationController?.navigationBar as? DynamicNavigationBar else { return nil }
                
        return navigationBar
    }
    
    open var navigationContentView: UIView?
    

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        guard let navigationController = navigationController as? DynamicNavigationController else { return }
        
        // 根据滑动返回手势是否完成，来设定 navigationContentView 的透明度。
        // 以此在进行 push 操作时，下一个 VC 的 navigationContentView 渐渐动画显现。
        navigationContentView?.alpha = navigationController.isEndingInteractivePopGestureRecognizer ? 0 : 1
                
        navigationContentView?.layoutIfNeeded()
                                                        
        navigationBar?.setContentViewHeight(navigationContentView?.bounds.height ?? 0)
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setupNavigationContentView()
    }
    
}

extension DynamicNavigationRootViewController {
    
    private func setupNavigationContentView() {
        
        guard let navigationContentView = navigationContentView else { return }
                                
        guard let navBar = navigationController?.navigationBar as? DynamicNavigationBar else { return }
        
        navBar.addContentSubview(navigationContentView)
                
        // 设定顶部偏移量，防止遮挡。
        additionalSafeAreaInsets.top = navBar.contentView.bounds.height
    }
    
}

