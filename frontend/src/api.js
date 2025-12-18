/**
 * Copyright © 2024-2025 Q2O - Quick to Objective AI Development Platform
 * Created by: CryptoLavar (Project Architect & Developer) cryptolavar@gmail.com
 *
 * Role: Nova (Frontend Engineer - React)
 */

import axios from 'axios';

export const api = axios.create({
  baseURL: process.env.REACT_APP_API_BASE_URL || '',
  withCredentials: true,
});

export function setAccessToken(token) {
  if (token) {
    api.defaults.headers.common.Authorization = `Bearer ${token}`;
  } else {
    delete api.defaults.headers.common.Authorization;
  }
}

export function loadAccessToken() {
  try {
    return localStorage.getItem('access_token');
  } catch {
    return null;
  }
}

export function saveAccessToken(token) {
  try {
    if (!token) localStorage.removeItem('access_token');
    else localStorage.setItem('access_token', token);
  } catch {
    // ignore storage errors
  }
}


