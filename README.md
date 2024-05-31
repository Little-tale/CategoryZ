<img src="https://github.com/Little-tale/CategoryZ/assets/116441522/080ef485-879b-4ecb-b377-fe8dceeb3e11" width="100" height="100"/>

# CategoryZ ReadMe

- CategoryZ app은 LSLP ( **Service Location Protocol ) 프로젝트 입니다.**

> **당신의 일상과 특별한 순간! 그외 에도** 다양한 경험을 카테고리 Z 로 공유해 보세요!
> 당신의 이야기로 다른 사람들과 소통할수 있는 앱입니다.

# 소개 사진

<picture>
    <img src ="https://github.com/Little-tale/NaverShopping/assets/116441522/0ad703d1-bd6c-4283-b9f8-5700f9a45bdc">
</picture>
# 📷 CategoryZ 프로젝트 소개

> 다양한 이미지와 글을을 올려 다른 사람과 소통할수 있는 SNS 앱 LSLP 프로젝트 앱입니다.

- CategoryZ는 서버를 기반으로 이미지와 글을 공유하고 소통할수있습니다.
- 다른 유저에게 후원할수 있습니다. (설정에서 등록시)
- 카테고리 별로 올릴수 있으며 보고싶은 카테고리만 골라 볼수 있습니다.
- 다른 유저를 팔로우 할수 있습니다!
- 좋아요를 남겨 모아 볼수 있습니다.
- 네트워크 상태를 실시간으로 감지하여, 사용자에게 네트워크 상태를 알려줍니다.
- 실시간 1:1 채팅 기능

## 📸 개발기간

> 4/13 ~ 5/3 + 5/20 ~ 5/22(채팅 기능 추가) ( 대략 3주 )

# 📷 사용한 기술들

- UIKit / RxSwift / RxCocoa
- MVVM / Facade / Router / SingleTone /
- Alamofire / Kingfisher/ SocketIO / Decodable / Encodable
- CodeBaseUI / SnapKit / Then / CompositionalLayout / RxDataSource / ReusableKit
- IQKeyboard / Toast / Lottie / TextFieldEffects / Lottie / KeychainAccess
- 다크모드 대응 Asset

# 📷 기술설명

## MVVM + RxSwift

> RxSwift를 이용하여 MVVM Input-output패턴을 통해
> 비즈니스 로직을 분리하여 재사용성을 높였습니다.

```swift
import RxSwift

protocol ViewModelType {

    associatedtype Input

    associatedtype Output

    func transform(_ input: Input) -> Output
}

protocol RxViewModelType: ViewModelType {

    var disposeBag: DisposeBag { get set }
}
```

## Alamofire + RouterPattern + RequestInterceptor

> Alamofire 를 통해 각 서비스별 라우터를 분리하여 구조화 하였습니다.
> 또한 각 API 는 토큰키와 리프레시 토큰키가 필요 하였기에 RequestInterceptor 를 구현하여
> 토큰키 만료시 리프레시 토큰키를 통해 토큰키를 갱신 하였습니다.

```swift
struct NetworkManager {
    // 서버로부터 데이터 받을시 + 보낼시 통합
    typealias FetchType<T:Decodable> = Single<Result<T, NetworkError>>
    // 받아올 모델은 없을시
    typealias NoneModelFetchType = Single<Result<Void,NetworkError>>
}

protocol ErrorCase {
    func errorCase(_ errorCode: Int,_ description: String) -> NetworkError
}

enum NetworkRouter {
    case authentication(authenticationRouter)
    case poster(PostsRouter)
    case comments(CommentRouter)
    case like(LikeRouter)
    case follow(FollowRouter)
    case profile(ProfileRouter)
    case payments(PaymentsRouter)
}
// 각각의 라우터들은 해당 프로토코콜을 채택 해야 합니다.
protocol TargetType: URLRequestConvertible {

    var method: HTTPMethod { get }

    var path: String { get }

    var parametters: Parameters? { get }

    var headers: [String: String] { get }

    var queryItems: [URLQueryItem]? { get }

    var version: String { get }

    var body: Data? { get }

    var multipart: MultipartFormData { get }

    func errorCase(_ errorCode: Int, _ description: String) -> NetworkError
}

```

## SocketIO + Chatting

> SocketIO 를 통해
> 실시간으로 채팅을 주고받을수 있도록 양방향 통신인 Socket통신(TCP)을 구현하였습니다, 다만 TCP 연결을 유지하면
> 사용자의 배터리를 많이 소모할수 있음으로 적절한 타이밍에 소켓을 끊을수 있도록 하였습니다.

```swift
final class ChatSocketManager {

    typealias ChatSocketManagerResult = PublishSubject<Result<ChatModel,ChatSocketManagerError>>

    static let shared = ChatSocketManager()

    private var manager: SocketManager?

    private var socket: SocketIOClient?

    private let decodable = JSONDecoder()

    /// 해당 프로퍼티를 통해 채팅 정보를 받습니다.
    let chatSocketResult = ChatSocketManagerResult ()

    private init() {
        setupManager()
    }
}

// 클라이언트
extension ChatSocketManager {

    func setID(id: String) {
        removeSocket()
        let roomId = SocketCase.Chat.rawValue + id
        socket = manager?.socket(forNamespace: roomId)
        guard let socket else {
            chatSocketResult.onNext(.failure(.nilSocat))
            return
        }
        startObserver(socket: socket)
    }

    func startSocket()
    func stopSocket()
    func removeSocket()
}

// SceneDelegate
func sceneWillEnterForeground(_ scene: UIScene) {
    ChatSocketManager.shared.startSocket()
}

func sceneDidEnterBackground(_ scene: UIScene) {
    ChatSocketManager.shared.stopSocket()
}
```

# UI

|                                                               메인화면                                                               |                                                               글올리기                                                               |                                                                프로필                                                                |                                                               결제기능                                                               |
| :----------------------------------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------------------------: |
| <img src="https://github.com/Little-tale/CategoryZ/assets/116441522/9b27d1e4-11f5-4c25-b6dd-820518c95b5e" width="200" height="400"/> | <img src="https://github.com/Little-tale/CategoryZ/assets/116441522/989300aa-b995-4d3f-9851-240530c5e416" width="200" height="400"/> | <img src="https://github.com/Little-tale/CategoryZ/assets/116441522/ac76a845-f4f1-4359-9c95-912ea3400987" width="200" height="400"/> | <img src="https://github.com/Little-tale/CategoryZ/assets/116441522/5a7480d2-8c45-4b49-9a81-08e30a8e04c2" width="200" height="400"/> |

|                                                                        태그 검색                                                                        |                                                                       글 수정하기                                                                       |                                                                         좋아요 모아보기                                                                          |                                                                 팔로잉/ 팔로우                                                                 |
| :-----------------------------------------------------------------------------------------------------------------------------------------------------: | :-----------------------------------------------------------------------------------------------------------------------------------------------------: | :--------------------------------------------------------------------------------------------------------------------------------------------------------------: | :--------------------------------------------------------------------------------------------------------------------------------------------: |
| <picture><img src="https://github.com/Little-tale/CategoryZ/assets/116441522/e2a5d74e-82da-491f-bd03-57d0539a41d7" width="200" height="400"/></picture> | <picture><img src="https://github.com/Little-tale/CategoryZ/assets/116441522/7145c086-da52-47d7-9bc5-51cbd85d399f" width="200" height="400"/></picture> | <picture><img src="https://github.com/Little-tale/CategoryZ/assets/116441522/936ac279-8153-4e20-a111-5c9815083854" width="200" height="400"/></picture><picture> | <img src="https://github.com/Little-tale/CategoryZ/assets/116441522/298628dd-c6d8-4548-b7eb-a9fa826941f8" width="200" height="400"/></picture> |

|                                                                          댓글                                                                           |                                                                         글 삭제                                                                         |                                                                        설정화면                                                                         |
| :-----------------------------------------------------------------------------------------------------------------------------------------------------: | :-----------------------------------------------------------------------------------------------------------------------------------------------------: | :-----------------------------------------------------------------------------------------------------------------------------------------------------: |
| <picture><img src="https://github.com/Little-tale/CategoryZ/assets/116441522/5c621a72-2c8f-42fc-9c99-6ac1e29d9346" width="200" height="400"/></picture> | <picture><img src="https://github.com/Little-tale/CategoryZ/assets/116441522/5eafc8b3-2518-4903-84b7-7f7a0686423b" width="200" height="400"/></picture> | <picture><img src="https://github.com/Little-tale/CategoryZ/assets/116441522/685880d4-a3b9-47ca-9a14-47844b98853e" width="200" height="400"/></picture> |

|                                                                          채팅                                                                           |                                                                          이미지                                                                          |
| :-----------------------------------------------------------------------------------------------------------------------------------------------------: | :------------------------------------------------------------------------------------------------------------------------------------------------------: |
| <picture><img src="https://github.com/Little-tale/CategoryZ/assets/116441522/f1b73d17-2830-497b-a9e5-5a45f448db73" width="400" height="400"/></picture> | <pickture><img src="https://github.com/Little-tale/CategoryZ/assets/116441522/39d77a27-d191-49eb-b5b7-61482ae1c2d0" width="200" height="400"/></picture> |

# 새롭게 학습 한 부분 과 고려했던 사항

## 메모리 누수 (instruments Check)

<picture>
<img src="https://github.com/Little-tale/CategoryZ/assets/116441522/07c4188c-2874-450f-8ced-d40ab7df75d4">
</picture>
> 
SNS 앱이기 때문에 다양한 이미지들을 캐시하게 됩니다.
같은 URL일 경우, 재요청하는 것이 아니라 원래 캐시된 이미지를 사용하므로 
메모리 누수를 체크하면서 이미지 관리에 신경을 썼습니다.
>

```swift
func downloadImage(imageUrl: String?, resizing: CGSize, complite: @escaping (Result<Data?,NetworkError>)-> Void ) {

        let processor = DownsamplingImageProcessor(size: resizing)
        var scale: CGFloat = 0

        if let screenCurrent = UIScreen.current?.scale {

            scale = screenCurrent
        } else {
            scale = UIScreen.main.scale
        }

        guard let imageUrl else {
            complite(.failure(.failMakeURLRequest))
            return
        }

        KingfisherManager.shared.retrieveImage(with: URL(string: imageUrl)!, options: [
            .processor(processor),
            .transition(.fade(1)),
            .requestModifier(KingFisherNet()),
            .scaleFactor(scale),
            .cacheOriginalImage
        ]) { imageResult in
            switch imageResult {
            case .success(let result):
                complite(.success(result.data()))
            case .failure(_):
                complite(.failure(.failMakeURLRequest))
                break
            }
        }
    }
```

> 회고 록: 다운샘플링

[이미지 압축 어떻게 하는거죠?](https://velog.io/@little_tail/이미지-압축-어떻게-하는거죠)

## 핀터레스트 UI

> 사용자가 올린 이미지의 비율을 그대로 유지하면서
> 레이아웃의 공간을 활용하고 사용자의 앱 경험을 높이기 위해
> 핀터레스트 UI를 구성하였습니다.

```swift
// 레이아웃을 구성하는데에 필요한 데이터를 계산하는 클래스 입니다.
final class LayoutBuilder {

    /// 각 열의 너비를 계산하는 계산 속성
    var columnWidth: CGFloat { get set }

    /// 특정 아이템의 프레임을 계산
    func frame(for row: Int) -> CGRect

    /// 행 레이아웃 아이템 생성
    func makeLayoutItem(for row: Int)

    /// 가장 낮은 열의 인덱스를 반환
    func columnIndex() -> Int

    // item x,y 좌표가 어딘지 계산해
    func itemOrigin(width: CGFloat) -> CGPoint

    // 모든 열중 가장 높은 높이를 반환
    func maxcolumHeight() -> CGFloat
}

/// 핀터레스트 레이아웃 구성에 필요한 세부사항들을 정의하는 구조체입니다.
struct PinterestConfiguration {
    let numberOfColumns: Int
    let interItemSpacing: CGFloat /
    let edgeInset: NSDirectionalEdgeInsets
    let itemHeightProvider: (_ index: Int,_ itemWidth: CGFloat) -> CGFloat // 특정 인뎃스 아이템 높이 클로저
    let itemCountProfider: () -> Int
}

final class PinterestcompositionalLayout {

    static func makeLayoutSection(
        config: PinterestConfiguration,
        environment: NSCollectionLayoutEnvironment,
        sectionIndex: Int
    ) -> NSCollectionLayoutSection

}

```

### 회고

> [PinterestLayout2탄! (Compositional)](https://velog.io/@little_tail/PinterestLayout2탄-Compositional)

> [😩 길고도 험했던 핀터레스트 UI 또는 Masonry](https://velog.io/@little_tail/길고도-험했던-핀터레스트-UI-또는-Masonry)

---

## 트러블 슈팅

### 정규 표현식

> 댓글 기능은 많은 앱들이 사용자가 글을 쓰는 도중 의도치 않게 엔터 키를 누를 수 있으므로 줄바꿈을 제한하는 것이 일반적인 방법이라는 것을 알았습니다. 정규 표현식 을 통해 줄바꿈을 막으려고 하였으나 통과가 되버리는 문제가 발생 하였었습니다. `영어` 일때는 문제가 없었으나
> `한글` 일떄는 입력 중 조합이 완성되지 않은 상태에서 `\n`가 통과가 되버리는 것을 깨닫고 직접 `\n` 방지해 문제를 해결하였습니다.

```swift
func commentValid(_ string: String, maxCount: Int) -> Bool {
    guard !string.isEmpty else {
        return false
    }
    let pattern = "^[^\n]{1,\(maxCount)}$"
    if string.contains("\n") {
        return false
    } else {
        return matchesPatternBool(string, pattern: pattern)
    }
}
```

[https://velog.io/@little_tail/정규표현식-오류....-아니-전-분명히-막았어요](https://velog.io/@little_tail/%EC%A0%95%EA%B7%9C%ED%91%9C%ED%98%84%EC%8B%9D-%EC%98%A4%EB%A5%98....-%EC%95%84%EB%8B%88-%EC%A0%84-%EB%B6%84%EB%AA%85%ED%9E%88-%EB%A7%89%EC%95%98%EC%96%B4%EC%9A%94)

### 좋아요 누르면 재 로드 되는 이슈

> 사용자가 좋아요 버튼을 클릭하면, 해당 셀의 데이터가 업데이트 되면서,
> 전체 테이블 뷰가 다시 로드되어 사용자가 보고있음에도 이미지 스크롤 뷰가
> 초기 위치로 리셋되는 문제가 발생했습니다.

[RxSwift 좋아요 버튼 이슈...!](https://velog.io/@little_tail/agwewmri)

### navigationcontroller.hidesbarsonswipe 이슈

> 사진 중심의 SNS앱이기에 화면을 최대한 채워 보여주는 것이
> 사용자 경험(UX)적으로 바람직하다고 생각했습니다.

```swift
 override func configureLayout() {

    emptyView.snp.makeConstraints { make in
        make.top.horizontalEdges.equalToSuperview()
        make.bottom.equalTo(safeAreaLayoutGuide.snptop)
    }

    tableView.snp.makeConstraints { make in
        make.horizontalEdges.bottom.equalTo(safeAreaLayoutGuide)
            make.top.equalToSuperview()
    }

    tableView.rowHeight = UITableView.automaticDimension

    tableView.estimatedRowHeight = 240

}

/// ViewController
   override func viewDidLoad() {
        super.viewDidLoad()
        homeView.tableView.tableHeaderView = homeView.headerView
        navigationController?.hidesBarsOnSwipe = true
    }

```

> `NavigationBar` 를 숨겨 사용자가 더 많은 컨텐츠를 볼수 있게 하려
> 하였었지만, navigationController?.hidesBarsOnSwipe = true 를 통해 네비게이션을 숨기려 하였으나, `SafeLayoutGuide 이슈` 가 발생하여, 네비게이션바가 사라진후 다시 나타나지 않는 이슈가 발생 하였었습니다. layout을 SuperView로 하게하여 EmptyView 를 구성해 자연스럽게 작동하도록 직접 구성하였습니다.
>
> [navigationcontroller.hidesbarsonswipe 왜 다시 안나오나요](https://velog.io/@little_tail/2jvewizv)

### JSON Encoder : **keyEncodingStrategy 이슈**

> 결제 API를 구성하는데에 있어서,
> JSONEncode를 이용하여
> JSON 데이터로 변환하는 과정중 문제가 발생하였었습니다.

```swift
struct PaymentsModel: Codable {

    let impUID: String
    let postID: String
    let productName: String
    var price: Int

    enum CodingKeys: String, CodingKey {
        case impUID = "imp_uid"
        case postID = "post_id"
        case productName
        case price
    }
    ... 생략 ...
}
'''
encoder.keyEncodingStrategy = .convertToSnakeCase
```

> keyEncodingStrategy 를 convertToSnakeCase로 사용하고 있었으나, 이는 productName을 product_name 로 바뀌게 되는 이슈를 발견하였고, keyEncodingStrategy에 대해 학습하여 useDefaultKeys로 전환해 문제를 해결하였습니다.

> 블로그링크: [encoder.keyEncodingStrategy 이해좀 해보자](https://velog.io/@little_tail/vhzagwdj)
