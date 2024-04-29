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
 
 /*
  여기서 유저 아이디가 본인 아이디와 같다면....?
  그때도... 하...
  다시 갈고 해보자
  */
 
 */
enum FollowType {
    case follower
    case following
}

final class FollowerAndFolowingViewController: RxHomeBaseViewController<FollowerAndFollowingView> {
    
    private
    let viewModel = FollowerFollowingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeView.tableView.rowHeight = UITableView.automaticDimension
        homeView.tableView.estimatedRowHeight = 150
    }
    
    func setModel(_ creator: [Creator], followType: FollowType, isME: ProfileType) {
        navigationSetting(followType)
        subscribe(creator, isMe: isME, followType: followType)
    }

    private
    func subscribe(_ creator: [Creator], isMe: ProfileType,followType: FollowType) {
        dump(creator)
        let myID = UserIDStorage.shared.userID
        guard let myID else {
            errorCatch(.refreshTokkenError(statusCode: 419, description: "ID Error"))
            return
        }
        
        let behivorPersons = BehaviorRelay(value: creator)
        let behaviorRelay = BehaviorRelay(value: isMe)
        
        let input = FollowerFollowingViewModel.Input(
            inputPersons: behivorPersons,
            inputProfileType: behaviorRelay,
            followType: followType,
            inputMyId: myID
        )
        
        let output = viewModel.transform(input)
        
        // 에러 발생시
        output.networkError
            .drive(with: self) { owner, error in
                owner.errorCatch(error)
            }
            .disposed(by: disPoseBag)
        
        output.outputOtherUser.drive(homeView.tableView.rx.items(cellIdentifier: FollowerAndFollwingTableViewCell.identi, cellType: FollowerAndFollwingTableViewCell.self)) { row, item, cell in
            print("셀입장에서",item.isFollow)
            cell.errorCatch = self
            cell.setModel(item, myID)
        }
        .disposed(by: disPoseBag)
        
    
        
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
