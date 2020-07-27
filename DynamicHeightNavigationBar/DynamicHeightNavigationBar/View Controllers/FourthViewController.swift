//
//  FourthViewController.swift
//  DynamicHeightNavigationBar
//
//  Created by Zhi Zhou on 2019/8/26.
//  Copyright © 2019 Zhi Zhou. All rights reserved.
//

import UIKit

class FourthViewController: DynamicNavigationRootViewController {
    
    private let seg = UISegmentedControl()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setupInterface()
    }

}

extension FourthViewController {
    
    private func setupInterface() {
        view.backgroundColor = .green
        title = "Fourth"

        setupNavBar()
    }
    
    private func setupNavBar() {
                                
        seg.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 31)
        
        seg.insertSegment(withTitle: "First", at: 0, animated: false)
        seg.insertSegment(withTitle: "Second", at: 1, animated: false)
        
        seg.selectedSegmentIndex = 1
        
        navigationContentView = seg
    }

}



































