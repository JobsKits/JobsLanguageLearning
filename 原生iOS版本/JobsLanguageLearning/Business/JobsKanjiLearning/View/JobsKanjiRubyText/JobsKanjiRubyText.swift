//
//  JobsKanjiRubyText.swift
//  JobsLanguageLearning
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import UIKit
import CoreText
import JobsByUIKit
import JobsSwiftDSL
import JobsSwiftBaseDefines
import JobsLanguageCore
import JobsKanjiLearning

final class JobsKanjiRubyText: UITextView {
    private var tokens: [[String]] = []
    var onRead: ((String) -> Void)?

    @discardableResult func byOnRead(_ value: @escaping (String) -> Void) -> Self {
        onRead = value
        return self
    }
    private lazy var proxy = Delegate(owner: self)

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        byEditable(false)
            .bySelectable(true)
            .byScrollEnabled(false)
            .byBackgroundColor(JobsCor.clear)
        byDelegate(proxy)
            .byTextContainerInset(UIEdgeInsets(top: 12, left: 0, bottom: 8, right: 0))
            .byLearningObserveAppearance { [weak self] in
                self?.render()
            }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @discardableResult func byTokens(_ value: [[String]]) -> Self {
        tokens = value
        render()
        return self
    }

    private func render() {
        let result = NSMutableAttributedString.make(learningText: "")
        for (index, token) in tokens.enumerated() where !token.isEmpty {
            var attributes: [NSAttributedString.Key: Any] = [
                .font: JobsFont.systemFont(ofSize: 22), .foregroundColor: JobsCor.label
            ]
            if token.count > 1, !token[1].isEmpty {
                let annotation = Self.ruby(token[1])
                attributes[NSAttributedString.Key(kCTRubyAnnotationAttributeName as String)] = annotation
            }
            attributes[.link] = URL(string: "jobs-ruby://read/\(index)")
            result.byAdd(NSAttributedString.make(learningText: token[0], learningAttributes: attributes))
        }
        byAttributedText(result)
        byLinkTextAttributes([.foregroundColor: JobsCor.label])
    }

    private static func ruby(_ reading: String) -> CTRubyAnnotation {
        let attributes =
            [kCTRubyAnnotationSizeFactorAttributeName: 0.5, kCTForegroundColorAttributeName: JobsCor.systemRed.cgColor]
            as CFDictionary
        return CTRubyAnnotationCreateWithAttributes(.auto, .auto, .before, reading as CFString, attributes)
    }
    private final class Delegate: NSObject, UITextViewDelegate {
        weak var owner: JobsKanjiRubyText?
        init(owner: JobsKanjiRubyText) {
            self.owner = owner
        }
        func textView(_ textView: UITextView, primaryActionFor textItem: UITextItem, defaultAction: UIAction)
            -> UIAction?
        {
            guard case .link(let url) = textItem.content else {
                return nil
            }
            return UIAction.make(title: "点读") { [weak self] _ in
                guard let owner = self?.owner, let index = Int(url.lastPathComponent),
                    owner.tokens.indices.contains(index)
                else {
                    return
                }
                let token = owner.tokens[index]
                owner.onRead?(token.count > 1 && !token[1].isEmpty ? token[1] : token[0])
            }
        }
    }
}
