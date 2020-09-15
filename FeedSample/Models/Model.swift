//
//  Model.swift
//  FeedSample
//
//  Created by 新井まりな on 2020/09/15.
//  Copyright © 2020 AbemaTV, Inc. All rights reserved.
//

import RxSwift

protocol ModelProtocol {
    func loadComment(at: Int) -> Observable<Comment>

}

final class Model: ModelProtocol {

    let apiSession = MockApiSession()

    init() {
        //一応．．
    }

    func loadComment(at: Int) -> Observable<Comment> {
        let comments = apiSession.fetchComments()
        let comment = comments[at]

        return Observable.create { observer in
            observer.onNext(comment)
            observer.onCompleted()
            return Disposables.create()
        }
    }

}
