# 📁 STRUCTURE DU PROJET ADMIN-WEB

```
admin-web/
│
├── 📄 package.json                 # Configuration npm
├── 📄 vite.config.js              # Configuration Vite
├── 📄 index.html                  # Point d'entrée HTML
├── 📄 .env                        # ⚠️ VARIABLES D'ENV (À COMPLÉTER)
├── 📄 .env.example                # Template .env
├── 📄 .gitignore                  # Fichiers à ignorer Git
├── 📄 README.md                   # Documentation
├── 📄 GUIDE_DEMARRAGE.md          # ← COMMENCEZ PAR LIRE CECI
│
├── 📁 src/
│   │
│   ├── 📄 main.jsx                # Point d'entrée React
│   ├── 📄 App.jsx                 # Composant racine + Routage
│   │
│   ├── 📁 components/
│   │   ├── ProtectedRoute.jsx     # Wrapper pour routes sécurisées
│   │   └── Navbar.jsx             # (À créer) Barre de navigation
│   │
│   ├── 📁 pages/
│   │   ├── Login.jsx              # 🔐 Page de connexion
│   │   ├── Dashboard.jsx          # 📊 Tableau de bord admin
│   │   ├── Users.jsx              # (À créer) Gestion utilisateurs
│   │   ├── Parkings.jsx           # (À créer) Gestion parkings
│   │   ├── Reservations.jsx       # (À créer) Gestion réservations
│   │   └── NotFound.jsx           # (À créer) Page 404
│   │
│   ├── 📁 hooks/
│   │   ├── useAuth.js             # 🔑 Gestion authentification
│   │   └── useForm.js             # (À créer) Gestion formulaires
│   │
│   ├── 📁 services/
│   │   ├── supabase.js            # Connexion Supabase
│   │   └── apiService.js          # 📡 Appels API (Users, Parkings, etc.)
│   │
│   ├── 📁 config/
│   │   └── supabase.js            # Configuration Supabase
│   │
│   └── 📁 styles/
│       ├── index.css              # 🎨 Styles globaux
│       ├── Login.css              # Styles page login
│       ├── Dashboard.css          # Styles tableau de bord
│       ├── Users.css              # (À créer)
│       ├── Parkings.css           # (À créer)
│       └── Reservations.css       # (À créer)
│
└── 📁 public/
    └── (Fichiers statiques)

```

## 🎯 Fichiers Clés

### Configuration
- **`.env`** - Variables Supabase (SECRET!)
- **`vite.config.js`** - Configuration build
- **`package.json`** - Dépendances npm

### Frontend Principal
- **`src/App.jsx`** - Router + structure
- **`src/main.jsx`** - Point d'entrée React

### Pages (à compléter)
- **`src/pages/Login.jsx`** ✅ Fait
- **`src/pages/Dashboard.jsx`** ✅ Fait
- **`src/pages/Users.jsx`** ⏳ À faire
- **`src/pages/Parkings.jsx`** ⏳ À faire
- **`src/pages/Reservations.jsx`** ⏳ À faire

### Logique
- **`src/hooks/useAuth.js`** ✅ Authentification
- **`src/services/apiService.js`** ✅ API Supabase
- **`src/config/supabase.js`** ✅ Connexion

### Sécurité
- **`src/components/ProtectedRoute.jsx`** ✅ Routes protégées

## ✅ DÉJÀ IMPLÉMENTÉ

```
✅ Authentification Supabase
✅ Protection des routes (ProtectedRoute)
✅ Page de login avec validation
✅ Dashboard avec statistiques
✅ Hook useAuth pour gestion session
✅ Service API complet (CRUD)
✅ Styles CSS responsif
✅ Configuration Supabase
✅ Gestion des erreurs
✅ Déconnexion sécurisée
```

## ⏳ À IMPLÉMENTER

```
1️⃣ Page Utilisateurs
   - Liste des utilisateurs
   - Édition profil
   - Suppression comptes
   - Recherche/Filtre

2️⃣ Page Parkings
   - Ajouter parking
   - Éditer informations
   - Supprimer parking
   - Voir disponibilités

3️⃣ Page Réservations
   - Historique réservations
   - Détails réservation
   - Annulation
   - Statuts

4️⃣ Amélioration Dashboard
   - Graphiques (Chart.js/Recharts)
   - Statistiques temps réel
   - Alertes
   - Notifications

5️⃣ Fonctionnalités avancées
   - Rapports PDF
   - Export données
   - Permissions admin
   - Logs d'activité
```

## 🔄 Workflow de création

Pour ajouter une nouvelle page (exemple: Users):

```
1. Créer: src/pages/Users.jsx
2. Créer: src/styles/Users.css
3. Modifier: src/App.jsx (ajouter route)
4. Modifier: src/pages/Dashboard.jsx (ajouter lien)
5. Importer dans App: import Users from './pages/Users'
```

## 📦 Structure des données (exemples)

### Utilisateurs (profiles)
```javascript
{
  id: "uuid",
  email: "user@example.com",
  name: "John Doe",
  created_at: "2024-01-01"
}
```

### Parkings
```javascript
{
  id: "uuid",
  name: "Parking Downtown",
  address: "123 Main St",
  capacity: 50,
  spots_available: 15
}
```

### Réservations
```javascript
{
  id: "uuid",
  user_id: "uuid",
  parking_id: "uuid",
  start_time: "2024-01-01T10:00:00",
  end_time: "2024-01-01T14:00:00",
  status: "active"
}
```

---

**Besoin d'aide? Consultez GUIDE_DEMARRAGE.md** 🚀
