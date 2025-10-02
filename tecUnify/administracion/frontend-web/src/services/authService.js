import api from './api';

export const login = async (email, password) => {
  try {
    const response = await api.post('/login/', {
      email,
      password
    });
    
    // Guardar el usuario en localStorage
    localStorage.setItem('user', JSON.stringify(response.data.user));
    
    return response.data;
  } catch (error) {
    throw error.response.data;
  }
};

export const logout = () => {
  localStorage.removeItem('user');
};

export const getCurrentUser = () => {
  const user = localStorage.getItem('user');
  return user ? JSON.parse(user) : null;
};

export const isAuthenticated = () => {
  return getCurrentUser() !== null;
};