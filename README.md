# openAILibrary

Used to access openAI service.

## Requirement

- Provide api key.
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
    var openAIObj = openAIService(apiKey: "<provide-your-api-key-here>")
    @State var showResponse : String = ""
    private func startOpenAIService(){
        self.openAIObj.request(prompt: self.openAIObj.makePrompt(data: [
            "Correct this to standard english",
            "She no went to the market"
        ])) { response, text in
            switch(response){
            case .receivedCorruptedData:
                self.showResponse = "corrupted data"
            case .receivedUncorruptedData:
                self.showResponse = text
            case .networkFailure:
                self.showResponse = "network failure"
            }
        }
    }
    var body: some View {
        VStack{
            Text(self.showResponse)
            
        }.onAppear(perform: {
            self.startOpenAIService()
        })
    }
}
```
