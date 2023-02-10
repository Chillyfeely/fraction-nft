// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Shares is ERC20{
    uint _sharesCount = 100;
    uint public _sharePrice;

    uint buyOut = _sharePrice * 100; //100 refers to total amount of shares
    mapping(address => uint) public addressToSharesBought;
    address payable[] public shareHolders;
    bool isFundingOver = false;
    
    
    constructor(string memory _name, string memory _symbol, address _owner, uint sharePrice) ERC20(_name, _symbol){
        _mint(_owner, _sharesCount);
        _sharePrice = sharePrice;
    }

    function buyShare(address payable _to, uint _amount) public payable{
        require(_amount<=_sharesCount,"insufficient shares");
        require(_amount*_sharePrice==msg.value,"insufficient payment");
        transfer(_to, _amount);
        _sharesCount -= _amount;

        addressToSharesBought[msg.sender] += msg.value;
        shareHolders.push(msg.sender);
    }

    function sellShare(address payable _to, uint _amount) public payable{
        require(balanceOf(_to)>0,"You do not have share");
        (bool success, )= _to.call{value:_amount*_sharePrice}("");
        require(success,"call failed");
        _sharesCount += _amount;

    }

    /*
    *total payment of user
    */
    function totalPaymentOf(address payable shareHolders) public view returns(uint){
        return addressToSharesBought[shareHolders];
    }

    /*
     * left shares in the contract
     */
    function leftShares() public view returns(uint){//ALready written in r21
        return _sharesCount;
    } 

    /*
     * redeem nft msg.sender and send left shares to the holders.
     */
    function redeem(address payable _potentialBuyerOfNFT, uint _paymentAmount) public payable{

        _potentialBuyerOfNFT = msg.sender;
        _paymentAmount = msg.value;
        uint sharesThatBuyerHave = addressToSharesBought[_potentialBuyerOfNFT];
        uint acquisitionPrice = buyOut - (sharesThatBuyerHave * _sharePrice);

        require(_paymentAmount >= acquisitionPrice, "Insufficient payment amount"); 
        uint256 _changeAmount = _paymentAmount - acquisitionPrice;

        if (_changeAmount > 0){
            transfer(_potentialBuyerOfNFT, _changeAmount);
        }

        require(_potentialBuyerOfNFT.transfer(tokenID), "NFT transfer failed")
        isFundingOver = true; 
    } 

    function sendPaymentBack(address payable _holder) public payable{

    require(isFundingOver, "Funding has not ended yet")
    _holder = msg.sender;

    require(addressToSharesBought[_holder] > 0, "Address is not a valid share holder");
    uint sharesBought = addressToSharesBought[_holder];
    uint repaymentAmount = sharesBought * sharePrice;

    transferFrom(_holder, address(this), sharesBought);
    
    addressToSharesBought[_holder] = 0;
    }
}