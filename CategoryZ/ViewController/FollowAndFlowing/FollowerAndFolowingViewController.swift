//
//  FollowerAndFolowingViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/23/24.
//

import UIKit
import RxSwift
import RxCocoa

/*
 //1. 팔로워 인지 팔로워 인지 구분져야함
 
 //2. 본인 팔로워 인지 팔로우 인지도 구분해야함
 
 // 본인 팔로워 일땐 버튼이 없어져야함
 // 본인 팔로잉 일땐 팔로우취소할지 팔로우 할지
 
 즉 타인이든 본인읻든 프로필 조회를 다시 해와야 간편해짐
 
 // 타인 : 팔로우 인지 팔로잉인지 나와야 하는데 이때 보인 프로필 조회를 또 해야 하나?
 // 팔로잉 도 똑같음
 
 
 
 */

final class FollowerAndFolowingViewController: RxHomeBaseViewController<FollowerAndFollowingView> {
    
    enum FollowType {
        case follower(ProfileType)
        case following(ProfileType)
    }
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func setModel(_ creator: [Creator], followType: FollowType) {
        navigationSetting(followType)
        
    }
    
    override func subscribe() {
        
    }
    
    private
    func navigationSetting(_ model: FollowType) {
        var title = ""
        switch model {
        case .follower:
            title = "팔로워"
        case .following:
            title = "팔로잉"
        }
        navigationItem.title = title
    }
}
