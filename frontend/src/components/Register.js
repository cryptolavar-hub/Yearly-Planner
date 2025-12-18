import React, { useState } from 'react';
import { api } from '../api';

function Register() {
  const [username, setUsername] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    await api.post('/api/users/register', { username, email, password });
  };

  return (
    <form onSubmit={handleSubmit}>
      <input type='text' value={username} onChange={(e) => setUsername(e.target.value)} placeholder='Username' required />
      <input type='email' value={email} onChange={(e) => setEmail(e.target.value)} placeholder='Email' required />
      <input type='password' value={password} onChange={(e) => setPassword(e.target.value)} placeholder='Password' required />
      <button type='submit'>Register</button>
    </form>
  );
}

export default Register;