//
//  FeedCellModel.swift
//  FeedSample
//
//  Created by 新井まりな on 2020/09/15.
//  Copyright © 2020 AbemaTV, Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AVKit

final class FeedCellViewModel {
    private let model: ModelProtocol
    private let disposeBag = DisposeBag()

    private var index: Int = 0

    var comments: Observable<[Comment]>
    private let _comments = BehaviorRelay<[Comment]>(value: [])

    init(model: ModelProtocol = Model()) {
        self.model = model
        comments = _comments.asObservable()
    }

    func viewDidLoad(_ cnt: Int) {

        model.loadComment(at: cnt)
            .subscribe(onNext: { [weak self] in
                guard let me = self else { return }

                //index番目のcommentを，配列に追加したい
                let comments = me._comments.value
                self?._comments.accept([$0] + comments)
            }).disposed(by: disposeBag)

    }

    //カウントアップよう分からんかっったな
    func startCommentReplay() -> Observable<Void> {
        var timer = Timer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
            if self.index >= 50 {
                self.index = 0
            }
            self.index += 1
        })
        return Observable.create { observer in
            observer.onCompleted()
            return Disposables.create()
        }
    }
}
