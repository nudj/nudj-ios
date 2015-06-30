//
//  AddJobCell.swift
//  Nudge
//
//  Created by Lachezar Todorov on 30.04.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import UIKit

enum AddJobbCellType {
    case Field
    case BigText
    case Tags
    case empty
}

@IBDesignable
class AddJobCell: UITableViewCell, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var thumb: UIImageView!

    @IBInspectable
    @IBOutlet weak var textField: UITextField!

    @IBOutlet weak var textView: UITextView!

    var isFilled = false
    var type: AddJobbCellType = AddJobbCellType.Field

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setup(type: AddJobbCellType, image: String, placeholder: String) {
        self.thumb.image = UIImage(named: image)
        self.thumb.alpha = 0.5
        self.type = type

        if (type == AddJobbCellType.Field) {
            self.textField.alpha = 0;
            //self.textView.removeFromSuperview()
            self.textField.placeholder = placeholder
        }else if(type ==  AddJobbCellType.empty){
            self.textField.alpha = 0;
            self.textField.alpha = 0;
        }else {
            self.textField.placeholder = placeholder
            self.textField.userInteractionEnabled = false
        }
    }

    func changeFilledStatus(status:Bool) {
        if (status != self.isFilled) {
            thumb.alpha = status ? 1 : 0.5
            self.isFilled = status

            if (self.type == AddJobbCellType.BigText) {
                self.textField.alpha = status ? 0 : 1
            }
        }
    }

    // MARK: - UITextFieldDelegate

    @IBAction func textFieldDidChange(sender: UITextField) {
        self.changeFilledStatus(count(sender.text) > 0)
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: - UITextViewDelegate

    func textViewDidChange(textView: UITextView) {
        self.changeFilledStatus(count(textView.text) > 0)
    }

}
