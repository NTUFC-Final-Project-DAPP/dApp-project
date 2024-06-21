// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EduPlatformToken is ERC20, Ownable {
    struct Course {
        address teacher;
        uint256 price;
        bool isActive;
        uint256 views;
        uint256 likes;
    }

    mapping(address => bool) public kycVerified;
    mapping(address => uint256) public teacherEarnings;
    mapping(uint256 => Course) public courses;
    mapping(address => mapping(uint256 => bool)) public studentPurchases;

    uint256 public nextCourseId;
    event EtherReceived(address indexed from, uint256 amount);
    constructor(address initialOwner) ERC20("EduPlatformToken", "EPT") Ownable(initialOwner) {
        _mint(msg.sender, 1000000 * 10 ** decimals()); // Initial supply of 1,000,000 tokens
    }

    // KYC verification function
    function verifyKYC(address user) public onlyOwner {
        kycVerified[user] = true;
    }

    // Function to distribute earnings to teachers
    function distributeEarnings(address teacher, uint256 amount) public onlyOwner {
        require(kycVerified[teacher], "Teacher must be KYC verified");
        _transfer(owner(), teacher, amount);
        teacherEarnings[teacher] += amount;
    }

    // Function to track earnings
    function getEarnings(address teacher) public view returns (uint256) {
        return teacherEarnings[teacher];
    }

    // Function to add a course
    function addCourse(uint256 price) public {
        require(kycVerified[msg.sender], "Teacher must be KYC verified");
        courses[nextCourseId] = Course({
            teacher: msg.sender,
            price: price,
            isActive: true,
            views: 0,
            likes: 0
        });
        nextCourseId++;
    }

     // Function to purchase a course
    function purchaseCourse(uint256 courseId) public {
        Course storage course = courses[courseId];
        require(course.isActive, "Course is not active");
        require(balanceOf(msg.sender) >= course.price, "Insufficient balance");

        _transfer(msg.sender, course.teacher, course.price);
        teacherEarnings[course.teacher] += course.price;
        studentPurchases[msg.sender][courseId] = true;
    }

    // Function to check if a student has purchased a course
    function hasPurchasedCourse(address student, uint256 courseId) public view returns (bool) {
        return studentPurchases[student][courseId];
    }

    // Function to record a view
    function recordView(uint256 courseId) public {
        Course storage course = courses[courseId];
        require(course.isActive, "Course is not active");
        course.views += 1;
    }

    // Function to record a like
    function recordLike(uint256 courseId) public {
        Course storage course = courses[courseId];
        require(course.isActive, "Course is not active");
        course.likes += 1;
    }

    // Function to calculate and distribute income to a teacher based on views and likes
    function distributeIncome(uint256 courseId) public onlyOwner {
        Course storage course = courses[courseId];
        require(course.isActive, "Course is not active");

        uint256 income = (course.views * 0.1 ether) + (course.likes * 0.5 ether);
        distributeEarnings(course.teacher, income);

        // Reset views and likes after distribution
        course.views = 0;
        course.likes = 0;
    }
     function receiveEther() public payable {
        emit EtherReceived(msg.sender, msg.value);
    }
    // Function to check the contract's Ether balance
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Withdraw Ether from the contract
    function withdrawEther(uint256 amount) public onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");
        payable(owner()).transfer(amount);
    }

    receive() external payable {
        emit EtherReceived(msg.sender, msg.value);
    }
}
