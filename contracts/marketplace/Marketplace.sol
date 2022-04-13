//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol"; //accept more token erc20 standard to payment

contract Marketplace is Ownable {
    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.AddressSet;
    Counters.Counter private _orderIdCount; //variable count id order

    struct Order {
        address seller;
        address buyer;
        uint256 idToken;
        address paymentToken; //address nft
        uint256 price;
    }

    IERC721 public immutable nftContract;
    mapping(uint256 => Order) orders; //mapping idorder=>order

    //about fee
    uint256 public feeDecimal;
    uint256 public feeRate;
    address public feeRecipient; //address receive fee recipient
    EnumerableSet.AddressSet private _supportedPaymentTokens; //list all token can payment

    // indexed to map 2 variable in 2 or more block
    event OrderAdded(
        uint256 indexed orderId,
        address indexed seller,
        uint256 indexed tokenId,
        address paymentToken,
        uint256 price
    );
    event OrderCancelled(uint256 indexed orderId);
    event OrderMatched(
        uint256 indexed orderId,
        address indexed seller,
        address indexed buyer,
        uint256 tokenId,
        address paymentToken,
        uint256 price
    );
    event FeeRateUpdated(uint256 feeDecimal, uint256 feeRate);

    constructor(
        address nftAddress_,
        uint256 feeDecimal_,
        uint256 feeRate_,
        address feeRecipient_
    ) {
        require(
            nftAddress_ != address(0),
            "NFT Marketplace: nftAddress_ is zero address"
        );
        require(
            feeRecipient_ != address(0),
            "NFT Marketplace: feeRecipient_ is zero address"
        );

        nftContract = IERC721(nftAddress_);
        _updateFeeRate(feeDecimal_, feeRate_);
        _updateFeeRecipient(feeRecipient_);
        _orderIdCount.increment();
    }

    function _updateFeeRecipient(address feeRecipient_) internal {
        require(
            feeRecipient_ != address(0),
            "NFT Marketplace: feeRecipient_ is zero address"
        );
        feeRecipient = feeRecipient_;
    }

    function updateFeeRecipient(address feeRecipient_) external onlyOwner {
        feeRecipient = feeRecipient_;
    }

    function _updateFeeRate(uint256 feeDecimal_, uint256 feeRate_) internal {
        require(
            feeRate_ < 10**(feeDecimal_ + 2),
            "NFT Marketplace: bad fee rate"
        );
        feeDecimal = feeDecimal_;
        feeRate = feeRate_;
        emit FeeRateUpdated(feeDecimal_, feeRate_);
    }

    function updateFeeRate(uint256 feeDecimal_, uint256 feeRate_)
        external
        onlyOwner
    {
        _updateFeeRate(feeDecimal_, feeRate_);
    }

    function _calculateFee(uint256 orderId_) private view returns (uint256) {
        Order storage _order = orders[orderId_];
        if (feeRate == 0) {
            return 0;
        }
        return (feeRate * _order.price) / 10**(feeDecimal + 2);

        //
    }

    function isSeller(uint256 orderId_, address seller_)
        public
        view
        returns (bool)
    {
        return orders[orderId_].seller == seller_;
    }

    function addPaymentToken(address paymentToken_) external onlyOwner {
        require(
            paymentToken_ != address(0),
            "NFT Marketplace: paymentToken_ is zero address"
        );
        require(
            _supportedPaymentTokens.add(paymentToken_),
            "NFT Marketplace: alrealy supported"
        );
    }

    function isPaymentTokenSupported(address paymentToken_)
        public
        view
        onlyOwner
        returns (bool)
    {
        return _supportedPaymentTokens.contains(paymentToken_);
    }

    modifier onlySupportedPaymentToken(address paymentToken_) {
        require(
            isPaymentTokenSupported(paymentToken_),
            "NFT Marketplace: Unsupport payment token."
        );
        _;
    }

    function addOrder(
        uint256 tokenId_,
        address paymentToken_,
        uint256 price_
    ) public onlySupportedPaymentToken(paymentToken_) {
        uint256 _orderId = _orderIdCount.current();

        orders[_orderId] = Order(
            _msgSender(),
            address(0),
            tokenId_,
            paymentToken_,
            price_
        );
        nftContract.transferFrom(_msgSender(), address(0), tokenId_);
        emit OrderAdded(
            _orderId,
            _msgSender(),
            tokenId_,
            paymentToken_,
            price_
        );
    }
}
