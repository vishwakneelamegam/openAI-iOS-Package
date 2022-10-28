import Foundation
import Alamofire

public enum response{
    case startService
    case receivedResponse
    case receivedUncorruptedData
    case receivedCorruptedData
    case networkFailure
}

public struct openAIStaticData{
    static let openApiLink : String = "https://api.openai.com/v1/completions"
    static let openApiContentType : String = "application/json"
    static let openApiModel : String = "text-davinci-002"
    static let openApiTemperature : Int = 0
    static let openApiMaxTokens : Int = 100
}

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public class openAIService : ObservableObject{
    
    @Published public var status = response.startService
    @Published public var responseText : String = ""
    @Published public var openAIApiKey : String = ""
    
    public init(){
        self.flush()
    }
    
    private func flush(){
        self.status = response.startService
        self.responseText = ""
    }
    
    private func makeApiKey() -> String{
        return "Bearer \(self.openAIApiKey)"
    }
    
    private func makeHeader() -> HTTPHeaders{
        let header : HTTPHeaders = [
            "Content-Type" : openAIStaticData.openApiContentType,
            "Authorization" : self.makeApiKey()
        ]
        return header
    }
    
    private func makeParameter(prompt : String) -> [String : Any]{
        var parameter = [String : Any]()
        parameter["model"] = openAIStaticData.openApiModel
        parameter["prompt"] = prompt
        parameter["temperature"] = openAIStaticData.openApiTemperature
        parameter["max_tokens"] = openAIStaticData.openApiMaxTokens
        return parameter
    }
    
    public func makePrompt(data : [String]) -> String{
        if data.count == 0{
            return "Say, Empty array"
        }
        if data.count > 0{
            var checkArray = [String]()
            for i in 0...data.count - 1{
                if data[i].trimmingCharacters(in: .whitespacesAndNewlines).count > 0{
                    checkArray.append(data[i])
                }
            }
            if checkArray.count == 0{
                return "Say, Empty array"
            }
            return checkArray.joined(separator: "\n\n")
        }
        return "Say, Empty array"
    }
    
    private func checkResponseAndGetTextData(data : Data){
        do{
            guard let responseDictionary = try JSONSerialization.jsonObject(with: data,options: .allowFragments) as? [String : Any] else{
                self.status = .receivedCorruptedData
                return
            }
            if (responseDictionary.keys.contains("choices")){
                guard let choiceArray = responseDictionary["choices"] as? [Any] else{
                    self.status = .receivedCorruptedData
                    return
                }
                if !choiceArray.isEmpty{
                    guard let firstChoice = choiceArray[0] as? [String : Any] else{
                        self.status = .receivedCorruptedData
                        return
                    }
                    if firstChoice.keys.contains("text"){
                        guard let text  = firstChoice["text"] as? String else{
                            self.status = .receivedCorruptedData
                            return
                        }
                        self.status = .receivedUncorruptedData
                        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                        self.responseText = cleanText
                        return
                    }
                    return
                }
            }
            return
        }
        catch{
            self.status = .receivedCorruptedData
            return
        }
        
    }
    
    public func request(prompt : String){
        self.flush()
        AF.request(openAIStaticData.openApiLink,method: .post,parameters: self.makeParameter(prompt: prompt), encoding: JSONEncoding.default, headers: self.makeHeader()).validate(statusCode: 200..<299).responseData(completionHandler: {
            response in
            switch response.result{
            case .success(let data):
                self.status = .receivedResponse
                self.checkResponseAndGetTextData(data: data)
            case .failure(_):
                self.status = .networkFailure
            }
        })
    }
}

