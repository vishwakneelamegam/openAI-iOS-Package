# openAILibrary

Used to access openAI completions service.

## Requirement

- Provide api key to the variable openAIApiKey(Get your api key from https://beta.openai.com/account/api-keys).
- Before requesting, you have to provide prompt as input(The prompt can be created using the function makePrompt).

## Methods
- request(prompt : String) - Used to make api request.
- makePrompt(data : [String]) - Used to make prompt.  Example ["Correct this to standard English","She no went to the market"]

## Variables
- status - Provides the status(startService, receivedResponse, receivedUncorruptedData, receivedCorruptedData, networkFailure) of the openAI service.
- responseText -  Provides the response text from the openAI service.
- openAIApiKey - You have to provide the openAI Api key to this variable.

## Open AI defined parameters
- API - https://api.openai.com/v1/completions
- Model - text-davinci-002
- Temperture - 0
- Max Tokens - 100

## Package dependencies
- Alamofire
