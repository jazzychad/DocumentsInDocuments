//
//  BookDocument.swift
//  DocumentsInDocuments
//
//  Created by Chad Etzel on 9/23/21.
//

import UIKit

extension String {
    static let bookFileExtension = "bookfile"
}

fileprivate extension String {
    static let dataKey: String = "Data"
    static let bookTitleFilename: String = "title.dat"
    static let bookAuthorFilename: String = "author.dat"
    static let bookChapterDocumentsDirectoryName: String = "chapters"
}

class BookDocument: UIDocument {

    override var description: String {
        return fileURL.deletingPathExtension().lastPathComponent
    }

    var fileWrapper: FileWrapper? // FileWrapper representing this document

    // BOOK TITLE
    lazy var title: String? = {
        guard
            fileWrapper != nil,
            let str = DocumentHelper.decodeDecodableFromWrapper(type: String.self, for: .bookTitleFilename, in: fileWrapper)
        else {
            return nil
        }

        return str
    }()

    // AUTHOR TITLE
    lazy var author: String? = {
        guard
            fileWrapper != nil,
            let str = DocumentHelper.decodeDecodableFromWrapper(type: String.self, for: .bookAuthorFilename, in: fileWrapper)
        else {
            return nil
        }

        return str
    }()

    lazy var chapterDocuments: [ChapterDocument]? = {
        guard
            fileWrapper != nil
        else {
            return nil
        }

        var documents: [ChapterDocument] = []
        if let chapterDirWrapper = fileWrapper?.fileWrappers?[.bookChapterDocumentsDirectoryName] { //chapterDirWrapper {
            if let fileWrappers = chapterDirWrapper.fileWrappers {

                // sort documents by filename
                let sortedWrappers = fileWrappers.values.sorted { wrapper1, wrapper2 in
                    return (wrapper1.filename ?? "__") < (wrapper2.filename ?? "__")
                }

                for wrapper in sortedWrappers {
                    // we have to supply a fileURL to the initializer, but we will never call `load` or `open`
                    // and we are assigning the filewrapper directly, so we just supply a dummy value
                    let chapterDoc = ChapterDocument(fileURL: URL(fileURLWithPath: wrapper.filename ?? ""))
                    chapterDoc.fileWrapper = wrapper // assiging .fileWrapper here
                    documents.append(chapterDoc)
                }
            }
        }
        return documents
    }()

    // creates the main fileWrapper for the document which represents a file directory package
    override func contents(forType typeName: String) throws -> Any {

        let titleWrapper = DocumentHelper.encodeEncodableToWrapper(obj: title)
        let authorWrapper = DocumentHelper.encodeEncodableToWrapper(obj: author)

        // other stuff
        let chaptersDirectoryWrapper = FileWrapper(directoryWithFileWrappers: [:])
        if let chapterDocuments = self.chapterDocuments {
            var index: Int = 1 // for creating numbered filenames
            for chapterDoc in chapterDocuments {
                do {
                    if let chapterWrapper: FileWrapper = try chapterDoc.contents(forType: "") as? FileWrapper {
                        chapterWrapper.filename = String(format: "%04d", index) + "." + .chapterFileExtension

                        // .preferredFilename is required to be set or will throw an exception
                        chapterWrapper.preferredFilename = chapterWrapper.filename

                        chaptersDirectoryWrapper.addFileWrapper(chapterWrapper)
                        index += 1;
                    }

                } catch {
                    print("error getting chapterWrapper: ", error as NSError)
                }
            }
        }

        let wrappers: [String: FileWrapper?] = [
            .bookTitleFilename: titleWrapper,
            .bookAuthorFilename: authorWrapper,
            .bookChapterDocumentsDirectoryName: chaptersDirectoryWrapper
        ]

        // create non-nil array of wrappers
        let actualWrappers = wrappers.compactMapValues { $0 }

        return FileWrapper(directoryWithFileWrappers: actualWrappers)
    }


    override func load(fromContents contents: Any, ofType typeName: String?) throws {

        guard let contents = contents as? FileWrapper else { return }

        fileWrapper = contents
    }
}
