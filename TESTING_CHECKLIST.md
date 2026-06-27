# 📱 MANUAL TESTING CHECKLIST - ParkSmart Mobile

**Durée estimée:** 10-15 minutes  
**Équipement:** 1 Téléphone Android + USB Cable

---

## ✅ Pre-Testing Setup

- [ ] Téléphone connecté en USB Debug Mode
- [ ] APK compilée: `build/app/outputs/apk/release/app-release.apk`
- [ ] APK installée sur le téléphone: `adb install app-release.apk`
- [ ] App peut se lancer sans crash
- [ ] WiFi et données mobiles disponibles

---

## 🧪 TEST 1: Détection de Connexion Internet

### Scénario: Désactiver puis réactiver la connexion

**Avant:**
- [ ] Ouvrir ParkSmart
- [ ] Aller sur Home ou une autre page
- [ ] App fonctionne normalement

**Action:**
- [ ] Aller dans Settings téléphone
- [ ] Désactiver WiFi
- [ ] Désactiver Données mobiles (Mode Avion recommandé)
- **Attendre 2-3 secondes**

**Attendu:**
- [ ] App affiche automatiquement page "Aucune connexion internet"
- [ ] Icône WiFi cassée visible
- [ ] Message: "Vous avez perdu votre connexion Internet"
- [ ] Statut: "Hors ligne" en rouge

**Résultat:** ✅ PASS / ❌ FAIL

---

**Action 2:**
- [ ] Réactiver WiFi ou désactiver Mode Avion
- **Attendre 2-3 secondes**

**Attendu:**
- [ ] App disparaît automatiquement
- [ ] Retour à la page précédente
- [ ] Connexion rétablie automatiquement
- [ ] Message: "Connexion rétablie" (brièvement)
- [ ] ✅ PAS de rechargement manuel nécessaire

**Résultat:** ✅ PASS / ❌ FAIL

---

## 🧪 TEST 2: Erreur "Email Déjà Existant"

### Scénario: Créer compte avec email déjà enregistré

**Setup:**
- [ ] Retourner à l'écran Login (si offline test complété)
- [ ] Cliquer "Pas de compte? S'inscrire"

**Actions:**
- [ ] Remplir le formulaire:
  - Nom: `Test`
  - Prénom: `User`
  - Email: `sarobidyfanantenana56@gmail.com` (email connu comme existant)
  - Téléphone: `349214170`
  - Mot de passe: `password123`
  - Confirmation: `password123`
- [ ] Cocher "J'accepte les conditions..."
- [ ] Cliquer "S'inscrire"

**Avant (BUG):**
```
Affiche: "duplicate key value violates unique constraint 'utilisateur_email_key'"
```

**Après (CORRIGÉ):**
```
Affiche: "Cet email est déjà utilisé. Connectez-vous ou utilisez un autre email."
```

**Attendu:**
- [ ] Message d'erreur en **français**
- [ ] Message **clair et compréhensible**
- [ ] Pas de technicalités PostgreSQL
- [ ] App ne crash pas
- [ ] L'utilisateur sait qu'il faut se connecter ou changer d'email

**Résultat:** ✅ PASS / ❌ FAIL

---

## 🧪 TEST 3: Erreur Email Invalide

### Scénario: Signup avec email invalide

**Actions:**
- [ ] Aller sur S'inscrire
- [ ] Remplir formulaire avec:
  - Email: `notanemail` (invalide)
  - Autres champs: valides
- [ ] Cliquer "S'inscrire"

**Attendu:**
- [ ] Message: "Adresse email invalide. Utilisez une adresse complete, par exemple nom@gmail.com."
- [ ] Pas de crash
- [ ] Message en français ✓

**Résultat:** ✅ PASS / ❌ FAIL

---

## 🧪 TEST 4: Erreur Mot de Passe Trop Faible

### Scénario: Signup avec mot de passe < 6 caractères

**Actions:**
- [ ] Aller sur S'inscrire
- [ ] Remplir formulaire avec:
  - Mot de passe: `123` (trop court)
  - Confirmation: `123`
- [ ] Cliquer "S'inscrire"

**Attendu:**
- [ ] Validation client: "Mot de passe trop court"
- [ ] OU Message Supabase en français

**Résultat:** ✅ PASS / ❌ FAIL

---

## 🧪 TEST 5: App Stability (Pas de Crash)

### Scénario: Navigation rapide + changements connexion

**Actions (Rapidement):**
- [ ] Ouvrir ParkSmart
- [ ] Naviguer entre pages (Home → Map → Profile)
- [ ] Désactiver WiFi → Page offline
- [ ] Réactiver WiFi
- [ ] Continuer navigation

**Attendu:**
- [ ] Pas de crash
- [ ] Pas d'erreurs "Exception" ou "Null"
- [ ] Navigation fluide
- [ ] App responsive

**Résultat:** ✅ PASS / ❌ FAIL

---

## 🧪 TEST 6: Reconnexion Automatique

### Scénario: Faire une action, perdre connexion, regagner

**Actions:**
1. Connecté à Internet ✓
2. [ ] Essayer une action (ex: voir reservations)
3. [ ] Désactiver WiFi → Attendre page offline
4. [ ] Réactiver WiFi
5. [ ] Vérifier que l'app continuerait l'action précédente

**Attendu:**
- [ ] Pas besoin de recliquer
- [ ] Reconnexion automatique
- [ ] App continue fonctionner

**Résultat:** ✅ PASS / ❌ FAIL

---

## 📋 RÉSUMÉ DES RÉSULTATS

| Test | Description | Résultat |
|------|-----------|----------|
| 1 | Détection perte connexion | ✅/❌ |
| 2 | Reconnexion automatique | ✅/❌ |
| 3 | Email déjà existant → message clair | ✅/❌ |
| 4 | Email invalide → message clair | ✅/❌ |
| 5 | Mot de passe faible → message clair | ✅/❌ |
| 6 | Pas de crash | ✅/❌ |
| 7 | Navigation fluide | ✅/❌ |

---

## 🐛 En Cas d'Erreur/Crash

### Si page "Aucune connexion" n'apparaît pas:
1. Vérifier que connectivity_plus est bien installé: `flutter pub get`
2. Vérifier que connectivity_provider.dart existe
3. Vérifier que ConnectivityWrapper est utilisé dans main.dart
4. Relancer: `flutter clean && flutter run`

### Si messages d'erreur toujours en English:
1. Vérifier formatAuthError() dans auth_repository.dart
2. Vérifier que PostgrestException est importée
3. Relancer: `flutter clean && flutter pub get && flutter run`

### Si app crash:
1. Vérifier les logs: `flutter logs`
2. Chercher "Exception" ou "Error"
3. Partager les logs pour debugging

---

## 💾 Documentation de Résultats

**Remplir ce tableau et sauvegarder:**

```
## Résultats Tests - [DATE]

- Test 1 (Détection connexion): ✅
- Test 2 (Reconnexion auto): ✅
- Test 3 (Email existant): ✅
- Test 4 (Email invalide): ✅
- Test 5 (Pwd trop faible): ✅
- Test 6 (Pas de crash): ✅
- Test 7 (Navigation fluide): ✅

Conclusion: ✅ PRÊT POUR PRODUCTION
```

---

**Durée totale:** ~15 minutes  
**Effort requis:** Minimal (juste tester)  
**Risque:** Aucun (tests non-destructifs)

Bon testing! 🎉
