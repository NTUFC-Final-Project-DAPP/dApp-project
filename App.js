import React from 'react';
import { Web3Provider } from './context/Web3Context';
import AddCourse from './components/AddCourse';
import './App.css';

function App() {
  return (
    <Web3Provider>
      <div className="App">
        <header className="App-header">
          <h1>Edu Platform</h1>
          <AddCourse />
        </header>
      </div>
    </Web3Provider>
  );
}

export default App;
