//
//  JobsKanjiTranslationHost.swift
//  JobsLanguageLearning
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import UIKit
import JobsKanjiLearning
import SwiftUI

final class JobsKanjiTranslationHost: UIHostingController<JobsKanjiTranslationView> {

    static func make(translator: JobsKanjiChineseTranslator) -> JobsKanjiTranslationHost {
        JobsKanjiTranslationHost(rootView: JobsKanjiTranslationView(translator: translator))
    }
}

extension UIViewController {

    @discardableResult func byKanjiTranslationHost(_ child: UIViewController) -> Self {
        addChild(child)
        child.didMove(toParent: self)
        return self
    }
}
