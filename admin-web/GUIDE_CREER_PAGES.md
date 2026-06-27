# 🎓 GUIDE: Comment ajouter de nouvelles pages

Ce guide vous montre comment créer une nouvelle page d'admin (Users, Parkings, etc.)

## 📝 Étapes

### 1. Créer le fichier de la page

**Fichier**: `src/pages/Users.jsx`

```jsx
import { useState, useEffect } from 'react';
import { userService } from '../services/apiService';
import { useAuth } from '../hooks/useAuth';
import '../styles/Users.css';

function Users() {
  const { user } = useAuth();
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    loadUsers();
  }, []);

  const loadUsers = async () => {
    try {
      setLoading(true);
      const { data, error } = await userService.getAllUsers();
      
      if (error) {
        setError(error);
      } else {
        setUsers(data || []);
      }
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (userId) => {
    if (!window.confirm('Êtes-vous sûr?')) return;
    
    const { error } = await userService.deleteUser(userId);
    if (error) {
      alert('Erreur: ' + error);
    } else {
      loadUsers(); // Recharger la liste
    }
  };

  return (
    <div className="users-container">
      <header className="page-header">
        <h1>👥 Gestion des utilisateurs</h1>
        <p>{users.length} utilisateurs</p>
      </header>

      {error && <div className="error-message">{error}</div>}

      <div className="users-table">
        {loading ? (
          <p>Chargement...</p>
        ) : users.length === 0 ? (
          <p>Aucun utilisateur</p>
        ) : (
          <table>
            <thead>
              <tr>
                <th>Email</th>
                <th>Nom</th>
                <th>Créé le</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {users.map((user) => (
                <tr key={user.id}>
                  <td>{user.email}</td>
                  <td>{user.name || '-'}</td>
                  <td>{new Date(user.created_at).toLocaleDateString('fr-FR')}</td>
                  <td>
                    <button onClick={() => handleDelete(user.id)} className="btn-danger">
                      Supprimer
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}

export default Users;
```

### 2. Créer les styles

**Fichier**: `src/styles/Users.css`

```css
.users-container {
  padding: 30px 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.page-header {
  margin-bottom: 30px;
  border-bottom: 2px solid #667eea;
  padding-bottom: 15px;
}

.page-header h1 {
  margin: 0 0 10px 0;
  color: #333;
}

.page-header p {
  margin: 0;
  color: #666;
  font-size: 14px;
}

.users-table {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.users-table table {
  width: 100%;
  border-collapse: collapse;
}

.users-table th {
  background: #f5f5f5;
  padding: 15px;
  text-align: left;
  font-weight: 600;
  color: #333;
  border-bottom: 2px solid #e0e0e0;
}

.users-table td {
  padding: 15px;
  border-bottom: 1px solid #e0e0e0;
}

.users-table tr:hover {
  background: #fafafa;
}

.btn-danger {
  background: #ff4757;
  color: white;
  border: none;
  padding: 8px 12px;
  border-radius: 4px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.btn-danger:hover {
  background: #ff3838;
}

.error-message {
  background: #fee;
  color: #c00;
  padding: 15px;
  border-radius: 5px;
  margin-bottom: 20px;
  border-left: 4px solid #c00;
}
```

### 3. Ajouter la route

**Modifier**: `src/App.jsx`

```jsx
import Users from './pages/Users';  // ← AJOUTER CETTE LIGNE

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route path="/" element={<ProtectedRoute><Dashboard /></ProtectedRoute>} />
        <Route path="/users" element={<ProtectedRoute><Users /></ProtectedRoute>} />  {/* ← AJOUTER CETTE LIGNE */}
      </Routes>
    </Router>
  );
}
```

### 4. Ajouter le lien dans le Dashboard

**Modifier**: `src/pages/Dashboard.jsx`

```jsx
<nav className="admin-nav">
  <a href="/users" className="admin-link">
    👥 Gérer les utilisateurs
  </a>
  {/* Autres liens... */}
</nav>
```

## ✅ Checklist

- [ ] Fichier page créé (`src/pages/XXX.jsx`)
- [ ] Fichier styles créé (`src/styles/XXX.css`)
- [ ] Import ajouté dans `App.jsx`
- [ ] Route ajoutée dans `App.jsx`
- [ ] Lien ajouté dans `Dashboard.jsx`
- [ ] Application redémarrée (`npm run dev`)
- [ ] Page accessible et fonctionnelle

## 🎯 Patterns d'API utilisés

### Récupérer des données
```javascript
const { data, error } = await userService.getAllUsers();
```

### Créer une ressource
```javascript
const { data, error } = await parkingService.createParking({
  name: 'My Parking',
  capacity: 50,
});
```

### Modifier une ressource
```javascript
const { data, error } = await parkingService.updateParking(id, {
  name: 'Updated Name'
});
```

### Supprimer une ressource
```javascript
const { error } = await userService.deleteUser(id);
```

## 🚀 Bonnes pratiques

✅ Toujours utilisez `try/catch`
✅ Gérez les états `loading` et `error`
✅ Confirmez avant de supprimer
✅ Recharger après modification
✅ Donnez du feedback utilisateur
✅ Utilisez les services API (`apiService.js`)
✅ Protégez les routes avec `<ProtectedRoute>`

## ❌ Erreurs courantes

❌ Oublier d'ajouter la route
❌ Oublier le `import`
❌ Ne pas gérer les erreurs
❌ Appels API en dehors du `useEffect`
❌ Exposer les secrets dans le code

## 📚 Templates prêts à l'emploi

J'ai créé des templates pour les pages manquantes. Vous pouvez les copier/coller et adapter!

---

**Besoin d'aide? Consultez les autres fichiers de doc.** 📖
