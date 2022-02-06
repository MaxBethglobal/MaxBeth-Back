//SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;
                        
import "hardhat/console.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
// import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
// import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";

// Event
// result1, result2...

// contract BettingEvent is ERC1155Supply, ERC1155Holder, Ownable {
/// @title A title that should describe the contract/interface
/// @author The name of the author
/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
contract Betting is ERC1155Supply, Ownable {
    
    enum State {
        INIT, OPEN, LOCKED, ENDED
    }
    
    //mapping(address => mapping(uint256 => uint256)) private _xxxxxxx;
    struct BettingEvent {
        State status;
        uint256 finalResult;
        mapping(uint256 => bool) resultsIds;
        uint256[] resultsIdsKeys;
    }
    mapping(uint256 => BettingEvent) public bettingEvents;
    uint256[] public bettingEventsKeys;
    //TODO add event ids in functions (param...)

    // mapping(uint256 => uint256) public finalResult4Ev;
    // mapping(uint256 => mapping(uint256 => bool)) public resultsIds4Ev;
    // mapping(uint256 => uint256[]) public resultsIdsKeys4Ev;

    State public status;
    uint256 public finalResult;
    mapping(uint256 => bool) public resultsIds;
    uint256[] public resultsIdsKeys;
    // fee or "rake" :
    uint256 public fee = 100;

    // "https://ourserver/api/event/{id}.json"
    // constructor(string memory uri_) ERC1155(uri_) {
    // }

    // constructor(string memory uri_, 
    //     uint256[] memory ids_,
    //     uint256[] memory amounts_,
    //     bytes memory data_) ERC1155(uri_) {
        
    //     // _mintBatch(msg.sender, ids_, amounts_, data_);
    //     // ApprovalForAll(msg.sender, address(this), true);
        
    //     mintBatch(ids_, amounts_, data_);
    // }

    // function mintBatch(uint256[] memory ids_, uint256[] memory amounts_, 
    //     bytes memory data_) public onlyOwner() {
    //     _mintBatch(address(this), ids_, amounts_, data_);
    // }
    
    constructor(string memory uri_, uint256[] memory resultIds_) ERC1155(uri_) {
        addResultIds(resultIds_);
        status = State.OPEN;
    }

    function addResultIds(uint256[] memory resultIds_) public onlyOwner() {
        for (uint i = 0; i < resultIds_.length; i++) {
            resultsIds[resultIds_[i]] = true;
            resultsIdsKeys.push(resultIds_[i]);
        }
    }

    // Bet
    function bet(uint256 resultId_) public payable returns (bool) {
        require(status == State.OPEN, "Betting: Event not open");
        // TODO require a minimum bet amount

        // transfer & register the bet
        // safeTransferFrom(address(this), msg.sender, resultId_, msg.value, "0x0");

        // another way
        require(resultsIds[resultId_], "Betting: This result does not exist!");
        _mint(msg.sender, resultId_, msg.value, "");

        return true;
    }
    
    function batchBet(uint256[] memory resultIds_, uint256[] memory amounts) public payable returns (bool) {
        require(status == State.OPEN, "Betting: Event not open");
        // TODO require a minimum total bet amounts

        uint amountsTotal = 0;
        for (uint i = 0; i < amounts.length; i++) {
            amountsTotal += amounts[i];
        }
        require(msg.value >= amountsTotal, "Betting: Insufficient value to cover bets");

        // safeBatchTransferFrom(address(this), msg.sender, resultIds_, amounts, "0x0");
        
        // another way
        for (uint i = 0; i < resultIds_.length; i++) {
            require(resultsIds[resultIds_[i]], "Betting: This result does not exist!");
        }
        _mintBatch(msg.sender, resultIds_, amounts, "");
    
        return true;
    }

    function lock() external {
        status = State.LOCKED;
    }

    // Store the event result
    function store(uint256 resultId_) public returns (bool) {
        // Require accessControl
        require(exists(resultId_), "Betting: This result does not exist!");

        finalResult = resultId_;
        status = State.ENDED;

        return true;
    }

    function totalBetsOnEvent() public view returns (uint256) {
        uint _totalBetsOnEvent = 0;
        for (uint i = 0; i < resultsIdsKeys.length; i++) {
            _totalBetsOnEvent += totalSupply(resultsIdsKeys[i]);
        }

        return _totalBetsOnEvent;
    }

    /// @notice Compute potential winnings
    /// @dev Compute potential or final winnings
    /// @param resultId_ result id
    /// @return the potential or final winnings of msg.sender for a result id
    function computeWinnings(uint256 resultId_) public view returns (uint256) {
        require(totalSupply(resultId_) != 0, "Betting: no bets on event");
        // winnings = balanceOf(msg.sender, resultId_) * (1 + total_bets_on_resultId_ / total_bets_on_event)
        
        uint256 winnings = balanceOf(msg.sender, resultId_) * totalBetsOnEvent() / totalSupply(resultId_);
        winnings *= (10000 - fee)/10000;

        return winnings;
    }
    
    // claim / cash out single Id
    function cashOut(uint256 resultId_) public returns (bool) {
        require(balanceOf(msg.sender, resultId_) > 0, "Betting: You didn't bet on this");
        require(status == State.ENDED, "Betting: Event not over");
        require(resultId_ == finalResult, "Betting: No winnings");

        uint winnings = computeWinnings(resultId_);

        payable(msg.sender).transfer(winnings);

        return true;
    }

    // TODO
    // cash out multiple ids / all results for msg.sender
    function batchCashOut(uint256[] memory resultIds_) public returns (bool) {
        
    }

    // withdraw : not production code !
    function withdraw(uint256 value_) public onlyOwner() {
        // transfer the fees value TODO
        payable(msg.sender).transfer(value_);
    }

    // function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, ERC1155Receiver) returns (bool) {
    //     return
    //         interfaceId == type(IERC1155).interfaceId ||
    //         interfaceId == type(ERC1155Receiver).interfaceId ||
    //         super.supportsInterface(interfaceId);
    // }
}