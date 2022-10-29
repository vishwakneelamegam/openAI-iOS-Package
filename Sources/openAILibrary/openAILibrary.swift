import Foundation
import Alamofire

public enum response{
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

public class openAIService{
    
    private var openAIApiKey : String = ""
    
    public init(apiKey : String){
        self.openAIApiKey = apiKey
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
            return "Say, No input"
        }
        if data.count > 0{
            var checkArray = [String]()
            for i in 0...data.count - 1{
                if data[i].trimmingCharacters(in: .whitespacesAndNewlines).count > 0{
                    checkArray.append(data[i])
                }
            }
            if checkArray.count == 0{
                return "Say, No input"
            }
            return checkArray.joined(separator: "\n\n")
        }
        return "Say, No input"
    }
    
    private func checkResponseAndGetTextData(data : Data) -> (response, String){
        do{
            guard let responseDictionary = try JSONSerialization.jsonObject(with: data,options: .allowFragments) as? [String : Any] else{
                return (.receivedCorruptedData, "")
            }
            if (responseDictionary.keys.contains("choices")){
                guard let choiceArray = responseDictionary["choices"] as? [Any] else{
                    return (.receivedCorruptedData, "")
                }
                if !choiceArray.isEmpty{
                    guard let firstChoice = choiceArray[0] as? [String : Any] else{
                        return (.receivedCorruptedData, "")
                    }
                    if firstChoice.keys.contains("text"){
                        guard let text  = firstChoice["text"] as? String else{
                            return (.receivedCorruptedData, "")
                        }
                        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                        return (.receivedUncorruptedData, cleanText)
                    }
                    return (.receivedCorruptedData, "")
                }
            }
            return (.receivedCorruptedData, "")
        }
        catch{
            return (.receivedCorruptedData, "")
        }
        
    }
    
    public func request(prompt : String, completion : @escaping (response, String) -> Void){
        AF.request(openAIStaticData.openApiLink,method: .post,parameters: self.makeParameter(prompt: prompt), encoding: JSONEncoding.default, headers: self.makeHeader()).validate(statusCode: 200..<299).responseData(completionHandler: {
            response in
            switch response.result{
            case .success(let data):
                let result : (response, String) = self.checkResponseAndGetTextData(data: data)
                completion(result.0, result.1)
            case .failure(_):
                completion(.networkFailure, "")
            }
        })
    }
}

