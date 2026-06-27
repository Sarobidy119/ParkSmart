/// Guide pour la navigation dans ParkSmart
/// 
/// # Fonctionnement du bouton retour du téléphone
/// 
/// Avec `go_router`, le bouton retour du système Android fonctionnera correctement
/// si vous utilisez les bonnes méthodes:
/// 
/// 1. **Navigation standard (recommandée)**: Utiliser `context.go('/route')`
///    ```dart
///    context.go('/home');  // Navigue et ajoute à la pile
///    ```
/// 
/// 2. **Pop (retour)**: Utiliser `context.pop()`
///    ```dart
///    context.pop();  // Retour à la page précédente
///    ```
/// 
/// 3. **Remplacer une route**: Utiliser `context.replace('/route')`
///    ```dart
///    context.replace('/home');  // Remplace la route actuelle
///    ```
/// 
/// # Architecture de navigation
/// 
/// Les boutons de navigation bas (BottomNavBar) permettent de naviguer entre:
/// - /home (Accueil)
/// - /carte (Carte)
/// - /reservation (Réservations)
/// - /profil (Profil)
/// 
/// Les détails/modaux ouvrent des sous-routes:
/// - /parking/:id (Détails parking)
/// - /reservation/new (Formulaire réservation)
/// - /payment (Paiement)
/// - /vehicles (Mes véhicules)
/// - /notifications (Notifications)
/// 
/// # Exemple: Flow complet d'une réservation
/// 
/// 1. Utilisateur clique sur un parking dans la liste/carte
///    `context.go('/parking/:id')`
/// 
/// 2. Voir les détails et cliquer "Réserver"
///    `context.go('/reservation/new?parkingId=xxx')`
/// 
/// 3. Remplir le formulaire et payer
///    `context.push('/payment', extra: {...})`
/// 
/// 4. Confirmation
///    `context.go('/reservation')` ou rester sur la confirmation
/// 
/// # Problèmes courants et solutions
/// 
/// **Problème**: Bouton retour quitte l'app au lieu de revenir à la page précédente
/// **Solution**: Assurez-vous que:
/// - Vous utilisez `context.go()` pour la navigation, pas `Navigator.of(context).push()`
/// - Les BottomNavBar utilisent bien `context.go()`
/// - Les modals (bottom sheets) ne remplacent pas la route de base
/// 
/// **Problème**: Navigation en boucle
/// **Solution**: Ne pas utiliser `context.replace()` sur les routes principales
/// 
/// **Problème**: Perte d'état en naviguant
/// **Solution**: Utiliser Riverpod pour persister l'état entre les pages
///

void example() {
  // Ceci est juste un guide documenté
}
