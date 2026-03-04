import React, { useState, useEffect } from 'react'; //Import React and hooks
import axios from 'axios'; //Import Axios for API requests

function App() {
    //State for storing users fetched from backend
    const [users, setUsers] = useState([]);
    //State for the input field to add a new user
    const [name, setName] = useState('');

    //Fetch users when the component mounts
    useEffect(() => {
        axios.get('http://localhost:3000/users', { name });
    }, []); //Empty array means run once on mount

    //Add new user via API
    const addUser = async () => {
        const res = await axios.post('http://localhost:3000/users', { name }); //Post new user
        setUsers([...users, res.data]); //Update user list
        setName(''); //Clear input field
    };

    return (
        <div>
            <h1>Users</h1>
            {/* Input for new user name */}
            <input value={name} onChange={e => setName(e.target.value)} />
            {/* Button to add user */}
            <button onClick={addUser}>Add User</button>
            {/* List all users */}
            <ul>{users.map(user => <li key={user.id}>{user.name}</li>)}</ul>
        </div>
    );
}

export default App; //Export component