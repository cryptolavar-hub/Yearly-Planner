/**
 * Copyright © 2024-2025 Q2O - Quick to Objective AI Development Platform
 * Created by: CryptoLavar (Project Architect & Developer) cryptolavar@gmail.com
 *
 * Role: Nova (Frontend Engineer - React)
 */

import React, { useEffect, useState } from 'react';
import { BrowserRouter as Router, Route, Switch, Redirect } from 'react-router-dom';
import ErrorBoundary from './components/ErrorBoundary';
import Home from './components/Home';
import Login from './components/Login';
import Register from './components/Register';
import { loadAccessToken, setAccessToken } from './api';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = loadAccessToken();
    if (token) {
      setAccessToken(token);
      setIsAuthenticated(true);
    }
    setLoading(false);
  }, []);

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-gray-600">Loading...</div>
      </div>
    );
  }

  return (
    <ErrorBoundary>
      <Router>
        <Switch>
          <Route
            path="/login"
            render={() => (isAuthenticated ? <Redirect to="/" /> : <Login onLogin={() => setIsAuthenticated(true)} />)}
          />
          <Route path="/register" component={Register} />
          <Route
            path="/"
            render={() => (isAuthenticated ? <Home /> : <Redirect to="/login" />)}
          />
        </Switch>
      </Router>
    </ErrorBoundary>
  );
}

export default App;