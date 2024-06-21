// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract EducationPlatform {
    struct Student {
        string name;
        address walletAddress;
        bool exists;
    }
    
    struct Teacher {
        string name;
        string[] courses; // 老師的課程列表
        address walletAddress;
        bool exists;
    }
    
    struct Course {
        string name;
        address teacher;
        bool exists;
    }
    
    struct Video {
        string title;
        string description;
        string ipfsHash; // 儲存影片的IPFS hash
        address uploader;
    }
    
    mapping (address => Student) private students;
    mapping (address => Teacher) private teachers;
    mapping (string => Course) private courses;
    mapping (string => Video) private videos;
    uint public courseCount;
    uint public videoCount;
    
    event StudentAdded(address indexed studentAddress, string name, address walletAddress);
    event TeacherAdded(address indexed teacherAddress, string name, address walletAddress);
    event CourseAdded(string indexed courseName, address indexed teacher);
    event VideoUploaded(uint indexed videoId, string title, address indexed uploader);
    
    modifier onlyTeacher() {
        require(teachers[msg.sender].exists, "Only teachers can call this function");
        _;
    }
    
    function addStudent(string memory _name,  address _walletAddress) public {
        require(!students[_walletAddress].exists, "Student already exists");
        students[_walletAddress] = Student(_name, _walletAddress, true);
        emit StudentAdded(_walletAddress, _name, _walletAddress);
    }
    
    function addTeacher(string memory _name, address _walletAddress) public {
        require(!teachers[_walletAddress].exists, "Teacher already exists");
        teachers[_walletAddress] = Teacher(_name, new string[](0), _walletAddress, true);
        emit TeacherAdded(_walletAddress, _name, _walletAddress);
    }
    
    function addCourse(string memory _courseName, address _teacherAddress) public onlyTeacher {
        require(teachers[_teacherAddress].exists, "Teacher does not exist");
        require(!courses[_courseName].exists, "Course already exists");
        courses[_courseName] = Course(_courseName, _teacherAddress, true);
        teachers[_teacherAddress].courses.push(_courseName); // 將課程名稱添加到老師的課程列表
        courseCount++;
        emit CourseAdded(_courseName, _teacherAddress);
    }
    
    function uploadVideo(string memory _title, string memory _description, string memory _ipfsHash) public onlyTeacher {
        videos[_ipfsHash] = Video({
            title: _title,
            description: _description,
            ipfsHash: _ipfsHash,
            uploader: msg.sender
        });
        
        videoCount++;
        emit VideoUploaded(videoCount, _title, msg.sender);
    }
    
    function getStudent(address _walletAddress) public view returns (string memory, address) {
        require(students[_walletAddress].exists, "Student does not exist");
        Student memory student = students[_walletAddress];
        return (student.name, student.walletAddress);
    }
    
    function getTeacher(address _walletAddress) public view returns (string memory, address, string[] memory) {
        require(teachers[_walletAddress].exists, "Teacher does not exist");
        Teacher memory teacher = teachers[_walletAddress];
        return (teacher.name, teacher.walletAddress, teacher.courses);
    }
    
    function getCourse(string memory _name) public view returns (string memory, address) {
        require(courses[_name].exists, "Course does not exist");
        Course memory course = courses[_name];
        return (course.name, course.teacher);
    }

    function getVideo(string memory _ipfsHash) public view returns (string memory, string memory, string memory, address) {
        require(bytes(videos[_ipfsHash].ipfsHash).length != 0, "Video does not exist");
        Video memory video = videos[_ipfsHash];
        return (video.title, video.description, video.ipfsHash, video.uploader);
    }
}
// 
