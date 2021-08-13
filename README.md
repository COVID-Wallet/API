# COVID Wallet (API)

Backend API for [COVID Wallet](https://covidwallet.pt).

This API, written in Swift and using Vapor as its web framework, takes care of converting a QR code from the Portuguese EU COVID Digital Certificate into a pass that can be imported into the Wallet on iOS devices.

Even though it's written in Swift, it was tested and runs fine on at least macOS and Linux.

## How to...

 - Compile using `swift build -c release`.
 - Move the release build somewhere, along with the `Resources` folder. 
   - Under `Resources/Certificates` three files are expected: `PassCertificate.pem` (the public key part of your pass certificate), `PassKey.pem` (the private key part of your pass certificate) and `WWDRCA.pem`, Apple's WWDR certificate authority.
 - Run the app!

## License

GPLv3
