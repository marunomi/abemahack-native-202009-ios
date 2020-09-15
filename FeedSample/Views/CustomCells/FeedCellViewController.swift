import AVKit
import UIKit
import RxSwift
import RxCocoa
import RxGesture

final class FeedCellViewController: UIViewController {

    private(set) var channel: Channel?
    private(set) var page: Int?

    private let disposeBag = DisposeBag()
    private var viewModel = FeedCellViewModel()

    @IBOutlet private weak var playerContainerView: UIView!

    private let playerViewController: AVPlayerViewController = {
        let playerVC = AVPlayerViewController()
        playerVC.showsPlaybackControls = false
        playerVC.videoGravity = .resizeAspectFill
        playerVC.view.isUserInteractionEnabled = false
        playerVC.view.backgroundColor = .darkGray
        playerVC.view.translatesAutoresizingMaskIntoConstraints = false
        return playerVC
    }()

    ///コメント表示用のテーブルビュー
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        //tableView
        tableView.estimatedRowHeight = 64
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CommentsCell.self, forCellReuseIdentifier: "CommentsCell")
        self.view.addSubview(tableView)

        view.backgroundColor = UIColor(white: 0.1, alpha: 1)

        playerContainerView.addSubview(playerViewController.view)

        NSLayoutConstraint.activate([
            playerViewController.view.topAnchor.constraint(equalTo: playerContainerView.topAnchor),
            playerViewController.view.leadingAnchor.constraint(equalTo: playerContainerView.leadingAnchor),
            playerViewController.view.trailingAnchor.constraint(equalTo: playerContainerView.trailingAnchor),
            playerViewController.view.bottomAnchor.constraint(equalTo: playerContainerView.bottomAnchor),
        ])

        tableView.topAnchor.constraint(equalTo: self.playerContainerView.bottomAnchor).isActive = true
        tableView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        // Tap Gesture

        //        self.playerContainerView.rx
        //            .tapGesture(numberOfTaprequired: 2)
        //            .subscribe(onNext: { _ in
        //
        //            }).dispoded(by: disposeBag)

        //tableView
        viewModel.comments.bind(to: tableView.rx.items(cellIdentifier: "CommentsCell")) { _, element, cell in
            cell.textLabel?.text = element.id + " : " + element.message
        }.disposed(by: disposeBag)

    }

    func play(with player: AVPlayer) {
        guard let channel = channel else {
            assertionFailure("should not reach here")
            return
        }

        guard let url = URL(string: channel.url) else {
            assertionFailure("invalid URL")
            return
        }

        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
        playerViewController.player = player
        player.play()
    }

    func stop() {
        playerViewController.player = nil
    }
}

extension FeedCellViewController {
    static func make(channel: Channel, page: Int) -> Self {
        let viewController = self.init(nibName: String(describing: self), bundle: nil)
        viewController.channel = channel
        viewController.page = page
        return viewController
    }
}
