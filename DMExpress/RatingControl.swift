//
//  RatingControl.swift
//  DMExpress
//
//  Created by Jessica Mouta on 13/02/19.
//  Copyright © 2019 Narlei A Moreira. All rights reserved.
//
import UIKit

@IBDesignable class RatingControl: UIStackView {
    
    //MARK: Properties
    private var ratingButtons = [UIButton]()
    // Load Button Images
    
    var highlightedStar:UIImage?
    
    var rating = 0.0 {
        didSet {
            updateButtonSelectionStates()
        }
    }
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButtons()
        }
    }
    
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    //MARK: Private Methods
    private func setupButtons() {
        
        // clear any existing buttons
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        ratingButtons.removeAll()
        
        let bundle = Bundle(for: type(of: self))
        let filledStar = UIImage(named: "ic_star", in: bundle, compatibleWith: self.traitCollection)?.maskWithColor(color: UIColor.orange)
        let emptyStar = UIImage(named:"ic_star_border", in: bundle, compatibleWith: self.traitCollection)?.maskWithColor(color: UIColor.orange)
        highlightedStar = UIImage(named:"ic_star_half", in: bundle, compatibleWith: self.traitCollection)?.maskWithColor(color: UIColor.orange)
        
        for index in 0..<starCount {
            
            
            // Create the button
            let button = UIButton()
            
            // Set the button images
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(filledStar, for: .highlighted)
            button.setImage(filledStar, for: [.highlighted, .selected])
            
            // Add constraints
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            // Set the accessibility label
            button.accessibilityLabel = "Set \(index + 1) star rating"
            
            // Setup the button action
            button.addTarget(self, action: #selector(RatingControl.ratingButtonTapped(button:)), for: .touchUpInside)
            
            // Add the button to the stack
            addArrangedSubview(button)
            
            // Add the new button to the rating button array
            ratingButtons.append(button)
        }
        updateButtonSelectionStates()
    }
    //MARK: Button Action
    @objc func ratingButtonTapped(button: UIButton) {
        guard let index = ratingButtons.index(of: button) else {
            fatalError("The button, \(button), is not in the ratingButtons array: \(ratingButtons)")
        }
        
        // Calculate the rating of the selected button
        let selectedRating = index + 1
        
        if selectedRating == Int(rating) {
            // If the selected star represents the current rating, reset the rating to 0.
            rating = 0.0
        } else {
            // Otherwise set the rating to the selected star
            rating = Double(selectedRating)
        }
    }
    
    private func updateButtonSelectionStates() {
        let irating = Int(rating)
        for (index, button) in ratingButtons.enumerated() {
            
            // If the index of a button is less than the rating, that button should be selected.
            button.isSelected = index < irating
            // Set the hint string for the currently selected star
            let hintString: String?
            if irating == index + 1 {
                hintString = "Tap to reset the rating to zero."
            } else {
                hintString = nil
            }
            
            // Calculate the value string
            let valueString: String
            switch (irating) {
            case 0:
                valueString = "No rating set."
            case 1:
                valueString = "1 star set."
            default:
                valueString = "\(irating) stars set."
            }
            
            // Assign the hint string and value string
            button.accessibilityHint = hintString
            button.accessibilityValue = valueString
        }
        
        let restDo = rating - Double(irating)
        
        if (restDo > 0.21 ) {
            ratingButtons[irating].setImage(highlightedStar, for: .selected)
            ratingButtons[irating].isSelected =  true
        }
        
    }
}
    extension UIImage {
        public func maskWithColor(color: UIColor) -> UIImage {

            UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
            let context = UIGraphicsGetCurrentContext()!

            let rect = CGRect(origin: CGPoint.zero, size: size)

            color.setFill()
            self.draw(in: rect)

            context.setBlendMode(.sourceIn)
            context.fill(rect)

            let resultImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return resultImage
        }

}
