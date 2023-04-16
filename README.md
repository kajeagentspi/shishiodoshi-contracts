# Shishiodoshi-contracts [![Open in Gitpod][gitpod-badge]][gitpod] [![Github Actions][gha-badge]][gha] [![Foundry][foundry-badge]][foundry] [![License: MIT][license-badge]][license]

[gitpod]: https://gitpod.io/#https://github.com/kajeagentspi/shishiodoshi-contracts
[gitpod-badge]: https://img.shields.io/badge/Gitpod-Open%20in%20Gitpod-FFB45B?logo=gitpod
[gha]: https://github.com/kajeagentspi/shishiodoshi-contracts/actions
[gha-badge]: https://github.com/kajeagentspi/shishiodoshi-contracts/actions/workflows/ci.yml/badge.svg
[foundry]: https://getfoundry.sh/
[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg
[license]: https://opensource.org/licenses/MIT
[license-badge]: https://img.shields.io/badge/License-MIT-blue.svg

Discord-integrated party game, that boosts communication within DAOs.

## Getting Started
1. Clone this repo.
2. Run ```forge build to install``` dependensies.
3. Run ```forge flatten src/ShishiodoshiGame.sol > game.sol```.
3. Run ```forge flatten src/ShishiodoshiToken.sol > token.sol```.
4. Using remix deploy the flattened contracts to your desired networks.

### Related Repositories
| [frontend](https://github.com/miyatakoji/shishiodoshi-app) |
| [gamemaster](https://github.com/kajeagentspi/shishiodoshi-go) |
| [youtube](https://youtu.be/1UM0RJBo1t4)|
### Token Contract Addresses
| Chain   | Address |
| ------- | ------- |
| Celo Alfajores | [0xd259fD0089c277c35a93C47Bc2A0771AC0c79A3C](https://alfajores.celoscan.io/address/0xd259fD0089c277c35a93C47Bc2A0771AC0c79A3C#code) |
| Mantle Testnet | [0xd259fD0089c277c35a93C47Bc2A0771AC0c79A3C](https://explorer.testnet.mantle.xyz/address/0xd259fD0089c277c35a93C47Bc2A0771AC0c79A3C/contracts#address-tabs) |
| Gnosis Mainnet | [0xd259fD0089c277c35a93C47Bc2A0771AC0c79A3C](https://gnosisscan.io/address/0xd259fd0089c277c35a93c47bc2a0771ac0c79a3c#code) |
| Taiko Testnet | [0xd259fD0089c277c35a93C47Bc2A0771AC0c79A3C](https://l2explorer.hackathon.taiko.xyz/address/0xd259fD0089c277c35a93C47Bc2A0771AC0c79A3C/contracts#address-tabs) |
| Polygon Mainnet | [0xd259fD0089c277c35a93C47Bc2A0771AC0c79A3C](https://polygonscan.com/address/0xd259fd0089c277c35a93c47bc2a0771ac0c79a3c#code) |

### Game Contract Addresses
| Chain   | Address | Supported Tokens |
| ------- | ------- | ------- |
| Celo Alfajores | [0x1e6c3bd6f9d01814fff919fc2c2f80de3a105627](https://alfajores.celoscan.io/address/0x1e6c3bd6f9d01814fff919fc2c2f80de3a105627#code) | [SSO](https://alfajores.celoscan.io/address/0xd259fD0089c277c35a93C47Bc2A0771AC0c79A3C#code) |
| Mantle Testnet | [0x1e6c3bd6f9d01814fff919fc2c2f80de3a105627](https://explorer.testnet.mantle.xyz/address/0x1e6c3bd6f9d01814fff919fc2c2f80de3a105627/contracts#address-tabs) | [SSO](https://explorer.testnet.mantle.xyz/address/0xd259fD0089c277c35a93C47Bc2A0771AC0c79A3C/contracts#address-tabs) |
| Gnosis Mainnet | [0x1e6c3bd6f9d01814fff919fc2c2f80de3a105627](https://gnosisscan.io/address/0x1e6c3bd6f9d01814fff919fc2c2f80de3a105627#code) | [SSO](https://gnosisscan.io/address/0xd259fd0089c277c35a93c47bc2a0771ac0c79a3c#code) |
| Taiko Testnet | [0x1e6c3bd6f9d01814fff919fc2c2f80de3a105627](https://l2explorer.hackathon.taiko.xyz/address/0x1E6c3bd6f9d01814FFF919Fc2C2f80de3a105627/contracts#address-tabs) | [SSO](https://l2explorer.hackathon.taiko.xyz/address/0xd259fD0089c277c35a93C47Bc2A0771AC0c79A3C/contracts#address-tabs) |
| Polygon Mainnet | [0x1e6c3bd6f9d01814fff919fc2c2f80de3a105627](https://polygonscan.com/address/0x1e6c3bd6f9d01814fff919fc2c2f80de3a105627#code) | [SSO](https://polygonscan.com/address/0xd259fd0089c277c35a93c47bc2a0771ac0c79a3c#code) [APE](https://polygonscan.com/address/0xB7b31a6BC18e48888545CE79e83E06003bE70930) [BOB](https://polygonscan.com/address/0xB0B195aEFA3650A6908f15CdaC7D92F8a5791B0B) |
