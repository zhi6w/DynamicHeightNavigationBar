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
        
        let pushItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(push))
                
        navigationItem.rightBarButtonItem = pushItem
    }
    
}

extension ThirdViewController {
    
    @objc private func push() {
        
        let fourthVC = FourthViewController()
        
        navigationController?.pushViewController(fourthVC, animated: true)
    }
    
}



































