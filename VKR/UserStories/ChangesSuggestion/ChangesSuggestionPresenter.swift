//
//  ChangesSuggestionPresenter.swift
//  VKR
//
//  Created by Руслан on 06.01.2024.
//

import Foundation

protocol IChangesSuggestionPresenter: AnyObject {
    var changesDescription: AttributedString { get }
    var fileChangesModels: [FileChangesModel] { get }
}

final class ChangesSuggestionPresenter: IChangesSuggestionPresenter {

    let changesDescription = try! AttributedString(markdown: "Класс **Class1** неявно ссылается на класс **Class2**, создавая его экземпляр внутри метода **method1**. Исправление заключается в использовании хранимого свойства __class1__, значение для которого передается через инициализатор.")

    private let leftDataSource: [LineModel] = [
        LineModel(text: "import Cocoa", status: .removed),
        LineModel(text: "", status: .empty),
        LineModel(text: "", status: .unchanged),
        LineModel(text: "class ViewController: NSViewController {", status: .removed),
        LineModel(text: "", status: .unchanged),
        LineModel(text: "    override func viewDidLoad() {", status: .unchanged),
        LineModel(text: "", status: .empty),
        LineModel(text: "        super.viewDidLoad()", status: .unchanged),
        LineModel(text: "", status: .removed),
        LineModel(text: "        // Do any additional setup after loading the view.", status: .removed),
        LineModel(text: "    }", status: .unchanged),
        LineModel(text: "", status: .unchanged),
        LineModel(text: "    override var representedObject: Any? {", status: .removed),
        LineModel(text: "        didSet {", status: .removed),
        LineModel(text: "        // Update the view, if already loaded.", status: .removed),
        LineModel(text: "        }", status: .removed),
        LineModel(text: "", status: .empty),
        LineModel(text: "    }", status: .unchanged),
        LineModel(text: "}", status: .unchanged),
    ]
    //            .split(separator: "\n", omittingEmptySubsequences: false).map { String($0) }

    private let rightDataSource: [LineModel] = [
        LineModel(text: "import AppKit", status: .added),
        LineModel(text: "import IGListDiffKit", status: .added),
        LineModel(text: "", status: .unchanged),
        LineModel(text: "final class ViewController: NSViewController {", status: .added),
        LineModel(text: "", status: .unchanged),
        LineModel(text: "    override func viewDidLoad() {", status: .unchanged),
        LineModel(text: "        print(\"viewDidLoad\")", status: .added),
        LineModel(text: "        super.viewDidLoad()", status: .unchanged),
        LineModel(text: "", status: .empty),
        LineModel(text: "", status: .empty),
        LineModel(text: "    }", status: .unchanged),
        LineModel(text: "", status: .unchanged),
        LineModel(text: "    override func loadView() {", status: .added),
        LineModel(text: "        view = NSView(frame: NSRect(x: 0, y: 0, width: 480, height: 270))", status: .added),
        LineModel(text: "        let anotherView = NSView(frame: NSRect(x: 0, y: 0, width: 480, height: 270))", status: .added),
        LineModel(text: "        anotherView.wantsLayer = true", status: .added),
        LineModel(text: "        anotherView.layer?.backgroundColor = NSColor.red.cgColor", status: .added),
        LineModel(text: "    }", status: .unchanged),
        LineModel(text: "}", status: .unchanged),
    ]

    lazy var fileChangesModels: [FileChangesModel] = [
        FileChangesModel(fileName: "SomeFolder/SomeFile.swift", leftLines: leftDataSource, rightLines: rightDataSource),
        FileChangesModel(fileName: "SomeFolder/SomeAnotherFile.swift", leftLines: leftDataSource, rightLines: rightDataSource)
    ]
}
