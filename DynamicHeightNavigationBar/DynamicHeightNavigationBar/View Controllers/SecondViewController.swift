//
//  SecondViewController.swift
//  DynamicHeightNavigationBar
//
//  Created by Zhi Zhou on 2019/8/26.
//  Copyright © 2019 Zhi Zhou. All rights reserved.
//

import UIKit

class SecondViewController: DynamicNavigationRootViewController {
    
    private let toolbar = UIToolbar()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
        setupInterface()
    }

}

extension SecondViewController {
    
    private func setupInterface() {
        view.backgroundColor = .yellow
        title = "Second"
        
        setupNavBar()
        setupNavgationContentView()
    }
    
    private func setupNavBar() {
        
        let pushItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(push))
                
        navigationItem.rightBarButtonItem = pushItem
    }
    
    private func setupNavgationContentView() {

        toolbar.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 30)
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        navigationContentView = toolbar
    }
    
}

extension SecondViewController {
    
    @objc private func push() {
        
        let thirdVC = ThirdViewController()
        
        navigationController?.pushViewController(thirdVC, animated: true)
    }
    
}

extension SecondViewController {
    
    private func loadData() {
        
        let weekTitles = Calendar.current.shortWeekdaySymbols
        
        let items = weekTitles.enumerated().compactMap { (value) -> [UIBarButtonItem]? in
            let button = UIButton()
            button.setTitle(value.element, for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            
            let item = UIBarButtonItem(customView: button)
            
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            
            if value.offset == weekTitles.endIndex - 1 {
                return [flexibleSpace, item, flexibleSpace]
            } else {
                return [flexibleSpace, item]
            }
        }

        toolbar.items = items.joined().compactMap({ return $0 })
    }
    
}

































