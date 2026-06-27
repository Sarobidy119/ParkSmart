import { useAuth } from '../hooks/useAuth';
import Login from '../pages/Login';

function ProtectedRoute({ children }) {
  const { user, loading } = useAuth();

  if (loading) {
    return (
      <div style={{
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        height: '100vh',
        fontSize: '18px',
        color: '#666',
      }}>
        Chargement...
      </div>
    );
  }

  if (!user) {
    return <Login />;
  }

  return children;
}

export default ProtectedRoute;
