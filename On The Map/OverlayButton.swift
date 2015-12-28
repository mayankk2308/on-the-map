//Code by Jarrod Parkes from MyFavoriteMovies App
//Code minutely adapted to suit needs

import UIKit

class OverlayButton: UIButton {
    
    /* Constants for styling and configuration */
    let buttonSelectedColor = UIColor.grayColor()
    let buttonColor = UIColor.lightGrayColor()
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
        _ = UIDevice.currentDevice().userInterfaceIdiom
        self.layer.masksToBounds = true
        self.layer.cornerRadius = borderedButtonCornerRadius
        self.highlightedBackingColor = buttonSelectedColor
        self.backingColor = buttonColor
        self.backgroundColor = buttonColor
        self.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: titleLabelFontSize)
    }
    
    // MARK: - Setters
    
    private func setBackingColor(backingColor : UIColor) -> Void {
        if (self.backingColor != nil) {
            self.backingColor = backingColor;
            self.backgroundColor = backingColor;
        }
    }
    
    private func setHighlightedBackingColor(highlightedBackingColor: UIColor) -> Void {
        self.highlightedBackingColor = highlightedBackingColor
        self.backingColor = highlightedBackingColor
    }
    
    // MARK: - Tracking
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent: UIEvent?) -> Bool {
        self.backgroundColor = self.highlightedBackingColor
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent: UIEvent?) {
        self.backgroundColor = self.backingColor
    }

    
    override func cancelTrackingWithEvent(event: UIEvent?) {
        self.backgroundColor = self.backingColor
    }
    
    // MARK: - Layout
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        _ = UIDevice.currentDevice().userInterfaceIdiom
        let extraButtonPadding : CGFloat = phoneBorderedButtonExtraPadding
        var sizeThatFits = CGSizeZero
        sizeThatFits.width = super.sizeThatFits(size).width + extraButtonPadding
        sizeThatFits.height = borderedButtonHeight
        return sizeThatFits
        
    }
}
