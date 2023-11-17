// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Tracking is AccessControl, Ownable {
  bytes32 public constant TRACKER_ROLE = keccak256("TRACKER_ROLE");

  uint public constant MIN_ORDER_AMOUNT = 1 * 10 ** 6;
  uint public constant SHIPPING_FEE = 8 * 10 ** 6;

  IERC20 private token;

  enum TrackingStatus { Ordered, Shipped, Delivered, Refunded, Cancelled }

  event TrackingStatusUpdated(
    string orderId, 
    TrackingStatus from, 
    TrackingStatus to
  );

  struct OrderTracking {
    address sender;
    uint orderAmount;
    uint createdAt;
    uint expiredAt;
    Package package;
    TrackingStatus status;
  }

  struct Package {
    string productName;
    uint width;
    uint height;
    uint length;
    uint weight;
  }

  mapping (string orderId => OrderTracking) orderTracking;

  constructor(address _token) {
    token = IERC20(_token);

    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(TRACKER_ROLE, msg.sender);
  }

  function getOrderTracking(string calldata orderId) public view returns (OrderTracking memory) {
    return orderTracking[orderId];
  }

  function createOrderTrackingFor(
    address sender,
    string calldata orderId,
    uint orderAmount,
    string calldata productName,
    uint width,
    uint height,
    uint length,
    uint weight
  ) public onlyRole(TRACKER_ROLE) {
    _createOrderTrackingFor(
      sender,
      orderId,
      orderAmount,
      productName,
      width,
      height,
      length,
      weight
    );
  }

  function createOrderTracking(
    string calldata orderId,
    uint orderAmount,
    string calldata productName,
    uint width,
    uint height,
    uint length,
    uint weight
  ) public {
    _createOrderTrackingFor(
      msg.sender,
      orderId,
      orderAmount,
      productName,
      width,
      height,
      length,
      weight
    );
  }

  modifier checkTrackingStatus(string calldata orderId, TrackingStatus status) {
    OrderTracking memory order = orderTracking[orderId];

    require(order.createdAt > 0, "Tracking does not exist");
    require(order.status != status, "Tracking status is the same");
    require(order.status != TrackingStatus.Delivered, "The order has already been delivered");
    require(order.status != TrackingStatus.Refunded, "The order has already been refunded");
    require(order.status != TrackingStatus.Cancelled, "The shipping fee has already been refunded");
    
    // Is valid tracking status
    require(
      status == TrackingStatus.Shipped ||
      status == TrackingStatus.Delivered ||
      status == TrackingStatus.Refunded ||
      status == TrackingStatus.Cancelled,
      "Invalid tracking status"
    );

    if (order.status == TrackingStatus.Ordered && status == TrackingStatus.Delivered) {
      revert("The order has not been shipped yet");
    }

    _;
  }

  function updateTrackingStatus(
    string calldata orderId,
    TrackingStatus status
  ) public onlyRole(TRACKER_ROLE) checkTrackingStatus(orderId, status) {
    OrderTracking storage order = orderTracking[orderId];

    if (status == TrackingStatus.Refunded) {
      SafeERC20.safeTransfer(token, order.sender, order.orderAmount + SHIPPING_FEE);
    } else if (status == TrackingStatus.Cancelled) {
      SafeERC20.safeTransfer(token, order.sender, SHIPPING_FEE);
    } else if (status == TrackingStatus.Delivered) {
      SafeERC20.safeTransfer(token, owner(), order.orderAmount + SHIPPING_FEE);
    }

    emit TrackingStatusUpdated(orderId, order.status, status);

    // Update tracking status
    order.status = status;
  }

  function _createOrderTrackingFor(
    address sender,
    string calldata orderId,
    uint orderAmount,
    string calldata productName,
    uint width,
    uint height,
    uint length,
    uint weight
  ) private {
    require(sender != address(0), "Sender address is required");
    require(bytes(orderId).length > 0, "Order ID is required");
    require(orderAmount > MIN_ORDER_AMOUNT, "Order amount must be greater than 1");
    require(bytes(productName).length > 0, "Product name is required");
    require(width > 0, "Width must be greater than 0");
    require(height > 0, "Height must be greater than 0");
    require(length > 0, "Length amount must be greater than 0");
    require(weight > 0, "Weight amount must be greater than 0");
    require(orderTracking[orderId].createdAt == 0, "Track already exists");
    require(token.balanceOf(owner()) >= orderAmount, "Insufficient balance to pay package insurance");
    require(token.balanceOf(sender) >= SHIPPING_FEE, "Insufficient balance to pay shipping fee");
    require(token.allowance(sender, address(this)) >= SHIPPING_FEE, "Insufficient allowance to pay shipping fee");

    SafeERC20.safeTransferFrom(token, owner(), address(this), orderAmount);
    SafeERC20.safeTransferFrom(token, sender, address(this), SHIPPING_FEE);

    orderTracking[orderId] = OrderTracking({
      sender: sender,
      orderAmount: orderAmount,
      createdAt: block.timestamp,
      expiredAt: block.timestamp + 5 days,
      package: Package({
        width: width,
        height: height,
        length: length,
        weight: weight,
        productName: productName
      }),
      status: TrackingStatus.Ordered
    });
  }
}