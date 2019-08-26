//
//  DynamicNavigationRootViewController.swift
//  DynamicHeightNavigationBar
//
//  Created by Zhi Zhou on 2019/8/26.
//  Copyright © 2019 Zhi Zhou. All rights reserved.
//

import UIKit

open class DynamicNavigationRootViewController: UIViewController {
    
    open override var navigationController: DynamicNavigationController? {
                        
        guard let navigationController = super.navigationController as? DynamicNavigationController else { return nil }

        return navigationController
    }
    
    open var navigationBar: DynamicNavigationBar? {
        
        guard let navigationBar = navigationController?.navigationBar as? DynamicNavigationBar else { return nil }
                
        return navigationBar
    }
    
    open var navigationContentView: UIView?
    

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationContentView?.layoutIfNeeded()
        
        guard let navBar = navigationController?.navigationBar as? DynamicNavigationBar else { return }
        
        navBar.setContentViewHeight(navigationContentView?.bounds.height ?? 0)
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
                
        setupNavigationContentView()
    }
    
}

extension DynamicNavigationRootViewController {
    
    private func setupNavigationContentView() {
        
        guard let navigationContentView = navigationContentView else { return }
        
        navigationContentView.layoutIfNeeded()
        
        guard let navBar = navigationController?.navigationBar as? DynamicNavigationBar else { return }
        
        navBar.addContentSubview(navigationContentView)
                
        // 设定顶部偏移量，防止遮挡。
        additionalSafeAreaInsets.top = navBar.contentView.bounds.height
    }
    
}
