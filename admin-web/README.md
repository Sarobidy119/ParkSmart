# Admin Web - ParkSmart

Interface d'administration pour l'application mobile ParkSmart utilisant React et Supabase.

## 📋 Prérequis

- Node.js 16+ installé
- npm ou yarn
- Compte Supabase avec projet créé

## 🚀 Installation

### 1. Installer les dépendances

```bash
npm install
```

### 2. Configurer les variables d'environnement

1. Créez un fichier `.env` à la racine du projet (copié de `.env.example`)
2. Récupérez vos clés Supabase:
   - Allez sur https://supabase.com
   - Ouvrez votre projet
   - Cliquez sur "Settings" > "API"
   - Copiez `Project URL` et `anon public key`

3. Remplissez le `.env`:
```
VITE_SUPABASE_URL=https://votre-projet.supabase.co
VITE_SUPABASE_ANON_KEY=votre_cle_publique_ici
```

### 3. Configurer l'authentification dans Supabase

**⚠️ IMPORTANT:**

1. Allez dans Supabase Dashboard > "Authentication" > "Users"
2. Créez un compte admin:
   - Email: `admin@parksmart.com`
   - Password: Mot de passe sécurisé
   - Utilisez ce compte pour vous connecter

3. (Optionnel) Activez les fournisseurs externes:
   - Google
   - GitHub
   - Microsoft

## 🏃 Lancer l'application

```bash
npm run dev
```

L'application s'ouvrira sur `http://localhost:5173`

### Login

- **Email**: `admin@parksmart.com`
- **Password**: (celui que vous avez défini dans Supabase)

## 📁 Structure du projet

```
admin-web/
├── src/
│   ├── components/
│   │   └── ProtectedRoute.jsx      # Route protégée par authentification
│   ├── config/
│   │   └── supabase.js             # Configuration Supabase
│   ├── hooks/
│   │   └── useAuth.js              # Hook personnalisé pour l'auth
│   ├── pages/
│   │   ├── Login.jsx               # Page de connexion
│   │   └── Dashboard.jsx           # Tableau de bord admin
│   ├── styles/
│   │   ├── index.css               # Styles globaux
│   │   ├── Login.css               # Styles login
│   │   └── Dashboard.css           # Styles dashboard
│   └── App.jsx                     # Composant racine
├── .env                            # Variables d'environnement (à compléter)
├── .env.example                    # Template d'env
└── package.json
```

## 🔗 Intégration avec la base Supabase mobile

Cette application admin utilise **la même instance Supabase** que l'app mobile.

### Tables disponibles

Les tables accessibles dépendent de votre schéma `supabase_schema.sql`.

Exemples courants:
- `profiles` - Profils utilisateurs
- `parkings` - Informations des parkings
- `reservations` - Réservations de parking

## ✨ Fonctionnalités implémentées

✅ Authentification Supabase
✅ Protection des routes
✅ Tableau de bord avec statistiques
✅ Affichage de l'utilisateur connecté
✅ Déconnexion sécurisée

## 📝 Prochaines étapes à implémenter

1. **Gestion des utilisateurs**
   - Lister tous les utilisateurs
   - Éditer les profils
   - Supprimer les utilisateurs

2. **Gestion des parkings**
   - Ajouter/éditer des parkings
   - Gérer les tarifs

3. **Gestion des réservations**
   - Voir l'historique
   - Annuler des réservations

4. **Rapports**
   - Revenus par période
   - Taux d'occupation

## 🛡️ Sécurité

- Authentification via Supabase
- Clés API dans `.env`
- Routes protégées
- Ne commitez JAMAIS `.env`

## 📦 Dépendances

- React
- Vite
- React Router
- Supabase
- Axios
