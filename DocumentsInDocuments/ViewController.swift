//
//  ViewController.swift
//  DocumentsInDocuments
//
//  Created by Chad Etzel on 9/23/21.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func _didTapExportBook(_ sender: Any) {

        // we give the chapters empty fileURLs because they aren't being saved individually,
        // so the fileURL will never be read

        let chapter1 = ChapterDocument(fileURL: URL(fileURLWithPath: ""))
        chapter1.title = "Chapter ONE"
        chapter1.body = "This is the first chapter."

        let chapter2 = ChapterDocument(fileURL: URL(fileURLWithPath: ""))
        chapter2.title = "Chapter TWO"
        chapter2.body = "Now we move one to the second chapter"

        let chapter3 = ChapterDocument(fileURL: URL(fileURLWithPath: ""))
        chapter3.title = "Chapter THREE"
        chapter3.body = "The third chapter presents even more story"

        let chapter4 = ChapterDocument(fileURL: URL(fileURLWithPath: ""))
        chapter4.title = "Chapter FOUR"
        chapter4.body = "Here we present the twist ending!"


        // we create a temporary URL for the book to live at for exporting
        let tempURL = FileManager.default.temporaryDirectory
        let bookFilename = "book-\(Int64(floor(Date().timeIntervalSince1970)))"
        let bookDocumentURL = tempURL.appendingPathComponent(bookFilename).appendingPathExtension(.bookFileExtension)
        print("bookDocumentURL: \(bookDocumentURL)")

        let book = BookDocument(fileURL: bookDocumentURL)
        book.title = "A Very Good Book"
        book.author = "Anne Arthur"
        book.chapterDocuments = [chapter1, chapter2, chapter3, chapter4]

        book.save(to: book.fileURL, for: .forCreating) { saveSuccess in
            print("save success: \(saveSuccess)")

            // export it with activity view controller
            let activityItem = book.fileURL
            let activityVC = UIActivityViewController(activityItems: [activityItem], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
//            activityVC.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
//            }
            self.present(activityVC, animated: true, completion: nil)
        }

    }


    @IBAction func _didTapImportbook(_ sender: Any) {

        let alert = UIAlertController(title: "Hello", message: "Look at the console output for the book contents", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert,animated: true)

        let exampleBookURL = Bundle.main.bundleURL.appendingPathComponent("ExampleBook").appendingPathExtension(.bookFileExtension)

        let bookDoc = BookDocument(fileURL: exampleBookURL)

        bookDoc.open { success in
            print("book file open success: \(success)")

            if (success) {
                print("BOOK TITLE: \(bookDoc.title ?? "no title")")
                print("BOOK AUTHOR: \(bookDoc.author ?? "no author")")
                print("CHAPTERS:")

                if let chapterDocuments = bookDoc.chapterDocuments {
                    for chapterDoc in chapterDocuments {
                        print("----");
                        print(chapterDoc.title ?? "no chapter title")
                        print(chapterDoc.body ?? " no chapter body")
                    }
                }

            }
        }
    }
    
}

