//
//  DocumentHelpers.swift
//  DocumentsInDocuments
//
//  Created by Chad Etzel on 9/21/21.
//

import Foundation

fileprivate extension String {
    static let dataKey: String = "Data"
}

class DocumentHelper {

    // ENCODE
    public class func encodeEncodableToWrapper<T>(obj: T) -> FileWrapper? where T: Encodable{
        let archiver = NSKeyedArchiver(requiringSecureCoding: true)
        do {
            try archiver.encodeEncodable(obj, forKey: .dataKey)
            archiver.finishEncoding()
            let data = archiver.encodedData
            return FileWrapper(regularFileWithContents: data)
        } catch {
            print("error encoding Encodable: ", (error as NSError))
            return nil
        }

    }

    // DECODE
    public class func decodeDecodableFromWrapper<T>(type: T.Type, for name: String, in fileWrapper: FileWrapper?) -> T? where T : Decodable {
        guard let allWrappers = fileWrapper,
              let wrapper = allWrappers.fileWrappers?[name],
              let data = wrapper.regularFileContents else { return nil }

        do {
            let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: data)
            let obj = unarchiver.decodeDecodable(T.self, forKey: .dataKey)
            return obj
        } catch {
            print("error decoding Decodable: ", (error as NSError))
            return nil
        }

    }

}
