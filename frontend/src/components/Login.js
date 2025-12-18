import React, { useState } from 'react';
import { api, saveAccessToken, setAccessToken } from '../api';

function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    const response = await api.post('/api/users/login', { email, password });
    const token = response?.data?.accessToken;
    if (token) {
      saveAccessToken(token);
      setAccessToken(token);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input type='email' value={email} onChange={(e) => setEmail(e.target.value)} placeholder='Email' required />
      <input type='password' value={password} onChange={(e) => setPassword(e.target.value)} placeholder='Password' required />
      <button type='submit'>Login</button>
    </form>
  );
}

export default Login;