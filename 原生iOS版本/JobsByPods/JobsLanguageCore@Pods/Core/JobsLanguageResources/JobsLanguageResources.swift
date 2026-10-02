//
//  JobsLanguageResources.swift
//  JobsLanguageCore
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import Foundation

public enum JobsLanguageResources {

    public static func bundle(_ name: String, owner: AnyClass) throws -> Bundle {
        let parents = [Bundle.make(learningOwner: owner), Bundle.main]
        for parent in parents {
            if let url = parent.url(forResource: name, withExtension: "bundle"),
                let bundle = Bundle.make(learningURL: url)
            {
                return bundle
            }
        }
        throw JobsLanguageError.message("资源包缺失：\(name)")
    }

    public static func file(_ name: String, extension ext: String, bundle: Bundle) throws -> URL {
        guard let url = bundle.url(forResource: name, withExtension: ext) else {
            throw JobsLanguageError.message("离线文件缺失：\(name).\(ext)")
        }
        return url
    }
}
