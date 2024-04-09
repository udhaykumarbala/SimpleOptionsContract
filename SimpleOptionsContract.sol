// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleOptionsContract {
    address public writer;
    address public holder;
    uint public strikePrice;
    uint public premium;
    uint public expiration;
    bool public optionExercised = false;
    bool public premiumPaid = false;

    // The constructor initializes the contract with the option details.
    constructor(
        uint _strikePrice,
        uint _premium,
        uint _expiration,
        address _holder
    ) {
        writer = msg.sender;
        strikePrice = _strikePrice;
        premium = _premium;
        expiration = block.timestamp + _expiration;
        holder = _holder;
    }

    // Pay the premium to buy the option.
    function payPremium() external payable {
        require(msg.sender == holder, "Only the option holder can pay the premium.");
        require(msg.value == premium, "Incorrect premium amount.");
        require(block.timestamp < expiration, "Option has expired.");
        require(!premiumPaid, "Premium already paid.");
        premiumPaid = true;
    }

    // Exercise the option to buy the asset at the strike price.
    function exerciseOption() external payable {
        require(msg.sender == holder, "Only the option holder can exercise the option.");
        require(premiumPaid, "Premium has not been paid.");
        require(!optionExercised, "Option already exercised.");
        require(block.timestamp <= expiration, "Option has expired.");
        require(msg.value == strikePrice, "Incorrect strike price amount.");

        // In a real contract, transfer the asset from writer to holder here.
        // For simplicity, we're just setting the option as exercised.
        optionExercised = true;

        // Send the strike price to the writer.
        payable(writer).transfer(msg.value);
    }

    // Allow the writer to withdraw the premium after the option is either exercised or expired.
    function withdrawPremium() external {
        require(msg.sender == writer, "Only the option writer can withdraw the premium.");
        require(premiumPaid, "Premium has not been paid.");
        require(optionExercised || block.timestamp > expiration, "Option not yet resolved.");
        
        payable(writer).transfer(premium);
    }

    // Check if the option is expired.
    function isExpired() public view returns (bool) {
        return block.timestamp > expiration;
    }
}
