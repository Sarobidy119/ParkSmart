# 📖 GUIDE COMPLET - Configuration et Démarrage

## ✅ État actuel

✅ Dossier `admin-web` créé
✅ Structure React avec Vite initialisée
✅ Dépendances installées (Supabase, React Router, Axios)
✅ Composants créés
✅ Authentification configurée
✅ Styles CSS appliqués

## 🎯 CE QU'IL FAUT FAIRE MAINTENANT

### ÉTAPE 1: Récupérer vos clés Supabase (5 min)

1. Allez sur: https://supabase.com
2. Connectez-vous à votre projet
3. Cliquez sur ⚙️ **Settings** en bas à gauche
4. Allez dans **API**
5. Vous verrez:
   - **Project URL**: `https://xxxxxx.supabase.co`
   - **anon public key**: `eyJhbG...` (long code)
6. **COPIEZ ces deux valeurs**

### ÉTAPE 2: Configurer le fichier `.env`

1. Ouvrez `d:\APK\admin-web\.env`
2. Remplissez avec les clés de Supabase:

```env
VITE_SUPABASE_URL=https://votre-projet.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**IMPORTANT**: Ne partagez JAMAIS ce fichier `.env` publiquement!

### ÉTAPE 3: Créer un compte admin dans Supabase

1. Allez sur le **Dashboard Supabase**
2. Cliquez sur **Authentication** (menu gauche)
3. Allez dans l'onglet **Users**
4. Cliquez sur **Invite user** ou **Add user**
5. Créez un compte avec:
   - **Email**: `admin@parksmart.com`
   - **Password**: Un mot de passe fort (ex: `AdminSecure2024!`)

**Mémorisez ce mot de passe** - vous en aurez besoin pour vous connecter!

### ÉTAPE 4: Lancer l'application

Ouvrez un terminal dans `d:\APK\admin-web`:

```bash
npm run dev
```

Le terminal affichera:
```
VITE v5.x.x  ready in XXX ms

➜  Local:   http://localhost:5173/
```

**Ouvrez ce lien dans votre navigateur** 🌐

### ÉTAPE 5: Tester la connexion

1. Vous verrez une page de login
2. Entrez:
   - **Email**: `admin@parksmart.com`
   - **Mot de passe**: Celui que vous avez créé à l'ÉTAPE 3
3. Cliquez **Se connecter**

Si ça marche ✅ → Vous verrez le **Dashboard**!

## 🔗 Connexion avec votre app mobile

Les deux applications (mobile + admin web) **partagent la même base Supabase**:

```
┌─────────────────┐
│  APP MOBILE     │
│  (Flutter)      │
└────────┬────────┘
         │
         │ Supabase (même DB)
         │
┌────────▼────────┐
│  APP ADMIN WEB  │
│  (React)        │
└─────────────────┘
```

**C'est pour ça qu'on utilise la même instance Supabase** dans les deux apps!

## 📋 Table de vérification

- [ ] Clés Supabase copiées
- [ ] Fichier `.env` rempli
- [ ] Compte admin créé dans Supabase
- [ ] Commande `npm run dev` exécutée
- [ ] Application accessible sur `http://localhost:5173/`
- [ ] Connexion réussie avec `admin@parksmart.com`
- [ ] Dashboard visible

## ❌ En cas de problème

### "Cannot find module 'supabase'"
Solution:
```bash
npm install supabase react-router-dom axios
```

### "VITE_SUPABASE_URL is not defined"
Solution: Vérifiez que le fichier `.env` existe et est rempli correctement

### "Invalid login credentials"
Solution:
- Vérifiez email/mot de passe dans Supabase
- Assurez-vous que le compte a été créé
- Réessayez

### Port 5173 déjà utilisé
Solution:
```bash
npm run dev -- --port 5174
```

## 🚀 Prochaines étapes (après le lancement)

Une fois que vous pouvez vous connecter:

1. **Ajouter une page de gestion des utilisateurs**
   - Fichier: `src/pages/Users.jsx`
   - Lister tous les utilisateurs
   - Options: Éditer, Supprimer

2. **Ajouter une page de gestion des parkings**
   - Fichier: `src/pages/Parkings.jsx`
   - Voir les parkings disponibles
   - Ajouter/Éditer/Supprimer

3. **Ajouter une page de gestion des réservations**
   - Fichier: `src/pages/Reservations.jsx`
   - Historique des réservations
   - Annulations

4. **Améliorer le Dashboard**
   - Ajouter des graphiques
   - Statistiques en temps réel

## 📁 Fichiers importants

| Fichier | Description |
|---------|-------------|
| `.env` | Vos clés Supabase (SECRET!) |
| `src/App.jsx` | Routage principal |
| `src/pages/Login.jsx` | Page de connexion |
| `src/pages/Dashboard.jsx` | Tableau de bord |
| `src/hooks/useAuth.js` | Gestion authentification |
| `src/config/supabase.js` | Connexion Supabase |

## 💡 Conseils

✅ **DO:**
- Utilisez `.env.local` pour les variables locales
- Testez fréquemment pendant le développement
- Lisez les erreurs de la console (F12)
- Utilisez git pour versionner

❌ **DON'T:**
- Ne commitez pas `.env`
- Ne changez pas les clés publiquement
- N'exposez pas votre `ANON_KEY` sur internet

## 📞 Questions?

- Docs Supabase: https://supabase.com/docs
- Docs React: https://react.dev
- Docs Vite: https://vite.dev

---

**Bonne chance! 🚀 N'hésitez pas si vous avez besoin d'aide.**
