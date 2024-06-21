// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EduPlatformToken is ERC20, Ownable {
    struct Course {
        string name;
        address teacher;
        uint256 price;
        bool isActive;
        uint256 views;
        uint256 likes;
    }

    struct Video {
        string title;
        string description;
        string ipfsHash; // 儲存影片的IPFS hash
        address uploader;
    }

    mapping(address => bool) public kycVerified;
    mapping(address => uint256) public teacherEarnings;
    mapping(uint256 => Course) public courses;
    mapping(address => mapping(uint256 => bool)) public studentPurchases;
    mapping(string => Video) private videos;

    uint256 public nextCourseId;
    uint256 public videoCount;

    event EtherReceived(address indexed from, uint256 amount);
    event CourseAdded(uint256 indexed courseId, string name, address indexed teacher);
    event VideoUploaded(uint256 indexed videoId, string title, address indexed uploader);

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
    function addCourse(string memory _name, uint256 price) public {
        require(kycVerified[msg.sender], "Teacher must be KYC verified");
        courses[nextCourseId] = Course({
            name: _name,
            teacher: msg.sender,
            price: price,
            isActive: true,
            views: 0,
            likes: 0
        });
        emit CourseAdded(nextCourseId, _name, msg.sender);
        nextCourseId++;
    }

    // Function to upload a video
    function uploadVideo(string memory _title, string memory _description, string memory _ipfsHash) public {
        require(kycVerified[msg.sender], "Uploader must be KYC verified");
        videos[_ipfsHash] = Video({
            title: _title,
            description: _description,
            ipfsHash: _ipfsHash,
            uploader: msg.sender
        });
        videoCount++;
        emit VideoUploaded(videoCount, _title, msg.sender);
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

    // Function to get a video by IPFS hash
    function getVideo(string memory _ipfsHash) public view returns (string memory, string memory, string memory, address) {
        require(bytes(videos[_ipfsHash].ipfsHash).length != 0, "Video does not exist");
        Video memory video = videos[_ipfsHash];
        return (video.title, video.description, video.ipfsHash, video.uploader);
    }

    // Function to get course details
    function getCourse(uint256 courseId) public view returns (string memory, address, uint256, bool, uint256, uint256) {
        Course storage course = courses[courseId];
        return (course.name, course.teacher, course.price, course.isActive, course.views, course.likes);
    }
}
