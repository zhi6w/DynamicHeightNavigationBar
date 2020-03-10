//
//  ThirdViewController.swift
//  DynamicHeightNavigationBar
//
//  Created by Zhi Zhou on 2019/8/26.
//  Copyright © 2019 Zhi Zhou. All rights reserved.
//

import UIKit

class ThirdViewController: DynamicNavigationRootViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupInterface()
    }

}

extension ThirdViewController {
    
    private func setupInterface() {
        view.backgroundColor = .cyan
        title = "Third"
        
        setupNavBar()
    }
    
    private func setupNavBar() {
        
        // 修复在 iOS 13 下，滑动返回取消后，navigationItem 中的 UIBarButtonItem 图标透明度变淡的问题。
        if #available(iOS 13.0, *) {
            let image = UIImage(systemName: "play.fill")
            let pushButton = UIButton(type: .system)
            pushButton.setImage(image, for: .normal)
            pushButton.addTarget(self, action: #selector(push), for: .touchUpInside)
            
            let pushItem = UIBarButtonItem(customView: pushButton)
            
            navigationItem.rightBarButtonItem = pushItem
        } else {
            let pushItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(push))
            
            navigationItem.rightBarButtonItem = pushItem
        }
    }
    
}

extension ThirdViewController {
    
    @objc private func push() {
        
        let fourthVC = FourthViewController()
        
        navigationController?.pushViewController(fourthVC, animated: true)
    }
    
}



































