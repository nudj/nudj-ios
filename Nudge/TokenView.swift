//
//  TokenView.swift
//  Nudge
//
//  Created by Lachezar Todorov on 8.06.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import UIKit
import Foundation

class TokenView: KSTokenView, KSTokenViewDelegate {

    @IBInspectable
    var autocompleteEndpoint:String? = nil

    @IBInspectable
    var tokenBackgroundColor:UIColor? = nil

    @IBInspectable
    var tokenTextColor:UIColor? = nil

    @IBInspectable
    var tokenBorderColor:UIColor? = nil


    var suggestionsParent:UIView? = nil

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }


    func setup() {
        promptText = "";

        self.delegate = self

        backgroundColor = UIColor.whiteColor()
        font = UIFont.systemFontOfSize(15)

        _tokenField.backgroundColor = UIColor.whiteColor()

        searchResultBackgroundColor = UIColor.whiteColor()
        activityIndicatorColor = UIColor.blueColor()

        suggestionsParent = self.superview?.superview

        removesTokensOnEndEditing = false
        shouldSortResultsAlphabatically = false
    }

    override func _showSearchResults() {
        if (_tokenField.isFirstResponder()) {
            _showingSearchResult = true
            if (KSUtils.isIpad()) {
                _popover?.presentPopoverFromRect(_tokenField.frame, inView: _tokenField, permittedArrowDirections: .Up, animated: false)

            } else {
                if let parent = suggestionsParent {
                    parent.addSubview(_searchTableView)
                    let point = parent.convertPoint(CGPoint(x: 0, y: bounds.height), fromView: self)
                    _searchTableView.frame.origin = point
                    _searchTableView.hidden = false
                } else {
                    addSubview(_searchTableView)
                    _searchTableView.frame.origin = CGPoint(x: 0, y: bounds.height)
                    _searchTableView.hidden = false
                }
            }
        }
    }

    override func _repositionSearchResults() {
        if (!_showingSearchResult) {
            return
        }

        if (KSUtils.isIpad()) {
            if (_popover!.popoverVisible) {
                _popover?.dismissPopoverAnimated(false)
            }
            if (_showingSearchResult) {
                _popover?.presentPopoverFromRect(_tokenField.frame, inView: _tokenField, permittedArrowDirections: .Up, animated: false)
            }

        } else {
            if let parent = suggestionsParent {
                let point = parent.convertPoint(CGPoint(x: 0, y: bounds.height), fromView: self)
                _searchTableView.frame.origin = point
                _searchTableView.layoutIfNeeded()
            } else {
                _searchTableView.frame.origin = CGPoint(x: 0, y: bounds.height)
                _searchTableView.layoutIfNeeded()
            }
        }
        
    }

    override func addToken(token: KSToken) -> KSToken? {
        prepareToken(token)

        return super.addToken(token)
    }

    func prepareToken(token: KSToken) {
        if (tokenBackgroundColor != nil) {
            token.tokenBackgroundColor = tokenBackgroundColor!
        }

        if (tokenTextColor != nil) {
            token.tokenTextColor = tokenTextColor!
        }

        if (tokenBorderColor != nil) {
            token.borderWidth = 1
            token.borderColor = tokenBorderColor!
        }
    }

    // MARK: KSTokenViewDelegate

    func tokenView(token: KSTokenView, performSearchWithString string: String, completion: ((results: Array<AnyObject>) -> Void)?) {
        if var path = self.autocompleteEndpoint {

            if (count(string) <= 0) {
                return
            }

            path += "/" + string

            API.sharedInstance.get(path, params: nil, closure: { result in
                if let data: Array<String> = result["data"].arrayObject as? Array<String> {
                    println(data)
                    completion!(results: data)
                }
//                var data: Array<String> = result["data"].arrayObject as! Array<String>
//                println(data)
//                completion!(results: data)
            }, errorHandler: { _ in

            })
        }
    }

    func tokenView(token: KSTokenView, displayTitleForObject object: AnyObject) -> String {
        return object as! String
    }

    func tokenView(tokenView: KSTokenView, didChangeFrame frame: CGRect) {
        UIView.animateWithDuration(0.25, animations: { _ in
            if var parentFrame = self.superview?.superview?.frame {
                parentFrame.size.height = self.frame.origin.y + self.frame.height
                self.superview!.superview!.frame = parentFrame
            }
        })
    }

}