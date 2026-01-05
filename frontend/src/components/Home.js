/**
 * Copyright © 2024-2025 Q2O - Quick to Objective AI Development Platform
 * Created by: CryptoLavar (Project Architect & Developer) cryptolavar@gmail.com
 *
 * Role: Nova (Frontend Engineer - React)
 */

import React, { useState, useEffect } from 'react';
import { useHistory } from 'react-router-dom';
import { api, setAccessToken, saveAccessToken } from '../api';

function Home() {
  const history = useHistory();
  const [tasks, setTasks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [newTaskTitle, setNewTaskTitle] = useState('');
  const [newTaskDescription, setNewTaskDescription] = useState('');
  const [creating, setCreating] = useState(false);
  const [filter, setFilter] = useState('all');

  useEffect(() => {
    loadTasks();
  }, [filter]);

  const loadTasks = async () => {
    try {
      setLoading(true);
      setError('');
      const params = filter !== 'all' ? { completed: filter === 'completed' ? 'true' : 'false' } : {};
      const response = await api.get('/api/tasks', { params });
      setTasks(response.data.tasks || []);
    } catch (err) {
      if (err.response?.status === 401) {
        setAccessToken(null);
        saveAccessToken(null);
        history.push('/login');
      } else {
        setError('Failed to load tasks. Please try again.');
      }
    } finally {
      setLoading(false);
    }
  };

  const handleCreateTask = async (e) => {
    e.preventDefault();
    if (!newTaskTitle.trim()) return;

    try {
      setCreating(true);
      setError('');
      const response = await api.post('/api/tasks', {
        title: newTaskTitle,
        description: newTaskDescription,
      });
      setTasks([response.data.task, ...tasks]);
      setNewTaskTitle('');
      setNewTaskDescription('');
    } catch (err) {
      if (err.response?.status === 401) {
        setAccessToken(null);
        saveAccessToken(null);
        history.push('/login');
      } else {
        setError('Failed to create task. Please try again.');
      }
    } finally {
      setCreating(false);
    }
  };

  const handleToggleComplete = async (taskId, currentStatus) => {
    try {
      const response = await api.put(`/api/tasks/${taskId}`, {
        completed: !currentStatus,
      });
      setTasks(tasks.map((task) => (task._id === taskId ? response.data.task : task)));
    } catch (err) {
      if (err.response?.status === 401) {
        setAccessToken(null);
        saveAccessToken(null);
        history.push('/login');
      } else {
        setError('Failed to update task. Please try again.');
      }
    }
  };

  const handleDeleteTask = async (taskId) => {
    if (!window.confirm('Are you sure you want to delete this task?')) return;

    try {
      await api.delete(`/api/tasks/${taskId}`);
      setTasks(tasks.filter((task) => task._id !== taskId));
    } catch (err) {
      if (err.response?.status === 401) {
        setAccessToken(null);
        saveAccessToken(null);
        history.push('/login');
      } else {
        setError('Failed to delete task. Please try again.');
      }
    }
  };

  const handleLogout = async () => {
    try {
      await api.post('/api/users/logout');
    } catch (err) {
      // ignore logout errors
    } finally {
      setAccessToken(null);
      saveAccessToken(null);
      history.push('/login');
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16">
            <div className="flex items-center">
              <h1 className="text-xl font-semibold text-gray-900">Yearly Planner</h1>
            </div>
            <div className="flex items-center">
              <button
                onClick={handleLogout}
                className="px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700"
              >
                Logout
              </button>
            </div>
          </div>
        </div>
      </nav>

      <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        <div className="px-4 py-6 sm:px-0">
          <div className="mb-6">
            <h2 className="text-2xl font-bold text-gray-900 mb-4">My Tasks</h2>
            
            <div className="mb-4 flex space-x-4">
              <button
                onClick={() => setFilter('all')}
                className={`px-4 py-2 rounded-md ${filter === 'all' ? 'bg-indigo-600 text-white' : 'bg-white text-gray-700 border border-gray-300'}`}
              >
                All
              </button>
              <button
                onClick={() => setFilter('active')}
                className={`px-4 py-2 rounded-md ${filter === 'active' ? 'bg-indigo-600 text-white' : 'bg-white text-gray-700 border border-gray-300'}`}
              >
                Active
              </button>
              <button
                onClick={() => setFilter('completed')}
                className={`px-4 py-2 rounded-md ${filter === 'completed' ? 'bg-indigo-600 text-white' : 'bg-white text-gray-700 border border-gray-300'}`}
              >
                Completed
              </button>
            </div>

            <form onSubmit={handleCreateTask} className="mb-6 bg-white p-4 rounded-lg shadow">
              <div className="mb-4">
                <input
                  type="text"
                  placeholder="Task title"
                  value={newTaskTitle}
                  onChange={(e) => setNewTaskTitle(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
                  disabled={creating}
                />
              </div>
              <div className="mb-4">
                <textarea
                  placeholder="Description (optional)"
                  value={newTaskDescription}
                  onChange={(e) => setNewTaskDescription(e.target.value)}
                  rows={3}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
                  disabled={creating}
                />
              </div>
              <button
                type="submit"
                disabled={creating || !newTaskTitle.trim()}
                className="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {creating ? 'Creating...' : 'Add Task'}
              </button>
            </form>

            {error && (
              <div className="mb-4 rounded-md bg-red-50 p-4">
                <div className="text-sm text-red-800">{error}</div>
              </div>
            )}
          </div>

          {loading ? (
            <div className="text-center text-gray-600">Loading tasks...</div>
          ) : tasks.length === 0 ? (
            <div className="text-center text-gray-500 py-8">
              No tasks found. Create your first task above!
            </div>
          ) : (
            <div className="bg-white shadow overflow-hidden sm:rounded-md">
              <ul className="divide-y divide-gray-200">
                {tasks.map((task) => (
                  <li key={task._id} className="px-6 py-4">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center flex-1">
                        <input
                          type="checkbox"
                          checked={task.completed || false}
                          onChange={() => handleToggleComplete(task._id, task.completed)}
                          className="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded"
                        />
                        <div className="ml-4 flex-1">
                          <h3 className={`text-lg font-medium ${task.completed ? 'line-through text-gray-500' : 'text-gray-900'}`}>
                            {task.title}
                          </h3>
                          {task.description && (
                            <p className={`mt-1 text-sm ${task.completed ? 'text-gray-400' : 'text-gray-600'}`}>
                              {task.description}
                            </p>
                          )}
                          {task.dueDate && (
                            <p className="mt-1 text-xs text-gray-500">
                              Due: {new Date(task.dueDate).toLocaleDateString()}
                            </p>
                          )}
                        </div>
                      </div>
                      <button
                        onClick={() => handleDeleteTask(task._id)}
                        className="ml-4 px-3 py-1 text-sm text-red-600 hover:text-red-800"
                      >
                        Delete
                      </button>
                    </div>
                  </li>
                ))}
              </ul>
            </div>
          )}
        </div>
      </main>
    </div>
  );
}

export default Home;
