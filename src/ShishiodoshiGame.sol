// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Shishiodoshi {
    struct Bid {
        address bidder;
        uint8 amount;
    }

    struct GameInfo {
        address bidToken;
        uint256 bidIncrement;
        uint8 startingCoinAmount;
        uint8 playerCount;
        uint256 minimumDeposit; //in bidToken units bidIncrement*coinsNeeded
        bytes32 winningHash;
        address[] playerOrder;
        uint16 totalBid;
        uint16 turn;
        bool isEnded;
        Bid[] bidHistory;
    }

    address owner;
    mapping(address => bool) public isAdmin;
    mapping(address => bool) public supportedTokens;
    mapping(uint256 => GameInfo) public gameInfos;
    mapping(uint256 => mapping(address => uint8)) public gamePlayers; //controls the increment to decide who is next
    mapping(uint256 => mapping(address => uint8)) public gameBalances;

    uint256 public nextGameID = 0;
    uint8 public minCoin = 10;
    uint8 public maxCoin = 100;

    // Events
    event GameCreated(uint256 gameID);
    event GameInitialized(uint256 gameID, bytes32 winningHash);
    event GameStarted(uint256 gameID);
    event BidReceived(uint256 gameID);

    constructor(address _token) {
        owner = msg.sender;
        isAdmin[msg.sender] = true;
        supportedTokens[_token] = true;
    }

    // Admin Functions

    modifier onlyAdmin() {
        require(isAdmin[msg.sender] == true, "NGMI");
        _;
    }

    function addAdmin(address _newAdmin) public onlyAdmin {
        isAdmin[_newAdmin] = true;
    }

    function removeAdmin(address _newAdmin) public onlyAdmin {
        isAdmin[_newAdmin] = false;
    }

    function addSupportedToken(address _token) public onlyAdmin {
        supportedTokens[_token] = true;
    }

    function removeSupportedToken(address _token) public onlyAdmin {
        supportedTokens[_token] = false;
    }

    function changeMin(uint8 _minCoin) public onlyAdmin {
        require(_minCoin < maxCoin, "Minimum coin amount larger than max");
        minCoin = _minCoin;
    }

    function changeMax(uint8 _maxCoin) public onlyAdmin {
        require(minCoin < _maxCoin, "Maximum coin amount smaller than min");
        maxCoin = _maxCoin;
    }

    function newGame(
        address _bidToken,
        uint256 _bidIncrement,
        uint8 _playerCount,
        uint8 _startingCoinAmount
    )
        public
        returns (uint256 currentGameID)
    {
        require(supportedTokens[_bidToken], "Token is not supported");
        require(minCoin <= _startingCoinAmount, "Starting coin is below limit");
        require(maxCoin >= _startingCoinAmount, "Starting coin is above limit");
        currentGameID = nextGameID;

        GameInfo storage game = gameInfos[currentGameID];
        game.bidToken = _bidToken;
        game.bidIncrement = _bidIncrement;
        game.playerCount = _playerCount;
        game.startingCoinAmount = _startingCoinAmount;
        game.minimumDeposit = _startingCoinAmount * _bidIncrement;

        nextGameID += 1;
        emit GameCreated(currentGameID);
    }

    function initGame(uint256 _gameID, bytes32 _winningHash) public onlyAdmin {
        GameInfo storage game = gameInfos[_gameID];
        require(game.winningHash == bytes32(0), "Game already initialized");
        game.winningHash = _winningHash;
        emit GameInitialized(_gameID, _winningHash);
    }

    function joinGame(uint256 _gameID) public {
        require(_gameID < nextGameID, "Game not yet created");
        GameInfo storage game = gameInfos[_gameID];
        require(game.winningHash != bytes32(0), "Game not initialized");
        require(gamePlayers[_gameID][msg.sender] == 0, "You already joined this game");
        require(game.playerOrder.length < game.playerCount, "Game full");

        ERC20(game.bidToken).transferFrom(msg.sender, address(this), game.minimumDeposit);
        game.playerOrder.push(msg.sender);
        gamePlayers[_gameID][msg.sender] = 1;
        gameBalances[_gameID][msg.sender] = game.startingCoinAmount;

        if (game.playerOrder.length == game.playerCount) {
            for (uint256 i = 0; i < game.playerOrder.length; i++) {
                uint256 n = i + uint256(keccak256(abi.encodePacked(block.timestamp))) % (game.playerOrder.length - i);
                address temp = game.playerOrder[n];
                game.playerOrder[n] = game.playerOrder[i];
                game.playerOrder[i] = temp;
            }
            emit GameStarted(_gameID);
        }
    }

    function leaveGame(uint256 _gameID) public {
        require(_gameID < nextGameID, "Game not yet created");
        GameInfo storage game = gameInfos[_gameID];
        require(game.winningHash != bytes32(0), "Game not initialized");
        require(game.playerOrder.length != game.playerCount, "Cant leave game already started");
        require(gamePlayers[_gameID][msg.sender] == 1, "Not a player of this game");

        ERC20(game.bidToken).transfer(msg.sender, game.minimumDeposit);
        delete gamePlayers[_gameID][msg.sender];
        delete  gameBalances[_gameID][msg.sender];
        uint256 leavingPlayerIndex = 0;
        for (; leavingPlayerIndex < game.playerOrder.length; leavingPlayerIndex++) {
            if (game.playerOrder[leavingPlayerIndex] == msg.sender) {
                break;
            }
        }

        game.playerOrder[leavingPlayerIndex] = game.playerOrder[game.playerOrder.length - 1];
        game.playerOrder.pop();
    }

    function bidGame(uint256 _gameID, uint8 _tokenAmount) public {
        require(_gameID < nextGameID, "Game not yet created");
        GameInfo storage game = gameInfos[_gameID];
        require(game.winningHash != bytes32(0), "Game not initialized");
        require(game.playerOrder.length == game.playerCount, "Game not yet started");
        require(gameBalances[_gameID][msg.sender] >= _tokenAmount, "Not enough balance");

        uint256 playerIndex = game.turn % game.playerCount;
        require(game.playerOrder[playerIndex] == msg.sender, "Wrong turn");
        gameBalances[_gameID][msg.sender] -= _tokenAmount;
        game.totalBid += _tokenAmount;

        game.turn += gamePlayers[_gameID][msg.sender];

        if (gameBalances[_gameID][msg.sender] == 0) {
            uint8 currentStep = gamePlayers[_gameID][msg.sender];
            gamePlayers[_gameID][msg.sender] = 0;
            uint256 i = playerIndex - 1;
            // check from player before backwards
            for (; i >= 0; i--) {
                if (gameBalances[_gameID][game.playerOrder[i]] > 0) {
                    gamePlayers[_gameID][game.playerOrder[i]] += currentStep;
                    break;
                }
            }
            // if i reaches 0 start looping from array end till playerIndex
            if (i == 0) {
                for (i = game.playerOrder.length - 1; i > playerIndex; i--) {
                    if (gameBalances[_gameID][game.playerOrder[i]] > 0) {
                        gamePlayers[_gameID][game.playerOrder[i]] += currentStep;
                        break;
                    }
                }
            }
            // Sanity check
            require(i != playerIndex, "Fatal error");
        }

        Bid memory bid = Bid({ amount: _tokenAmount, bidder: msg.sender });

        game.bidHistory.push(bid);
        emit BidReceived(_gameID);
    }

    function findTipper(uint256 _gameID, uint16 _tippingAmount) internal returns (address tipper) {
        GameInfo storage game = gameInfos[_gameID];
        uint256 totalBid = game.totalBid;
        for (uint256 tipIndex = game.bidHistory.length - 1; tipIndex >= 0; tipIndex--) {
            Bid memory bid = game.bidHistory[tipIndex];
            totalBid -= bid.amount;
            if (totalBid < _tippingAmount) {
                tipper = bid.bidder;
                break;
            } else {
                // refund the player
                gameBalances[_gameID][bid.bidder] += bid.amount;
                game.totalBid -= bid.amount;
                game.bidHistory.pop();
            }
        }
    }

    function getHighestNonTipperBid(
        uint256 _gameID,
        address _tipper
    )
        internal
        view
        returns (uint8 highestNonTipperBid)
    {
        GameInfo memory game = gameInfos[_gameID];
        for (uint256 i = 0; i < game.playerOrder.length; i++) {
            if (game.playerOrder[i] != _tipper) {
                uint8 bidAmount = game.startingCoinAmount - gameBalances[_gameID][game.playerOrder[i]];
                if (highestNonTipperBid < bidAmount) {
                    highestNonTipperBid = bidAmount;
                }
            }
        }
    }

    function getHighestNonTipperBidCount(
        uint256 _gameID,
        address _tipper,
        uint8 _highestNonTipperBid
    )
        internal
        returns (uint8 highestNonTipperBidCount)
    {
        GameInfo memory game = gameInfos[_gameID];
        for (uint256 i = 0; i < game.playerOrder.length; i++) {
            if (game.playerOrder[i] != _tipper) {
                uint8 bidAmount = game.startingCoinAmount - gameBalances[_gameID][game.playerOrder[i]];
                if (bidAmount == _highestNonTipperBid) {
                    highestNonTipperBidCount += 1;
                }
            }
        }
    }

    function transferBalances(
        uint256 _gameID,
        address _tipper,
        uint8 _prize,
        uint8 _highestNonTipperBid,
        uint8 fee
    )
        internal
    {
        GameInfo memory game = gameInfos[_gameID];
        ERC20 gameToken = ERC20(game.bidToken);
        for (uint256 i = 0; i < game.playerOrder.length; i++) {
            address player = game.playerOrder[i];
            uint8 refundCoinAmount;
            if (player != _tipper) {
                refundCoinAmount = game.startingCoinAmount;
                if (gameBalances[_gameID][player] == (game.startingCoinAmount - _highestNonTipperBid)) {
                    refundCoinAmount += _prize;
                }
            } else {
                refundCoinAmount = gameBalances[_gameID][_tipper];
            }
            gameToken.transfer(player, game.bidIncrement * refundCoinAmount);
        }
        gameToken.transfer(owner, game.bidIncrement * fee);
    }

    function endGame(uint256 _gameID, uint16 _tippingAmount, bytes32 _randomHash) public onlyAdmin {
        require(_gameID < nextGameID, "Game not yet created");
        GameInfo storage game = gameInfos[_gameID];
        require(game.winningHash != bytes32(0), "Game not initialized");
        require(game.playerOrder.length == game.playerCount, "Game not yet started");
        require(!game.isEnded, "Game already ended");
        require(game.totalBid > _tippingAmount, "Not enough bids");

        bytes memory tippingAmountBytes = new bytes(32);
        assembly {
            mstore(add(tippingAmountBytes, 32), _tippingAmount)
        }

        bytes memory winningRaw = new bytes(32);
        winningRaw[0] = tippingAmountBytes[30];
        winningRaw[1] = tippingAmountBytes[31];

        for (uint256 i = 0; i < 30; i++) {
            winningRaw[i + 2] = _randomHash[i];
        }
        bytes32 winningHash = sha256(winningRaw);

        require(game.winningHash == winningHash, "Hash mismatch");
        game.isEnded = true;

        address tipper = findTipper(_gameID, _tippingAmount);
        uint8 prizePool = game.startingCoinAmount - gameBalances[_gameID][tipper];

        uint8 highestNonTipperBid = getHighestNonTipperBid(_gameID, tipper);
        uint8 highestNonTipperBidCount = getHighestNonTipperBidCount(_gameID, tipper, highestNonTipperBid);

        // TODO Change this calculation because there are cases where the winners wont receive anything.
        uint8 prizeAmount = prizePool / highestNonTipperBidCount;
        uint8 fee = prizePool % highestNonTipperBidCount;

        // Perform balance transfers
        transferBalances(_gameID, tipper, prizeAmount, highestNonTipperBid, fee);
    }

    function getPlayerOrder(address _player, uint256 _gameID) public view returns (uint256 order) {
        require(_gameID < nextGameID, "Game not yet created");
        GameInfo storage game = gameInfos[_gameID];
        for (order = 0; order < game.playerOrder.length; order++) {
            if (game.playerOrder[order] == _player) {
                return order;
            }
        }
    }

    function getCurrentPlayer(uint256 _gameID) public view returns (address) {
        require(_gameID < nextGameID, "Game not yet created");
        GameInfo storage game = gameInfos[_gameID];
        return game.playerOrder[game.turn % game.playerCount];
    }

    function getPlayers(uint256 _gameID) public view returns (address[] memory) {
        require(_gameID < nextGameID, "Game not yet created");
        GameInfo storage game = gameInfos[_gameID];
        return game.playerOrder;
    }

    function getGameRequirements(uint256 _gameID) public view returns (uint8, string memory, uint256, uint8) {
        require(_gameID < nextGameID, "Game not yet created");
        GameInfo storage game = gameInfos[_gameID];
        string memory tokenSymbol = ERC20(game.bidToken).symbol();
        return (game.playerCount, tokenSymbol, game.bidIncrement, game.startingCoinAmount);
    }
}
