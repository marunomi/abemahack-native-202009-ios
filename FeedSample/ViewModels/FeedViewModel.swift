//
//  FeedViewModel.swift
//  FeedSample
//
//  Created by 新井まりな on 2020/09/14.
//  Copyright © 2020 AbemaTV, Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AVKit

final class FeedViewModel {
    private let model: ModelProtocol
    private let disposeBag = DisposeBag()

    var comments: Observable<[Comment]>

    init(player: AVPlayer,
         model: ModelProtocol = Model()) {
        self.model = model
        comments = model.loadComment()
    }
}
