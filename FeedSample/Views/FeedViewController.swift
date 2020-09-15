import AVKit
import UIKit
import RxSwift
import RxCocoa
import RxGesture

class FeedViewController: UIPageViewController {

    /// 動画再生用のプレイヤー
    /// - NOTE: 多重再生を防ぐためにViewController単位で単一のプレイヤーを使う
    private let player = AVPlayer()

    ///コメント表示用のテーブルビュー
    private let tableView = UITableView()

    /// 現在表示中のページ
    private var currentPage: Int?

    /// チャンネル一覧
    private lazy var channels = {
        return MockApiSession.shared.fetchChannels()
    }()

    private lazy var viewModel = FeedViewModel(player: player)

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 64
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.register(CommentsCell.self, forCellReuseIdentifier: "CommentsCell")

        self.view.addSubview(tableView)

        player.isMuted = true
        dataSource = self
        delegate = self

        view.backgroundColor = UIColor(white: 0.1, alpha: 1)

        let initialViewController = viewController(for: 0)
        setViewControllers([initialViewController], direction: .forward, animated: false, completion: nil)
        pageWillChange(newPage: 0, viewController: initialViewController, previousViewControllers: [])

        //constraints
        tableView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        tableView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        tableView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.5).isActive = true

        //Binding

        NotificationCenter.default.rx.notification(.AVPlayerItemDidPlayToEndTime)
            .subscribe(onNext: { [weak self] _ in
                self?.player.seek(to: .zero)
                self?.player.play()
            }).disposed(by: disposeBag)

        //tableView
        viewModel.comments.bind(to: tableView.rx.items(cellIdentifier: "CommentsCell")) { _, element, cell in
            cell.textLabel?.text = element.id + " : " + element.message
        }.disposed(by: disposeBag)

    }
}

extension FeedViewController {
    /// 各ページ用のViewControllerを生成する
    private func viewController(for page: Int) -> FeedCellViewController {
        FeedCellViewController.make(channel: channels[page], page: page)
    }

    /// `page` から `delta` 移動し、チャンネルの数でローテーションしたページ番号を返す
    private func rotatedPage(_ page: Int, delta: Int) -> Int {
        var newPage = page + delta
        if newPage < channels.startIndex {
            newPage += channels.count
        } else if newPage >= channels.endIndex {
            newPage -= channels.count
        }
        return newPage
    }

    /// 新しいページに遷移する際に呼び出す
    private func pageWillChange(
        newPage: Int,
        viewController: FeedCellViewController,
        previousViewControllers: [UIViewController]
    ) {
        guard currentPage != newPage else {
            // ページが変わっていなければそのまま
            return
        }
        currentPage = newPage

        // 移動元のページの再生を停止する
        for case let previousViewController as FeedCellViewController in previousViewControllers
            where previousViewController.page != newPage {
                previousViewController.stop()
        }

        // 移動先のページの再生を開始する
        viewController.play(with: player)
    }
}

extension FeedViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let currentPage = (viewController as? FeedCellViewController)?.page else {
            assertionFailure("should never reach here")
            return UIViewController()
        }

        let newPage = rotatedPage(currentPage, delta: -1)
        return self.viewController(for: newPage)
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let currentPage = (viewController as? FeedCellViewController)?.page else {
            assertionFailure("should never reach here")
            return UIViewController()
        }

        let newPage = rotatedPage(currentPage, delta: 1)
        return self.viewController(for: newPage)
    }
}

extension FeedViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        for viewController in pendingViewControllers {
            viewController.view.setNeedsLayout()
        }
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard
            let viewController = pageViewController.viewControllers?.first as? FeedCellViewController,
            let newPage = viewController.page
            else {
                assertionFailure("should never reach here")
                return
        }

        pageWillChange(newPage: newPage, viewController: viewController, previousViewControllers: previousViewControllers)
    }
}
