# EduPlatform 智能合約

EduPlatform是一個基於以太坊的教育平台智能合約，旨在為教師和學生提供一個去中心化的平台，教師可以發布課程，學生可以購買或免費觀看課程。該智能合約使用了OpenZeppelin庫來實現ERC20代幣和合約的所有權管理。


#### addUser
- **描述**: 添加新用戶（教師或學生），自動通過KYC驗證。
- **輸入**: `address _walletAddress` - 用戶的錢包地址。
- **輸出**: 無，但觸發`UserAdded`事件。
- **示例**:
    
    **輸入**:
    ```
    0xUserWalletAddress: 0x1234567890abcdef1234567890abcdef12345678
    ```
    **輸出**:
    ```
    事件 UserAdded(address indexed userAddress)
    ```

### 課程管理

#### addCourse
- **描述**: 添加新課程，只有通過KYC的教師可以添加。
- **輸入**:
    - `string memory _courseName` - 課程名稱。
    - `uint256 price` - 課程價格。
    - `string memory _description` - 課程描述。
    - `bool _isFree` - 課程是否免費。
    - `string memory _ipfsHash` - 課程影片的IPFS哈希（僅在課程免費時填寫）。
- **輸出**: 無，但觸發`CourseAdded`事件。
- **示例**:
    
    **輸入**:
    ```
    _courseName: "Solidity 101"
    price: 1000
    _description: "Learn the basics of Solidity"
    _isFree: false
    _ipfsHash: ""
    ```
    **輸出**:
    ```
    事件 CourseAdded(uint256 indexed courseId, string name, address indexed teacher)
    ```

#### purchaseCourse
- **描述**: 購買課程，非免費課程需要用戶有足夠的代幣餘額。
- **輸入**: `uint256 courseId` - 課程ID。
- **輸出**: 無。
- **示例**:
   
    **輸入**:
    ```
    courseId: 1
    ```
    **輸出**: 
    ```
    User課程列表更新
    ```

#### hasPurchasedCourse
- **描述**: 檢查用戶是否已購買指定課程。
- **輸入**:
    - `address student` - 學生地址。
    - `uint256 courseId` - 課程ID。
- **輸出**: `bool` - 是否已購買。
- **示例**:
    
    **輸入**:
    ```
    student: 0x1234567890abcdef1234567890abcdef12345678
    courseId: 1
    ```
    **輸出**:
    ```
    purchased: true 或 false
    ```

#### recordView
- **描述**: 記錄課程觀看次數。
- **輸入**: `uint256 courseId` - 課程ID。
- **輸出**: 無。
- **示例**:
    
    **輸入**:
    ```
    courseId: 1
    ```
    **輸出**: 
    ```
    課程的觀看次數增加
    ```

#### recordLike
- **描述**: 記錄課程點贊次數。
- **輸入**: `uint256 courseId` - 課程ID。
- **輸出**: 無。
- **示例**:
    
    **輸入**:
    ```
    courseId: 1
    ```
    **輸出**: 
    ```
    課程的點贊次數增加
    ```

### 收入管理

#### distributeEarnings
- **描述**: 向教師分發收入，僅所有者可調用。
- **輸入**:
    - `address teacher` - 教師地址。
    - `uint256 amount` - 分發的收入數量。
- **輸出**: 無。
- **示例**:
    
    **輸入**:
    ```
    teacher: 0x1234567890abcdef1234567890abcdef12345678
    amount: 1000
    ```
    **輸出**: 
    ```
    teacherEarnings更新
    ```

#### distributeIncome
- **描述**: 根據觀看次數和點贊次數計算並分發課程收入，僅所有者可調用。
- **輸入**: `uint256 courseId` - 課程ID。
- **輸出**: 無。
- **示例**:
   
    **輸入**:
    ```
    courseId: 1
    ```
    **輸出**: 
    ```
    分發收入後重置views和likes
    ```

#### getEarnings
- **描述**: 獲取教師的總收入。
- **輸入**: `address teacher` - 教師地址。
- **輸出**: `uint256` - 總收入。
- **示例**:
    
    **輸入**:
    ```
    teacher: 0x1234567890abcdef1234567890abcdef12345678
    ```
    **輸出**:
    ```
    earnings: 1000
    ```

### KYC驗證

#### verifyKYC
- **描述**: 對用戶進行KYC驗證，僅所有者可調用。
- **輸入**: `address user` - 用戶地址。
- **輸出**: 無。
- **示例**:
    
    **輸入**:
    ```
    user: 0x1234567890abcdef1234567890abcdef12345678
    ```
    **輸出**:
    ```
    kycVerified更新
    ```

### 以太幣管理

#### receiveEther
- **描述**: 接收以太幣的函數。
- **輸入**: 無。
- **輸出**: 事件`EtherReceived`。
- **示例**:
    
   **任何以太幣轉入的操作將觸發此函數**
    
    **輸入**:
    ```
    msg.value: 1 ether
    ```
    **輸出**:
    ```
    事件 EtherReceived(address indexed from, uint256 amount)
    ```

#### getBalance
- **描述**: 獲取合約的以太幣餘額。
- **輸入**: 無。
- **輸出**: `uint256` - 合約餘額。
- **示例**:
    
    **輸入**: 無。
    **輸出**:
    ```
    balance: 5 ether
    ```

#### withdrawEther
- **描述**: 提取指定數量的以太幣，僅所有者可調用。
- **輸入**: `uint256 amount` - 提取的以太幣數量。
- **輸出**: 無。
- **示例**:
    
    **輸入**:
    ```
    amount: 1 ether
    ```
    **輸出**:
    ```
    owner的錢包地址接收到1 ether
    ```



