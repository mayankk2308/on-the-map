//Code by Jarrod Parkes from MyFavoriteMovies App
//Code minutely adapted to suit needs

import UIKit

class OverlayButton: UIButton {
    
    /* Constants for styling and configuration */
    let buttonSelectedColor = UIColor.gray
    let buttonColor = UIColor.lightGray
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
        _ = UIDevice.current.userInterfaceIdiom
        self.layer.masksToBounds = true
        self.layer.cornerRadius = borderedButtonCornerRadius
        self.highlightedBackingColor = buttonSelectedColor
        self.backingColor = buttonColor
        self.backgroundColor = buttonColor
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
        _ = UIDevice.current.userInterfaceIdiom
        let extraButtonPadding : CGFloat = phoneBorderedButtonExtraPadding
        var sizeThatFits = CGSize.zero
        sizeThatFits.width = super.sizeThatFits(size).width + extraButtonPadding
        sizeThatFits.height = borderedButtonHeight
        return sizeThatFits
        
    }
}
