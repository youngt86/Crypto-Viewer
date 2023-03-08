//
//  CustomButton.swift
//  CoinFlip Project
//
//  Created by Travis Young on 3/3/23.
//

import Foundation
import UIKit

class CustomButton: UIButton {
    
    var title: String
    
    required init(title: String) {
        
        self.title = title
        super.init(frame: .zero)
        
        setTitle(self.title, for: .normal)
        backgroundColor = UIColor(named: "buttonColor")
        layer.cornerRadius = 5
        height(50)
        width(100)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
