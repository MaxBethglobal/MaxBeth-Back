//SPDX-License-Identifier: Unlicense
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
contract BettingEvent is ERC1155Supply, Ownable {
    
    //mapping(address => mapping(uint256 => uint256)) private _xxxxxxx;
    
    uint256 public finalResult;
    mapping(uint256 => bool) public resultsIds;
    uint256[] public resultsIdsKeys;

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
    }

    function addResultIds(uint256[] memory resultIds_) public onlyOwner() {
        for (uint i = 0; i < resultIds_.length; i++) {
            resultsIds[resultIds_[i]] = true;
            resultsIdsKeys.push(resultIds_[i]);
        }
    }

    // Bet
    function bet(uint256 resultId_) public payable returns (bool) {
        // TODO require bet not locked

        // transfer & register the bet
        // safeTransferFrom(address(this), msg.sender, resultId_, msg.value, "0x0");

        // another way
        require(resultsIds[resultId_], "This result does not exist!");
        _mint(msg.sender, resultId_, msg.value, "");

        return true;
    }
    
    function batchBet(uint256[] memory resultIds_, uint256[] memory amounts) public payable returns (bool) {
        // TODO require bet not locked

        uint amountsTotal = 0;
        for (uint i = 0; i < amounts.length; i++) {
            amountsTotal += amounts[i];
        }
        require(msg.value >= amountsTotal, "Insufficient value to cover bets");

        // safeBatchTransferFrom(address(this), msg.sender, resultIds_, amounts, "0x0");
        
        // another way
        for (uint i = 0; i < resultIds_.length; i++) {
            require(resultsIds[resultIds_[i]], "This result does not exist!");
        }
        _mintBatch(msg.sender, resultIds_, amounts, "");
    
        return true;
    }

    // Store the event result
    //TODO don't allow to bet after storing result (new function: lock before results are known, require that event isn't locked when betting)
    function store(uint256 resultId_) public returns (bool) {
        // Require accessControl
        require(exists(resultId_), "This result does not exist!");

        finalResult = resultId_;
        
        return true;
    }
    
    function totalBetsOnEvent() public view returns (uint256) {
        // TODO write function for this (inside lock bet function)
        uint _totalBetsOnEvent = 0;
        for (uint i = 0; i < resultsIdsKeys.length; i++) {
            _totalBetsOnEvent += totalSupply(resultsIdsKeys[i]);
        }

        return _totalBetsOnEvent;
    }

    function computeWinnings(uint256 resultId_) public view returns (uint256) {
        // TODO 
        //require ! DIV 0
        // winnings = balanceOf(msg.sender, resultId_) * (1 + total_bets_on_resultId_ / total_bets_on_event)

        

        uint256 winnings =  balanceOf(msg.sender, resultId_) * totalBetsOnEvent() / totalSupply(resultId_);
        // winnings = balanceOf(msg.sender, resultId_) * total_bets_on_event / total_bets_on_resultId_;
        // balanceOf(msg.sender, resultId_) * (total_bets_on_resultId + total_loosing_bets) / total_bets_on_resultId_
        // balanceOf(msg.sender, resultId_) * (1 + total_loosing_bets / total_bets_on_resultId_)


        // balanceOf(msg.sender, resultId_) + balanceOf(msg.sender, resultId_) / total_bets_on_resultId * total_loosing_bets
        // balanceOf(msg.sender, resultId_) * (1 + 1 / total_bets_on_resultId * total_loosing_bets)
        // balanceOf(msg.sender, resultId_) * (1 + total_loosing_bets / total_bets_on_resultId )

        return winnings;
    }
    
    // claim / cash out single Id
    function cashOut(uint256 resultId_) public returns (bool) {
        require(balanceOf(msg.sender, resultId_) > 0, "You didn't bet on this");
        
        uint winnings = computeWinnings(resultId_); //to be computed // TODO

        payable(msg.sender).transfer(winnings);

        return true;
    }

    // TODO
    // cash out multiple ids / all results for msg.sender
    function batchCashOut(uint256[] memory resultIds_) public returns (bool) {
        
    }

    // withdraw
    function withdraw(uint256 value_) public onlyOwner() {
        // transfer the value 
        payable(msg.sender).transfer(value_);
    }

    // function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, ERC1155Receiver) returns (bool) {
    //     return
    //         interfaceId == type(IERC1155).interfaceId ||
    //         interfaceId == type(ERC1155Receiver).interfaceId ||
    //         super.supportsInterface(interfaceId);
    // }
}