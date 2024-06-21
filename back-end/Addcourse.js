import React, { useContext, useState } from 'react';
import Web3Context from '../context/Web3Context';
import { parseUnits } from 'ethers'; // ethers.js v6 不再需要单独导入 utils

const AddCourse = () => {
  const { contract } = useContext(Web3Context);
  const [courseName, setCourseName] = useState('');
  const [price, setPrice] = useState('');
  const [description, setDescription] = useState('');
  const [isFree, setIsFree] = useState(false);
  const [ipfsHash, setIpfsHash] = useState('');

  const addCourse = async () => {
    if (!contract) {
      console.log('Contract not loaded');
      return;
    }

    try {
      const tx = await contract.addCourse(courseName, parseUnits(price, 'ether'), description, isFree, ipfsHash);
      await tx.wait();
      alert('Course added successfully!');
    } catch (error) {
      console.error('Error adding course:', error);
    }
  };

  return (
    <div>
      <h2>Add Course</h2>
      <form onSubmit={(e) => { e.preventDefault(); addCourse(); }}>
        <div>
          <label>Course Name:</label>
          <input type="text" value={courseName} onChange={(e) => setCourseName(e.target.value)} required />
        </div>
        <div>
          <label>Price:</label>
          <input type="text" value={price} onChange={(e) => setPrice(e.target.value)} required />
        </div>
        <div>
          <label>Description:</label>
          <textarea value={description} onChange={(e) => setDescription(e.target.value)} required></textarea>
        </div>
        <div>
          <label>Is Free:</label>
          <input type="checkbox" checked={isFree} onChange={(e) => setIsFree(e.target.checked)} />
        </div>
        <div>
          <label>IPFS Hash (if free):</label>
          <input type="text" value={ipfsHash} onChange={(e) => setIpfsHash(e.target.value)} />
        </div>
        <button type="submit">Add Course</button>
      </form>
    </div>
  );
};

export default AddCourse;
