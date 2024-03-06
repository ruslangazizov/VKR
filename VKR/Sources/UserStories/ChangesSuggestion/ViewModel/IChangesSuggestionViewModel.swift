//
//  IChangesSuggestionViewModel.swift
//  VKR
//
//  Created by r.a.gazizov on 05.03.2024.
//

import Foundation

protocol IChangesSuggestionViewModel: ObservableObject {
    var model: ChangesSuggestionModel? { get }
    func viewDidAppear()
    func didTapDiscardButton()
    func didTapAcceptButton()
}
