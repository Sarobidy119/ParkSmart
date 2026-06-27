# 🔒 SÉCURITÉ ET BONNES PRATIQUES

## 🛡️ Sécurité

### ✅ À FAIRE

```
✅ Nunca commitez .env
✅ Utilisez variables d'environnement pour les secrets
✅ Protégez les routes admin avec ProtectedRoute
✅ Validez les inputs utilisateur
✅ Utilisez HTTPS en production
✅ Activez RLS (Row Level Security) dans Supabase
✅ Limitez les permissions des rôles
✅ Mettez à jour npm packages régulièrement
✅ Utilisez des mots de passe forts
✅ Activez 2FA si possible
```

### ❌ À ÉVITER

```
❌ Ne mettez PAS le .env dans Git
❌ Ne loggez JAMAIS les secrets
❌ Ne stockez PAS de données sensibles en localStorage
❌ Ne confiez PAS aux tokens non vérifiés
❌ Ne faites PAS confiance aux données du client
❌ Ne loggez PAS les erreurs complètes aux utilisateurs
❌ N'exposez PAS les stacks traces
❌ N'oubliez PAS de valider les données
```

## 📋 Checklist sécurité

### Phase de développement
- [ ] `.env` ajouté à `.gitignore`
- [ ] `.env.example` créé (sans secrets)
- [ ] Pas de secrets commitées
- [ ] Authentification Supabase activée
- [ ] Routes protégées avec `ProtectedRoute`

### Phase de test
- [ ] Tester avec données sensibles minimales
- [ ] Tester déconnexion/reconnexion
- [ ] Vérifier expiration de session
- [ ] Tester sessions multiples

### Avant production
- [ ] RLS activée dans Supabase
- [ ] Policies configurées par rôle
- [ ] CORS configuré correctement
- [ ] npm packages à jour (`npm audit`)
- [ ] Pas de console.log() en production
- [ ] Gestion des erreurs correcte

## 🔐 Configuration Supabase sécurisée

### 1. Row Level Security (RLS)

```sql
-- Activer RLS sur les tables publiques
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Permettre aux users de voir leur propre profil
CREATE POLICY "Users can view own profile"
  ON profiles
  FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

-- Permettre aux admins de voir tous les profils
CREATE POLICY "Admins can view all profiles"
  ON profiles
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );
```

### 2. Variables d'environnement

✅ **Correct**:
```env
VITE_SUPABASE_URL=https://project.supabase.co
VITE_SUPABASE_ANON_KEY=ey...public...
```

❌ **INCORRECT** (ne faites jamais ça):
```
VITE_SUPABASE_SERVICE_ROLE_KEY=ey...secret...  ← ❌ JAMAIS!
```

### 3. Authentification

**Supabase gère automatiquement**:
- ✅ Hachage des mots de passe (bcrypt)
- ✅ Tokens JWT sécurisés
- ✅ Sessions sécurisées
- ✅ CSRF protection

## 💻 Pratiques de code

### ✅ Gestion des erreurs

```javascript
// BON
try {
  const { data, error } = await supabase.from('users').select();
  if (error) {
    console.error('Erreur serveur:', error);
    showUserMessage('Une erreur est survenue. Réessayez.');
  }
} catch (err) {
  console.error('Erreur application:', err);
}

// MAUVAIS
const { data } = await supabase.from('users').select();
// Pas de gestion d'erreur!
```

### ✅ Validation des inputs

```javascript
// BON
function createUser(email, password) {
  if (!email || !password) {
    throw new Error('Email et mot de passe requis');
  }
  if (!email.includes('@')) {
    throw new Error('Email invalide');
  }
  if (password.length < 8) {
    throw new Error('Mot de passe trop court');
  }
  // Créer l'utilisateur...
}

// MAUVAIS
function createUser(email, password) {
  // Aucune validation!
  supabase.auth.signUp({ email, password });
}
```

### ✅ Gestion des secrets

```javascript
// BON - Utiliser variables d'env
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

// MAUVAIS - Hardcoder les secrets
const supabaseKey = 'eyJhbGciOi...'; // ❌ NE FAITES PAS ÇA
```

### ✅ Storage sécurisé

```javascript
// BON - localStorage pour données publiques uniquement
localStorage.setItem('theme', 'dark'); // OK
localStorage.setItem('username', 'john'); // OK

// MAUVAIS - localStorage pour données sensibles
localStorage.setItem('token', jwtToken); // ❌ Supabase gère ça
localStorage.setItem('password', password); // ❌ JAMAIS!
```

## 📊 Monitoring et logging

### Logging sûr

```javascript
// BON
console.log('User login attempt:', { email: user.email });
console.log('API call to:', endpoint);

// MAUVAIS
console.log('Full user object:', userData); // Peut contenir des secrets
console.log('Response:', response); // Peut contenir tokens
```

### Erreurs à logger

```javascript
// À logger en production
- Erreurs de sécurité (failed login attempts)
- Erreurs d'accès non autorisé
- Erreurs critiques
- Changements importants (création compte, suppression)

// À NE PAS logger
- Mots de passe
- Tokens
- Données complètes d'utilisateurs
- Stack traces (montrer à l'utilisateur)
```

## 🚀 Déploiement sécurisé

### Avant de déployer

```bash
# Vérifier les vulnérabilités
npm audit

# Fixer les vulnérabilités
npm audit fix

# Build de production
npm run build

# Vérifier qu'aucun secret n'est leaké
grep -r "VITE_SUPABASE" dist/ # Ne doit rien afficher
```

### Vercel/Netlify

1. ✅ Ajouter variables d'env dans le dashboard
2. ✅ Ne PAS passer `.env` en paramètre
3. ✅ Utiliser secrets manager si disponible
4. ✅ Activer HTTPS (automatique)

### Azure/AWS

1. ✅ Utiliser Key Vault pour les secrets
2. ✅ Configurer IAM correctement
3. ✅ Activer monitoring et logging
4. ✅ Chiffrer les données en transit ET au repos

## 🔄 Updates et maintenance

### Garder npm à jour

```bash
# Vérifier les mises à jour
npm outdated

# Mettre à jour
npm update

# Mettre à jour majeurs (attention!)
npm install @supabase/supabase-js@latest
```

### Vérifier régulièrement

```bash
# Audit hebdomadaire
npm audit

# Mettre à jour
npm audit fix

# Commit
git add package.json package-lock.json
git commit -m "chore: update dependencies"
```

## 📚 Ressources

- **Supabase Security**: https://supabase.com/docs/guides/auth/concepts/mfa
- **OWASP**: https://owasp.org/
- **NPM Security**: https://docs.npmjs.com/cli/v10/commands/npm-audit
- **React Security**: https://react.dev/learn

## ✅ Audit checklist final

Avant de montrer votre app à un client:

- [ ] Pas de secrets dans le code
- [ ] `.env` dans `.gitignore`
- [ ] `npm audit` passe
- [ ] Authentification fonctionne
- [ ] Routes protégées
- [ ] Déconnexion fonctionne
- [ ] Gestion erreurs correcte
- [ ] HTTPS en production
- [ ] RLS activée dans Supabase
- [ ] Logs n'exposent pas de secrets

---

**Sécurité = Priorité #1** 🔒
