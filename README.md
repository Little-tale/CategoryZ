
<img src="https://github.com/Little-tale/CategoryZ/assets/116441522/585addef-5680-4001-905b-90c6e86dc260" width="100" height="100"/>


# CategoryZ ReadMe

- CategoryZ app은 LSLP ( **Service Location Protocol ) 프로젝트 입니다.**

> **당신의 일상과 특별한 순간! 그외 에도** 다양한 경험을 카테고리 Z 로 공유해 보세요!
당신의 이야기로 다른 사람들과 소통할수 있는 앱입니다.
> 

# 소개 사진

![readMEEE 001](https://github.com/Little-tale/CategoryZ/assets/116441522/0d303f23-fd43-4b71-a249-abe96801e2ed)

# 📷 CategoryZ 프로젝트 소개

> 다양한 이미지와 글을을 올려 다른 사람과 소통할수 있는 SNS 앱 LSLP 프로젝트 앱입니다.
> 
- CategoryZ는 서버를 기반으로 이미지와 글을 공유하고 소통할수있습니다.
- 다른 유저에게 후원할수 있습니다. (설정에서 등록시)
- 카테고리 별로 올릴수 있으며 보고싶은 카테고리만 골라 볼수 있습니다.
- 다른 유저를 팔로우 할수 있습니다!
- 좋아요를 남겨 모아 볼수 있습니다.
- 네트워크 상태를 실시간으로 감지하여, 사용자에게 네트워크 상태를 알려줍니다.

## 📸 개발기간

> 4/13 ~ 5/3 ( 대략 3주 )
> 

# 📷 사용한 기술들

- UIKit / RxSwift / RxCocoa
- MVVM / Facade / Router / SingleTone /
- Alamofire / Kingfisher / Decodable / Encodable
- CodeBaseUI / SnapKit / Then / CompositionalLayout / RxDataSource / ReusableKit
- IQKeyboard / Toast / Lottie / TextFieldEffects / Lottie / KeychainAccess
- 다크모드 대응 Asset

# 📷 기술설명

## MVVM + RxSwift

> RxSwift를 이용하여 MVVM Input-output패턴을 통해 
비즈니스 로직을 분리하여 재사용성을 높였습니다.
> 

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
또한 각 API 는 토큰키와 리프레시 토큰키가 필요 하였기에  RequestInterceptor 를 구현하여 
토큰키 만료시 리프레시 토큰키를 통해 토큰키를 갱신 하였습니다.
> 

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

# UI

## 메인화면

<img src="https://github.com/Little-tale/CategoryZ/assets/116441522/9b27d1e4-11f5-4c25-b6dd-820518c95b5e" width="200" height="400"/>

## 글올리기

<img src="https://github.com/Little-tale/CategoryZ/assets/116441522/989300aa-b995-4d3f-9851-240530c5e416" width="200" height="400"/>

## 프로필

<img src="https://github.com/Little-tale/CategoryZ/assets/116441522/ac76a845-f4f1-4359-9c95-912ea3400987" width="200" height="400"/>

## 결제기능

<img src="https://github.com/Little-tale/CategoryZ/assets/116441522/5a7480d2-8c45-4b49-9a81-08e30a8e04c2" width="200" height="400"/>

## 태그 검색

<img src="https://github.com/Little-tale/CategoryZ/assets/116441522/e2a5d74e-82da-491f-bd03-57d0539a41d7" width="200" height="400"/>

## 글 수정하기

<img src="https://github.com/Little-tale/CategoryZ/assets/116441522/7145c086-da52-47d7-9bc5-51cbd85d399f" width="200" height="400"/>

## 좋아요 모아보기

<img src="https://github.com/Little-tale/CategoryZ/assets/116441522/936ac279-8153-4e20-a111-5c9815083854" width="200" height="400"/>

## 팔로잉/ 팔로우

<img src="https://github.com/Little-tale/CategoryZ/assets/116441522/298628dd-c6d8-4548-b7eb-a9fa826941f8" width="200" height="400"/>

## 댓글

<img src="https://github.com/Little-tale/CategoryZ/assets/116441522/5c621a72-2c8f-42fc-9c99-6ac1e29d9346" width="200" height="400"/>

## 글 삭제

<img src="https://github.com/Little-tale/CategoryZ/assets/116441522/5eafc8b3-2518-4903-84b7-7f7a0686423b" width="200" height="400"/>

## 설정화면

<img src="https://github.com/Little-tale/CategoryZ/assets/116441522/685880d4-a3b9-47ca-9a14-47844b98853e" width="200" height="400"/>

# 새롭게 학습 한 부분 과 고려했던 사항

### 메모리 누수 (instruments Check)

![%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA_2024-05-05_%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE_5 27 04](https://github.com/Little-tale/CategoryZ/assets/116441522/07c4188c-2874-450f-8ced-d40ab7df75d4)

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
> 

[이미지 압축 어떻게 하는거죠?](https://velog.io/@little_tail/이미지-압축-어떻게-하는거죠)

### 핀터레스트 UI (Masonry) Flow Layout 으로 구성해보기

> 사용자가 올린 이미지의 비율을 그대로 유지하면서 레이아웃의 공간을 활용하기 위해서 구성하게 되었습니다
아래는 그 과정의 대한 내용입니다.
> 

[😩 길고도 험했던 핀터레스트 UI 또는 Masonry](https://velog.io/@little_tail/길고도-험했던-핀터레스트-UI-또는-Masonry)

### 핀터레스트 UI  Compositional Layout 으로 구성해보기

> Flow 레이아웃으로 구성했었지만 compositonal Layout으로도 구성해 보았습니다.
아래는 그과정의 대한 내용입니다.
> 

[PinterestLayout2탄! (Compositional)](https://velog.io/@little_tail/PinterestLayout2탄-Compositional)

---

## 트러블 슈팅

### 정규식 표현식

> 
댓글 기능을 구현하면서 다른 앱들이 어떤 방식으로 작동하는지 살펴 보았었는데, 
많은 앱들이 줄바꿈을 허용하지 않는다는 것을 발견했습니다.
그과정에서 정규식 표현과 관련해 발생했던 이슈입니다.
> 

[https://velog.io/@little_tail/정규표현식-오류....-아니-전-분명히-막았어요](https://velog.io/@little_tail/%EC%A0%95%EA%B7%9C%ED%91%9C%ED%98%84%EC%8B%9D-%EC%98%A4%EB%A5%98....-%EC%95%84%EB%8B%88-%EC%A0%84-%EB%B6%84%EB%AA%85%ED%9E%88-%EB%A7%89%EC%95%98%EC%96%B4%EC%9A%94)

### 좋아요 누르면 재 로드 되는 이슈

>
사용자가 좋아요 버튼을 클릭하면, 해당 셀의 데이터가 업데이트 되면서,
전체 테이블 뷰가 재로드되어 사용자가 보고있음에도 이미지 스크롤 뷰가
초기 위치로 리셋되는 문제가 발생했습니다.
> 

[RxSwift 좋아요 버튼 이슈...!](https://velog.io/@little_tail/agwewmri)

### navigationcontroller.hidesbarsonswipe 이슈

> 
사진 기반의 SNS이기 때문에 화면을 최대한 꽉 채워 보여주는 것이
사용자 경험(UX)적으로 바람직하다고 생각했습니다.
네비게이션바를 숨기는 것이 사용자 경험(UX)적으로 좋겠구나 라는 생각이 들어서
적용 하였었지만, 네비게이션바가 돌아오지 않았던 이슈 입니다.
> 

[navigationcontroller.hidesbarsonswipe 왜 다시 안나오나요](https://velog.io/@little_tail/2jvewizv)

### JSON Encoder : **keyEncodingStrategy 이슈**

> 인코딩 옵션을 제대로 이해하지 못하고 발생한 문제에 대한 회고록입니다
> 

[encoder.keyEncodingStrategy 이해좀 해보자](https://velog.io/@little_tail/vhzagwdj)
