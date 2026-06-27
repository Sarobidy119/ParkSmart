# ⚡ QUICK START - Les 5 min pour lancer

## 🎯 Objectif
Lancer l'application admin web ParkSmart en 5 minutes

## 📋 Ordre des étapes

### 1️⃣ Récupérer les clés Supabase (2 min)

```
1. Allez sur: https://supabase.com
2. Connectez-vous
3. Cliquez ⚙️ Settings
4. Allez dans: API
5. Copiez:
   - Project URL
   - anon public key
```

### 2️⃣ Configurer .env (1 min)

Ouvrez: `d:\APK\admin-web\.env`

Remplissez:
```env
VITE_SUPABASE_URL=https://xxxxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJ...
```

**Sauvegardez** (Ctrl+S)

### 3️⃣ Créer compte admin dans Supabase (1 min)

```
1. Dashboard Supabase
2. Authentication
3. Users
4. Add User
5. Email: admin@parksmart.com
6. Password: (fort!)
7. Créer
```

### 4️⃣ Lancer l'app (1 min)

Terminal dans `d:\APK\admin-web`:

```bash
npm run dev
```

Vous verrez:
```
➜  Local:   http://localhost:5173/
```

### 5️⃣ Ouvrir dans navigateur

- Cliquez le lien ou ouvrez: http://localhost:5173/
- Entrez: admin@parksmart.com
- Mot de passe: (celui de l'étape 3)
- Cliquez: Se connecter

## ✅ C'est fait!

Vous voyez le dashboard? 🎉

---

## 🆘 Ça ne marche pas?

### Erreur: "Cannot find module"
```bash
npm install
npm run dev
```

### Erreur: "VITE_SUPABASE_URL undefined"
- Vérifiez `.env` est rempli
- Redémarrez `npm run dev`

### Erreur: "Invalid login credentials"
- Vérifiez le compte existe dans Supabase
- Vérifiez email/password

### Port 5173 busy
```bash
npm run dev -- --port 5174
```

---

## 📚 Documentation complète

- **COMMENCEZ_ICI.md** - Vue d'ensemble
- **GUIDE_DEMARRAGE.md** - Instructions détaillées
- **STRUCTURE_PROJET.md** - Architecture
- **GUIDE_CREER_PAGES.md** - Ajouter des pages
- **SECURITE.md** - Bonnes pratiques

---

**Ready? Lancez npm run dev! 🚀**
