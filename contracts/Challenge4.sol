/*The given task is as follows:
Minting new tokens: The platform should be able to create new tokens and distribute them to players as rewards. Only the owner can mint tokens.
Transferring tokens: Players should be able to transfer their tokens to others.
Redeeming tokens: Players should be able to redeem their tokens for items in the in-game store.
Checking token balance: Players should be able to check their token balance at any time.
Burning tokens: Anyone should be able to burn tokens, that they own, that are no longer needed.
*/


// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DegenToken is ERC20, ERC20Burnable, Ownable {
    struct Item {
        string name;
        uint256 price;
    }
    // creates a mapping to store information about different items, where each item is identified by a unique ID
    mapping(uint256 => Item) public items;
    // creates a mapping to track which items have been redeemed by which users
    mapping(address => mapping(uint256 => bool)) public redeemedItems;
    // We are declaring a event here which is the way to log and record specific actions within the contract
    event ItemRedeemed(address indexed player, uint256 itemId);

    // Here we are declared a constructor and mapping the items to the respective item id's 
    constructor() ERC20("DegenToken", "DGN") {
        // Add some example items
        items[1] = Item("Laptop Backpack", 10);
        items[2] = Item("Cofee Mug", 20);
        items[3] = Item("Cap", 50);
    }
    // Function used to mint tokens 
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
    // Function used to transfer the tokens and it also checks the enter value should be greater than zero 
    function transfer(address to, uint256 amount) public override returns (bool) {
        require(amount > 0, "Amount should be greater than 0");
        _transfer(_msgSender(), to, amount);
        return true;
    }
    // Function used to redeem the prizes 
    function redeem(uint256 itemId) external {
        require(itemId > 0, "Invalid item ID.");
        require(redeemedItems[_msgSender()][itemId] == false, "Item already redeemed.");

        Item storage item = items[itemId];
        require(item.price > 0, "Item not found.");

        uint256 itemPrice = item.price;
        require(balanceOf(_msgSender()) >= itemPrice, "Insufficient balance.");

        // Transfer tokens from the sender to the contract
        _transfer(_msgSender(), address(this), itemPrice);

        // Mark the item as redeemed
        redeemedItems[_msgSender()][itemId] = true;

        emit ItemRedeemed(_msgSender(), itemId);
    }
    // returns the balance of tokens held by the specified address
    function getBalance(address account) public view returns (uint256) {
        return balanceOf(account);
    }
    // This function allows destroying the required amount of tokens owned by the caller
     function burn(address _address, uint256 value) public {
    if (balanceOf(_address) >= value) {
        _burn(_address, value);
    }
}
}
