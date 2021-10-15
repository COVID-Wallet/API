# COVID Wallet (API)

Backend API for [COVID Wallet](https://covidwallet.pt).

This API, written in Swift and using Vapor as its web framework, takes care of converting a QR code from the EU COVID Digital Certificate into a pass that can be imported into the Wallet on iOS devices.

It's written in Swift, and supports both macOS and Linux.

## Compiling

Compile using `swift build -c release`. The Swift toolchain must be installed. At least `Swift 5.2` is required.

## Pre-Requisites

This project requires `zip` to be present on your system. You should have it already if you are running macOS, but you probably need to install it on Linux systems.

## Running

- Move the release build somewhere, along with the `Resources` folder. 
   - The release build will be located under a `.build` folder on the project directory, considering you ran the command above.
   - Under `Resources/Certificates` three files are expected: `PassCertificate.pem` (the public key part of your pass certificate), `PassKey.pem` (the private key part of your pass certificate) and `WWDRCA.pem`, Apple's WWDR certificate authority.
 - The following environment variables **MUST** be set in order for the app to run correctly:
   - `CERTIFICATE_KEY`: The key for your `PassKey.pem` file.
   - `PASS_TYPE_IDENTIFIER`: The pass type identifier.
   - `TEAM_IDENTIFIER`: Your Apple Developer team identifier.
 - Run the app!

## License

GPLv3
