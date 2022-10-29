# openAILibrary

Used to access openAI service.

## Requirement

- Provide api key to the variable openAIApiKey(Get your api key from https://beta.openai.com/account/api-keys).
- Before requesting, you have to provide prompt as input(The prompt can be created using the function makePrompt).

## Open AI defined parameters
- API - https://api.openai.com/v1/completions
- Model - text-davinci-002
- Temperture - 0
- Max Tokens - 100

## Package manager link
- https://github.com/vishwakneelamegam/openAI-iOS-Package

## The package uses
- Alamofire - https://github.com/Alamofire/Alamofire

## Sample code

```
import SwiftUI
import openAILibrary

struct mainUI: View {
    @StateObject var openAIObj = openAIService()
    private func startOpenAIService(){
        self.openAIObj.openAIApiKey = "<provide-your-API-key-here>"
        self.openAIObj.request(prompt: self.openAIObj.makePrompt(data: [
            "Correct this to standard english",
            "She no went to the market"
        ]))
    }
    var body: some View {
        VStack{
            switch(self.openAIObj.status){
            case .startService:
                Text("Start service")
            case .receivedResponse:
                Text("Received response")
            case .receivedUncorruptedData:
                Text(self.openAIObj.responseText)
            case .receivedCorruptedData:
                Text("Received corrupted text")
            case .networkFailure:
                Text("Network failure")
            }
            
        }.onAppear(perform: {
            self.startOpenAIService()
        })
    }
}
```
