//
//  SocketManager.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/16/24.
//

import Foundation
import SocketIO
// 소켓 아이오 내부 코드 를 다 까보진 못했으나
/*
 소켓 아이오 에미터 파일에
 socket.manager?.handleQueue.asyncAfter(deadline: DispatchTime.now() + seconds) {[weak socket, weak self] in
             guard let socket = socket, let `self` = self else { return }

             socket.ackHandlers.timeoutAck(self.ackNumber)
         }
 같이 비동기 디스페치를 사용하는 것으로 추정됨으로 바로 사용할 예정
 다만 밖에서 사용시 UI 반영때에 알아서 풀어서 준건지는 분석을 못함
 */

final class ChatSocketManager {
    
    static
    let shared = ChatSocketManager()
    
    var manager: SocketIO.SocketManager?
    var socket: SocketIOClient?
    
    init() {
//        manager = SocketManager(
//            socketURL: <#T##URL#>,
//            config: <#T##[String : Any]?#>
//        )
        
    }
    
    
}
