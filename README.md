# COVID Wallet (API)

Backend API for [COVID Wallet](https://covidwallet.pt).

This API, written in Swift and using Vapor as its web framework, takes care of converting a QR code from the Portuguese EU COVID Digital Certificate into a pass that can be imported into the Wallet on iOS devices.

Even though it's written in Swift, it was tested and runs fine on at least macOS and Linux.

## Compiling

Compile using `swift build -c release`. The Swift toolchain must be installed. At least `Swift 5.2` is required.

## Pre-Requisites

This project requires `zip` and `zsh` to be present on your system. 

The dependency on `zsh` was a bad decision and will be eventually dropped.

## Running

- Move the release build somewhere, along with the `Resources` folder. 
   - Under `Resources/Certificates` three files are expected: `PassCertificate.pem` (the public key part of your pass certificate), `PassKey.pem` (the private key part of your pass certificate) and `WWDRCA.pem`, Apple's WWDR certificate authority.
 - The following environment variables **MUST** be set in order for the app to run correctly:
   - `CERTIFICATE_KEY`: The key for your `PassKey.pem` file.
   - `PASS_TYPE_IDENTIFIER`: The pass type identifier.
   - `TEAM_IDENTIFIER`: Your Apple Developer team identifier.
 - Run the app!

## License

GPLv3
