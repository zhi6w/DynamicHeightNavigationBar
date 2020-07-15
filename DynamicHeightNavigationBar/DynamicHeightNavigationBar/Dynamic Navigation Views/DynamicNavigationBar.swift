//
//  DynamicNavigationBar.swift
//  DynamicHeightNavigationBar
//
//  Created by Zhi Zhou on 2019/8/26.
//  Copyright © 2019 Zhi Zhou. All rights reserved.
//

import UIKit

open class DynamicNavigationBar: UINavigationBar {
    
    public let effectView = UIVisualEffectView()
        
    open var effect: UIVisualEffect? {
        didSet {
            effectView.effect = effect
        }
    }
    
    public let contentView = UIView()
    
    /// NavgationBar 分割线
    private let separator = UIView()
        
    open var separatorColor: UIColor? {
        didSet {
            separator.backgroundColor = separatorColor
        }
    }
    
    open var isHiddenSeparator: Bool = false {
        didSet {
            separator.isHidden = isHiddenSeparator
        }
    }
    
    open var contentViewHeightLayoutConstraint: NSLayoutConstraint?
    
    private var effectViewTopLayoutConstraint: NSLayoutConstraint?
    

    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        setupInterface()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupInterface()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
                
        sendSubviewToBack(effectView)
                
        effectViewTopLayoutConstraint?.constant = -UIApplication.shared.statusBarFrame.height
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        // 拦截：超出 navigationBar 视图范围内的子控件（contentView）点击事件
        
        if clipsToBounds || isHidden || alpha == 0 {
            return nil
        }
        
        for subview in subviews.reversed() {
            let subviewPoint = subview.convert(point, from: self)
            if let view = subview.hitTest(subviewPoint, with: event) {
                return view
            }
        }

        return nil
    }
    
}

extension DynamicNavigationBar {
    
    private func setupInterface() {
        setupContentView()
        setupSeparatorView()
        setupEffectView()
    }
    
    private func setupContentView() {

        contentView.backgroundColor = .clear
        contentView.clipsToBounds = true
        
        addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentViewHeightLayoutConstraint = NSLayoutConstraint(item: contentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
            contentView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0),
            contentView.topAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            contentViewHeightLayoutConstraint!
        ])
    }
        
    private func setupSeparatorView() {
        
        if #available(iOS 13.0, *) {
            separator.backgroundColor = UIColor(named: "NavigationBarSeparatorColor")
        } else {
            separator.backgroundColor = #colorLiteral(red: 0.7019607843, green: 0.7019607843, blue: 0.7019607843, alpha: 1)
        }
                
        // separator: 0.23529411764705882 0.23529411764705882 0.2627450980392157 0.29
        // custom: 0.7019608020782471 0.7019608020782471 0.7019608020782471 1.0

        addSubview(separator)
        
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        separator.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        separator.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        separator.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
    }
    
    private func setupEffectView() {
        
        if #available(iOS 13.0, *) {
            effectView.effect = UIBlurEffect(style: .systemMaterial)
        } else {
            effectView.effect = UIBlurEffect(style: .extraLight)
        }
        
        insertSubview(effectView, at: 0)
        
        effectView.translatesAutoresizingMaskIntoConstraints = false
                
        effectViewTopLayoutConstraint = NSLayoutConstraint(item: effectView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: -UIApplication.shared.statusBarFrame.height)
                
        NSLayoutConstraint.activate([
            effectView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
            effectView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0),
            effectViewTopLayoutConstraint!,
            effectView.bottomAnchor.constraint(equalTo: separator.bottomAnchor, constant: -1 / UIScreen.main.scale),
        ])
    }
    
}

extension DynamicNavigationBar {
    
    /// 设定 contentView 高度
    /// - 高度设定必须在 UIViewController 的 viewWillAppear(_ animated: Bool) 方法内执行。
    open func setContentViewHeight(_ height: CGFloat) {
        contentViewHeightLayoutConstraint?.constant = height
    }
    
    open func addContentSubview(_ view: UIView) {
        
//        print(self.items?.first?.searchController)
        
        contentView.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0).isActive = true
        view.rightAnchor.constraint(equalTo:contentView.rightAnchor, constant: 0).isActive = true
        view.heightAnchor.constraint(equalToConstant: view.bounds.height).isActive = true
    }
    
}

