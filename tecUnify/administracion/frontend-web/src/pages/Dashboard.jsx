import React from 'react';
import { useNavigate } from 'react-router-dom';
import { getCurrentUser, logout } from '../services/authService';

function Dashboard() {
  const user = getCurrentUser();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <div style={{ padding: '20px' }}>
      <h1>🎯 Dashboard de Administración</h1>
      <div style={{ marginTop: '20px' }}>
        <p>Bienvenido, <strong>{user?.nombre}</strong></p>
        <p>Email: {user?.email}</p>
        <p>Tipo: {user?.tipo}</p>
        
        <button
          onClick={handleLogout}
          style={{
            marginTop: '20px',
            padding: '10px 20px',
            backgroundColor: '#dc3545',
            color: 'white',
            border: 'none',
            cursor: 'pointer'
          }}
        >
          Cerrar Sesión
        </button>
      </div>
    </div>
  );
}

export default Dashboard;