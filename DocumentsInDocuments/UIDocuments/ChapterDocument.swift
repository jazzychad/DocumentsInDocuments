//
//  ChapterDocument.swift
//  DocumentsInDocuments
//
//  Created by Chad Etzel on 9/23/21.
//

import UIKit

extension String {
    static let chapterFileExtension = "chapterfile"
}

fileprivate extension String {
    static let dataKey: String = "Data"
    static let chapterTitleFilename: String = "title.dat"
    static let chapterBodyFilename: String = "body.dat"
}

class ChapterDocument: UIDocument {

    override var description: String {
        return fileURL.deletingPathExtension().lastPathComponent
    }

    var fileWrapper: FileWrapper? // FileWrapper representing this document

    // CHAPTER TITLE
    lazy var title: String? = {
        guard
            fileWrapper != nil,
            let str = DocumentHelper.decodeDecodableFromWrapper(type: String.self, for: .chapterTitleFilename, in: fileWrapper)
        else {
            return nil
        }

        return str
    }()

    // CHAPTER BODY
    lazy var body: String? = {
        guard
            fileWrapper != nil,
            let str = DocumentHelper.decodeDecodableFromWrapper(type: String.self, for: .chapterBodyFilename, in: fileWrapper)
        else {
            return nil
        }

        return str
    }()

    // creates the main fileWrapper for the document which represents a file directory package
    override func contents(forType typeName: String) throws -> Any {


        let titleWrapper = DocumentHelper.encodeEncodableToWrapper(obj: title)
        let bodyWrapper = DocumentHelper.encodeEncodableToWrapper(obj: body)

        let wrappers: [String: FileWrapper?] = [
            .chapterTitleFilename: titleWrapper,
            .chapterBodyFilename: bodyWrapper,
        ]

        // create array of non-nil wrappers
        let actualWrappers = wrappers.compactMapValues { $0 }

        return FileWrapper(directoryWithFileWrappers: actualWrappers)
    }

    override func load(fromContents contents: Any, ofType typeName: String?) throws {

        guard let contents = contents as? FileWrapper else { return }

        fileWrapper = contents
    }
}
