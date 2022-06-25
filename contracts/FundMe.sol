//SPDX-License-Identifier: Unlicense
//Pragma
pragma solidity ^0.8.0;

//Imports
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

//Error Codes
error FundMe__NotOwner();

//Interfaces, Libraries, Contracts

/** @title A contract for crowd funding
 *  @author Patrick Collins
 *  @notice This contract is to demo a sample funding contract
 *  @dev This implements price feeds as our library
 */
contract FundMe {
    //Type Declarations
    using PriceConverter for uint256;

    //State variables
    mapping(address => uint256) private s_addressToAmountFunded;
    address[] private s_funders;

    //Could we make athis constant?
    uint256 public constant MINIMUM_USD = 50 * 10**18;
    //uint256 public constant MINIMUM_USD = 0;
    address private immutable i_owner;

    AggregatorV3Interface private s_priceFeed;

    //Modifiers
    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    //All the functions
    //Functions Order:
    // constructor
    // receive
    // fallback
    // external
    // public
    // internal
    // private
    // view/pure

    //Constructor
    constructor(address priceFeed) {
        s_priceFeed = AggregatorV3Interface(priceFeed);
        i_owner = msg.sender;
    }

    //@notice Funds our contract based on the ETH/USD price

    /** @notice This function funds this contract
     *  @dev This implements price feeds as our library
     */
    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "You need to spend more ETH!"
        );

        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    //retirar fondos
    function withdraw() public payable onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        s_funders = new address[](0);

        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success);
    }

    //
    function cheaperWithdraw() public payable onlyOwner {
        address[] memory funders = s_funders;

        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        s_funders = new address[](0);

        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success);
    }

    //More Methods
    function getAddressToAmountFunded(address fundingAddress)
        public
        view
        returns (uint256)
    {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
