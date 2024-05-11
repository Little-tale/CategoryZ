//
//  PlaceholderTextView.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/15/24.
//

import UIKit
import SnapKit

final class PlaceholderTextView: UITextView {
    
    // MARK: Constant
    private enum Const {
        static let containerInset = UIEdgeInsets(top: 20, left: 14, bottom: 20, right: 14)
        static let placeholderColor = JHColor.darkGray
    }
    
    var textFont: UIFont? {
        didSet {
            placeholderTextView.font = textFont
            font = textFont
        }
    }
    
    // MARK: UI
    private let placeholderTextView: UITextView = {
        let view = UITextView()
        view.backgroundColor = .clear
        view.textColor = Const.placeholderColor
        view.isUserInteractionEnabled = false
        view.isAccessibilityElement = false
        return view
    }()
    
    init() {
        super.init(frame: .zero, textContainer: nil)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
    
    // MARK: Property
    var placeholderText: String? {
        didSet {
            placeholderTextView.text = placeholderText
            updatePlaceholderTextView()
        }
    }
    
    // MARK: Method
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePlaceholderTextView()
    }
}

// MARK: - Private Method
private extension PlaceholderTextView {
    func setupUI() {
        delegate = self
    
        clipsToBounds = true
        
        textContainerInset = Const.containerInset
        contentInset = .zero
        
        addSubview(placeholderTextView)
        
        placeholderTextView.textContainerInset = Const.containerInset
        placeholderTextView.contentInset = contentInset
    }
    
    func updatePlaceholderTextView() {
        
        placeholderTextView.isHidden = !text.isEmpty
        
        placeholderTextView.textContainer.exclusionPaths = textContainer.exclusionPaths
        
        placeholderTextView.textContainer.lineFragmentPadding = textContainer.lineFragmentPadding
        
        placeholderTextView.frame = bounds
    }
}

// MARK: - PlaceholderTextView + UITextViewDelegate
extension PlaceholderTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderTextView()
    }
}

