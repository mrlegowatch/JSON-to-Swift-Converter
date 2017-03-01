# JSON-to-Swift-Converter
An Xcode 8 editor extension to convert JSON format to Swift code.

## Description
This is a lightweight naïve implementation for converting JSON-formatted text into Swift code. The JSON-formatted text structure and types are interpreted, and code is generated.
There are several settings for controlling how the code is generated. By default, keys for dictionaries are declared, and properties and nested types are declared. The settings can be changed from the application that hosts the Xcode editor extension.

## Example

The extension will convert the following JSON-formatted text:
```json
{
    "currency": [
                 {
                 "symbol": "cp",
                 "coefficient": 0.01,
                 "long name": "copper piece",
                 "long name plural": "copper pieces"
                 },
                 {
                 "symbol": "sp",
                 "coefficient": 0.1,
                 "long name": "silver piece",
                 "long name plural": "silver pieces"
                 }
                ]
}
```
Into the following Swift implementation:

```swift

    struct Key {

        let symbol = "symbol"
        let longNamePlural = "long name plural"
        let currency = "currency"
        let longName = "long name"
        let coefficient = "coefficient"

    }

    struct <#CurrencyType#> {

        let longNamePlural: String!
        let coefficient: Double!
        let symbol: String!
        let longName: String!

    }

    let currency: [<#CurrencyType#>]!

```

## Usage
In Xcode, choose `Editor` > `Convert JSON to Swift` > `Convert`. 

## Settings

In Xcode, choosing `Editor` > `Convert JSON to Swift` > `Settings...` opens the host application where settings that control the conversion can be changed. Settings include:

- `declaration`: specify `let` or `var` for property declarations (default is `let`)
- `typeUnwrapping`: options include `explicit`, `optional` ("?"), or `required` ("!") (default is `required`)
- `addKeys`: whether to add key declarations in a `Key` struct (default is true)
- `addDefaultValue`: whether to add default values, e.g., "= 0" (default is false)

## Credits

This extension is loosely based on <a href = "https://github.com/keepyounger/Json2Property">Json2Property</a>, which in turn is based on <a href ="https://github.com/EnjoySR/ESJsonFormat-Xcode">ESJsonFormat-Xcode</a>. This version is written entirely Swift, is expanded a bit, and has unit tests.
