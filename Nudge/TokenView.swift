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

    @IBInspectable
    var tokenBorderWidth:CGFloat = 0

    var suggestionsParent:UIView? = nil

    var startEditClosure:((TokenView)->())? = nil
    var changedClosure:((TokenView)->())? = nil

    var setupMode = false
    var placeholderLabel:UILabel?

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

        backgroundColor = UIColor.clearColor()
        font = UIFont.systemFontOfSize(15)

        _tokenField.backgroundColor = UIColor.clearColor()

        searchResultBackgroundColor = UIColor.whiteColor()
        activityIndicatorColor = UIColor.blueColor()

        suggestionsParent = self.superview?.superview

        removesTokensOnEndEditing = false
        shouldSortResultsAlphabatically = false
    }

    func fillTokens(tokens:[String]) {
        setupMode = true

        self.deleteAllTokens()

        for t in tokens {
            addTokenWithTitle(t)
        }
        _tokenField.tokenize()

        setupMode = false
    }

    override func _showSearchResults() {
        if (_tokenField.isFirstResponder()) {

            if (_showingSearchResult) {
                return
            }

            _showingSearchResult = true

            if (KSUtils.isIpad()) {
                _popover?.presentPopoverFromRect(_tokenField.frame, inView: _tokenField, permittedArrowDirections: .Up, animated: false)

            } else {
                if let parent = suggestionsParent {
                    parent.addSubview(_searchTableView)
                    let point = parent.convertPoint(CGPoint(x: 0, y: bounds.height), fromView: self)
                    _searchTableView.frame.origin = point
                } else {
                    addSubview(_searchTableView)
                    _searchTableView.frame.origin = CGPoint(x: 0, y: bounds.height)
                }

                _searchTableView.hidden = false
                resizeSearchTable()
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
            } else {
                _searchTableView.frame.origin = CGPoint(x: 0, y: bounds.height)
            }

            resizeSearchTable()
        }
        
    }

    func resizeSearchTable() {
        if (_resultArray.count <= 0) {
            _hideSearchResults()
        } else {
            _searchTableView.layoutIfNeeded()
            _searchTableView.frame.size = _searchTableView.contentSize
        }
    }

    func prepareToken(token: KSToken) -> KSToken {
        if (tokenBackgroundColor != nil) {
            token.tokenBackgroundColor = tokenBackgroundColor!
        }

        if (tokenTextColor != nil) {
            token.tokenTextColor = tokenTextColor!
        }

        if (tokenBorderColor != nil) {
            token.borderWidth = self.tokenBorderWidth
            token.borderColor = tokenBorderColor!
        }

        return token
    }

    // MARK: KSTokenViewDelegate

    func tokenView(tokenView: KSTokenView, shouldChangeAppearanceForToken token: KSToken) -> KSToken? {
        return prepareToken(token)
    }

    func tokenView(token: KSTokenView, performSearchWithString string: String, completion: ((results: Array<AnyObject>) -> Void)?) {
        if var path = self.autocompleteEndpoint {

            if (count(string) <= 0) {
                return
            }

            path += "/" + string

            API.sharedInstance.get(path, params: nil, closure: { result in
                if let data: Array<String> = result["data"].arrayObject as? Array<String> {
                    completion!(results: data)
                } else {
                    completion!(results: [String]())
                }

                self._repositionSearchResults()

            }, errorHandler: { _ in
                completion!(results: [String]())
                self._repositionSearchResults()
            })
        }
    }

    func tokenView(token: KSTokenView, displayTitleForObject object: AnyObject) -> String {
        return object as! String
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        if (startEditClosure != nil) {
            startEditClosure!(self)
        }
        
        if(placeholderLabel != nil){
            placeholderLabel!.hidden = true
        }
    }
    
    

    func tokenView(tokenView: KSTokenView, didAddToken token: KSToken) {
        if (!setupMode) {
            self.changedClosure?(self)
        }
    }

    func tokenView(tokenView: KSTokenView, didDeleteToken token: KSToken) {
        if (!setupMode) {
            self.changedClosure?(self)
        }
    }

    func tokenView(tokenView: KSTokenView, didSelectToken token: KSToken) {
        if (!_tokenField.isFirstResponder()) {
            _tokenField.becomeFirstResponder()
            _tokenField.selectToken(token)
        }
        

    }

}