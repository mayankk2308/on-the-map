//Code by Jarrod Parkes from MyFavoriteMovies App
//Code minutely adapted to suit needs

import UIKit

class LoginButton: UIButton {
    
    /* Constants for styling and configuration */
    let darkerRed = UIColor(red: 1.0, green: 0.2, blue: 0.1, alpha:1.0)
    let lighterRed = UIColor(red: 0.9, green:0.2, blue:0.2, alpha: 1.0)
    let titleLabelFontSize : CGFloat = 15.0
    let borderedButtonHeight : CGFloat = 44.0
    let borderedButtonCornerRadius : CGFloat = 4.0
    let phoneBorderedButtonExtraPadding : CGFloat = 14.0
    
    var backingColor : UIColor? = nil
    var highlightedBackingColor : UIColor? = nil
    
    // MARK: - Initialization
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.themeBorderedButton()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.themeBorderedButton()
    }
    
    func themeBorderedButton() -> Void {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = borderedButtonCornerRadius
        self.highlightedBackingColor = darkerRed
        self.backingColor = lighterRed
        self.backgroundColor = lighterRed
        self.setTitleColor(UIColor.white, for: UIControlState())
        self.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: titleLabelFontSize)
    }
    
    // MARK: - Setters
    
    fileprivate func setBackingColor(_ backingColor : UIColor) -> Void {
        if (self.backingColor != nil) {
            self.backingColor = backingColor;
            self.backgroundColor = backingColor;
        }
    }
    
    fileprivate func setHighlightedBackingColor(_ highlightedBackingColor: UIColor) -> Void {
        self.highlightedBackingColor = highlightedBackingColor
        self.backingColor = highlightedBackingColor
    }
    
    // MARK: - Tracking
    
    override func beginTracking(_ touch: UITouch, with withEvent: UIEvent?) -> Bool {
        self.backgroundColor = self.highlightedBackingColor
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with withEvent: UIEvent?) {
        self.backgroundColor = self.backingColor
    }
    
    override func cancelTracking(with event: UIEvent?) {
        self.backgroundColor = self.backingColor
    }
    
    // MARK: - Layout
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let extraButtonPadding : CGFloat = phoneBorderedButtonExtraPadding
        var sizeThatFits = CGSize.zero
        sizeThatFits.width = super.sizeThatFits(size).width + extraButtonPadding
        sizeThatFits.height = borderedButtonHeight
        return sizeThatFits
        
    }
}
