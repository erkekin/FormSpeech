# FormSpeech
Talk to fill long boring forms in your iOS 10 app!


![FormSpeech descriptive image](https://github.com/erkekin/FormSpeech/blob/master/FormSpeech.png?raw=true)

## Usage

- Change language from en-US to your locale in the ViewController.swift
- Fill Field enum with your custom form data words as in the below.
- Conform your controller to FormSpeechDelegate
- implement func valueParsed(parser: Parser, forValue value: String, andKey key: Field) in your ViewController
- Profit!

```

enum Field: String, Iteratable{

case name = "My name is"
case surname = "my surname is"
case birthPlace = "I live in"
case phoneNumber = "my number is"

}
```

Thanks.

@erkekin
