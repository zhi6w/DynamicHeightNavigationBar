//
//  DynamicBarBackgroundShadowView.swift
//  DynamicHeightNavigationBar
//
//  Created by Zhi Zhou on 2023/4/3.
//  Copyright © 2023 Zhi Zhou. All rights reserved.
//

import UIKit

open class DynamicBarBackgroundShadowView: UIView {
    
    open override var intrinsicContentSize: CGSize {
        if #available(iOS 13.0, *) {
            let scale = self.window?.windowScene?.screen.scale ?? 1
            return CGSize(width: super.intrinsicContentSize.width, height: 1 / scale)
        } else {
            return CGSize(width: super.intrinsicContentSize.width, height: 1 / UIScreen.main.scale)
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupInterface()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension DynamicBarBackgroundShadowView {
    
    private func setupInterface() {
        backgroundColor = chromeShadowColor
    }
    
}

extension DynamicBarBackgroundShadowView {
    
    /// 灰色阴影
    public var chromeShadowColor: UIColor {
        
        guard let systemChromeShadowColor = UIColor.value(forKey: "_systemChromeShadowColor") as? UIColor
        else {
            if #available(iOS 13.0, *) {
                return UIColor(dynamicProvider: { $0.userInterfaceStyle == .dark ? .init(white: 1, alpha: 0.15) : .init(white: 0, alpha: 0.3) })
            } else {
                return .init(white: 0, alpha: 0.3)
            }
        }

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        systemChromeShadowColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
}

