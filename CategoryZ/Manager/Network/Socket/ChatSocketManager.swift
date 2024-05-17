//
//  SocketManager.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/16/24.
//

import Foundation
import SocketIO
import RxSwift

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
enum ChatSocketManagerError: Error {
    case nilSocat
    case weakError
    case JSONDecodeError
    
    var message: String {
        switch self {
        case .nilSocat:
            return "인터넷 환경을 확인해 주세요"
        case .weakError:
            return "치명적이 에러가 발생했습니다."
        case .JSONDecodeError:
            return "모델을 불러오는중 문제가 발생 했어요!"
        }
    }
}

final class ChatSocketManager {
    
    typealias ChatSocketManagerResult = PublishSubject<Result<ChatModel,ChatSocketManagerError>>
    
    static
    let shared = ChatSocketManager()
    
    private
    var manager: SocketManager?
    
    private
    var socket: SocketIOClient?
    
    private
    let decodable = JSONDecoder()
    
    /// 해당 프로퍼티를 통해 채팅 정보를 받으셔요
    let chatSocketResult = ChatSocketManagerResult ()

    private init() {
        setupManager()
    }

}
// 클라이언트
extension ChatSocketManager {
    
    func setID(id: String) {
        socket = manager?.socket(forNamespace: id)
        
        guard let socket else {
            chatSocketResult.onNext(.failure(.nilSocat))
            return
        }
        statrObserver(socket: socket)
    }
}
// 내부 코드
extension ChatSocketManager {
    
    private 
    func setupManager(){
        var baseUrl = APIKey.baseURL.rawValue
        var version = ChatRouter.myChatRooms.version
        let url = URL(string: baseUrl + version)!
        print("ChatSocketManager URL: \(url)")
        manager = SocketManager(
            socketURL: url,
            config: [.log(true), .compress]
        )
    }
    
    private
    func statrObserver(socket: SocketIOClient){
        
        socket.on( // 소켓이 서버에 성공적 연결 되었음을 의미
            clientEvent: .connect
        ) { data, ack in
            print(data, ack)
        }
        
        socket.on( // 소켓이 서버와 연결이 끊어졌을때 발생함
            clientEvent: .disconnect
        ) { data, ack in
            print(data, ack)
        }
        
        socket.on("chat") { [unowned self] dataArray, ack in
            
            do {
                if let data = dataArray.first {
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    
                    let decoded = try decodable.decode(ChatModel.self, from: jsonData)
                    
                    chatSocketResult.onNext(.success(decoded))
                }
            } catch(let error) {
                chatSocketResult.onNext(.failure(.JSONDecodeError))
            }
        }
    }
}
