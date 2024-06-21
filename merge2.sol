// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EduPlatform is ERC20, Ownable {
    struct User {
        string[] courses; // 老師和學生的課程列表
        address walletAddress;
        bool exists;
    }
    
    struct Course {
        string name;
        address teacher;
        uint256 price;
        bool isActive;
        uint256 views;
        uint256 likes;
        string description;
        bool isFree; // 是否可以免費觀看
        string ipfsHash; // 儲存影片的IPFS hash，只有在isFree為true時填寫
    }
    
    mapping(address => User) public users;
    mapping(uint256 => Course) public courses;
    mapping(address => mapping(uint256 => bool)) public studentPurchases;
    mapping(address => bool) public kycVerified;
    mapping(address => uint256) public teacherEarnings;

    uint256 public nextCourseId;
    uint256 public userCount;

        event UserAdded(address indexed userAddress);
    event CourseAdded(uint256 indexed courseId, string name, address indexed teacher);
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

    // Function to add a user (teacher or student)
    function addUser(address _walletAddress) public {
        require(!users[_walletAddress].exists, "User already exists");
        string[] memory emptyCourses;
        users[_walletAddress] = User({
            courses: emptyCourses,
            walletAddress: _walletAddress,
            exists: true
        });
        userCount++;
        kycVerified[_walletAddress] = true; // 自动通过KYC认证
        emit UserAdded(_walletAddress);
    }

    // Function to add a course
    function addCourse(string memory _courseName, uint256 price, string memory _description, bool _isFree, string memory _ipfsHash) public {
        require(kycVerified[msg.sender], "Teacher must be KYC verified");
        string memory ipfsHashToSave = "";
        if (_isFree) {
            ipfsHashToSave = _ipfsHash;
        }
        courses[nextCourseId] = Course({
            name: _courseName,
            teacher: msg.sender,
            price: price,
            isActive: true,
            views: 0,
            likes: 0,
            description: _description,
            isFree: _isFree,
            ipfsHash: ipfsHashToSave
        });
        users[msg.sender].courses.push(_courseName); // 将课程名称添加到用户的课程列表
        emit CourseAdded(nextCourseId, _courseName, msg.sender);
        nextCourseId++;
    }

    // Function to purchase a course
    function purchaseCourse(uint256 courseId) public {
        Course storage course = courses[courseId];
        require(course.isActive, "Course is not active");
        require(!course.isFree, "Course is free to watch");
        require(balanceOf(msg.sender) >= course.price, "Insufficient balance");

        _transfer(msg.sender, course.teacher, course.price);
        teacherEarnings[course.teacher] += course.price;
        studentPurchases[msg.sender][courseId] = true;
        users[msg.sender].courses.push(course.name); // 将购买的课程名称添加到用户的课程列表
    }

    // Function to check if a student has purchased a course
    function hasPurchasedCourse(address student, uint256 courseId) public view returns (bool) {
        Course storage course = courses[courseId];
        if (course.isFree) {
            return true;
        }
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

    // Function to get user details
    function getUser(address _walletAddress) public view returns (address, string[] memory) {
        require(users[_walletAddress].exists, "User does not exist");
        User memory user = users[_walletAddress];
        return (user.walletAddress, user.courses);
    }

    // Function to get course details
    function getCourse(uint256 courseId) public view returns (string memory, address, uint256, bool, uint256, uint256, string memory, bool, string memory) {
        Course storage course = courses[courseId];
        return (course.name, course.teacher, course.price, course.isActive, course.views, course.likes, course.description, course.isFree, course.ipfsHash);
    }
}
