# Guide d'intégration des réservations - Admin Web + Mobile

## Vue d'ensemble

L'application mobile ParkSmart (Flutter) communique avec le backend Supabase qui est utilisé par l'admin web (React). Les réservations effectuées sur l'app mobile doivent être visibles en temps réel dans l'interface d'administration web.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     SUPABASE PROJECT                         │
├─────────────────────────────────────────────────────────────┤
│  • Base de données (PostgreSQL)                              │
│  • Authentication (JWT)                                      │
│  • Real-time subscriptions                                   │
│  • Storage (pour images)                                     │
│  • Policies (RLS)                                            │
└─────────────────────────────────────────────────────────────┘
         ↑                                      ↑
         │                                      │
    ┌────────────────┐               ┌──────────────────┐
    │ FLUTTER MOBILE │               │  REACT ADMIN WEB │
    │   (ParkSmart)  │               │   (admin-web)    │
    │                │               │                  │
    │ • Réservations │←──────────────│ • Dashboard      │
    │ • Paiements    │  (Supabase)   │ • Gestion users  │
    │ • Profil user  │               │ • Rapports       │
    └────────────────┘               │ • Confirmations  │
                                      └──────────────────┘
```

## Schéma des tables Supabase

### Table: reservations
```sql
CREATE TABLE reservations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  utilisateur_id UUID NOT NULL REFERENCES auth.users(id),
  parking_id UUID NOT NULL REFERENCES parkings(id),
  place_id UUID NOT NULL,
  vehicule_id UUID NOT NULL,
  debut TIMESTAMP WITH TIME ZONE NOT NULL,
  fin TIMESTAMP WITH TIME ZONE NOT NULL,
  statut VARCHAR(50) NOT NULL, -- 'en_attente', 'confirmee', 'annulee', 'terminee'
  montant DECIMAL(10, 2) NOT NULL,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(parking_id, place_id, debut)
);

-- Index pour les requêtes fréquentes
CREATE INDEX idx_reservations_utilisateur ON reservations(utilisateur_id);
CREATE INDEX idx_reservations_parking ON reservations(parking_id);
CREATE INDEX idx_reservations_statut ON reservations(statut);
CREATE INDEX idx_reservations_dates ON reservations(debut, fin);
```

### Table: utilisateurs_profil (stockage des infos supplémentaires)
```sql
CREATE TABLE utilisateurs_profil (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  nom VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  adresse TEXT,
  telephone VARCHAR(20),
  vehicule_plaque VARCHAR(20),
  vehicule_modele VARCHAR(255),
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Table: notifications_reservation
```sql
CREATE TABLE notifications_reservation (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  utilisateur_id UUID NOT NULL REFERENCES auth.users(id),
  reservation_id UUID NOT NULL REFERENCES reservations(id),
  type VARCHAR(50) NOT NULL, -- 'confirmee', 'annulee', 'rappel', 'en_attente'
  titre VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  lu BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_notifications_utilisateur ON notifications_reservation(utilisateur_id);
CREATE INDEX idx_notifications_lu ON notifications_reservation(lu);
```

## Politiques RLS (Row Level Security)

```sql
-- Réservations: L'utilisateur ne voit que ses propres réservations
ALTER TABLE reservations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can see their own reservations"
  ON reservations FOR SELECT
  USING (auth.uid() = utilisateur_id);

CREATE POLICY "Users can create their own reservations"
  ON reservations FOR INSERT
  WITH CHECK (auth.uid() = utilisateur_id);

CREATE POLICY "Users can update their own reservations"
  ON reservations FOR UPDATE
  USING (auth.uid() = utilisateur_id)
  WITH CHECK (auth.uid() = utilisateur_id);

-- Profil utilisateur
ALTER TABLE utilisateurs_profil ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can see their own profile"
  ON utilisateurs_profil FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON utilisateurs_profil FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);
```

## Notifications et statuts

### États des réservations
- **en_attente**: Réservation créée, en attente de confirmation
- **confirmee**: Réservation confirmée après paiement
- **annulee**: Réservation annulée par l'utilisateur
- **terminee**: Réservation expirée (heure de fin dépassée)

### Flux de statuts
```
Créer réservation → en_attente
                  ↓
Paiement → confirmee → (attendre fin) → terminee
                  ↓
Annuler → annulee
```

## Intégration côté mobile (Flutter)

### 1. Créer une réservation
```dart
// providers/reservation_provider.dart
Future<void> createReservation({
  required String parkingId,
  required String placeId,
  required String vehiculeId,
  required DateTime debut,
  required DateTime fin,
  required double montant,
}) async {
  try {
    final user = Supabase.instance.client.auth.currentUser;
    final response = await Supabase.instance.client
        .from('reservations')
        .insert({
          'utilisateur_id': user!.id,
          'parking_id': parkingId,
          'place_id': placeId,
          'vehicule_id': vehiculeId,
          'debut': debut.toIso8601String(),
          'fin': fin.toIso8601String(),
          'montant': montant,
          'statut': 'en_attente',
        })
        .select()
        .single();
    
    // Créer une notification pour l'utilisateur
    await _createNotification(
      user.id,
      response['id'],
      'en_attente',
      'Réservation créée',
      'Votre réservation est en attente de confirmation',
    );
  } catch (e) {
    state = state.copyWith(error: e.toString());
  }
}
```

### 2. Mettre à jour le statut
```dart
Future<void> updateReservationStatus({
  required String reservationId,
  required String newStatus,
}) async {
  try {
    final response = await Supabase.instance.client
        .from('reservations')
        .update({'statut': newStatus})
        .eq('id', reservationId)
        .select()
        .single();
    
    // Notifier l'utilisateur du changement
    await _createNotification(
      response['utilisateur_id'],
      reservationId,
      newStatus,
      'Réservation $newStatus',
      'Votre réservation a été $newStatus',
    );
  } catch (e) {
    state = state.copyWith(error: e.toString());
  }
}
```

### 3. Écouter les changements en temps réel
```dart
void subscribeToReservations(String userId) {
  Supabase.instance.client
      .from('reservations')
      .on(RealtimeListenTypes.all, ChannelFilter(
        event: '*',
        schema: 'public',
        table: 'reservations',
        filter: 'utilisateur_id=eq.$userId',
      ).toFilterString())
      .subscribe((payload) {
        // Mettre à jour l'état local
        ref.read(reservationProvider.notifier).loadByUser(userId);
        
        // Afficher une notification
        if (payload.eventType == 'UPDATE') {
          final reservation = ReservationModel.fromJson(payload.newRecord);
          _showStatusNotification(reservation);
        }
      });
}
```

## Intégration côté admin web (React)

### 1. Dashboard des réservations
```javascript
// admin-web/src/pages/ReservationsDashboard.jsx
import { useEffect, useState } from 'react';
import { supabase } from '../config/supabase';

export function ReservationsDashboard() {
  const [reservations, setReservations] = useState([]);
  const [filter, setFilter] = useState('en_attente');

  useEffect(() => {
    // Charger les réservations
    const loadReservations = async () => {
      const { data, error } = await supabase
        .from('reservations')
        .select(`
          *,
          utilisateurs_profil (nom, email, telephone),
          parkings (nom, adresse)
        `)
        .eq('statut', filter)
        .order('created_at', { ascending: false });

      if (error) console.error(error);
      else setReservations(data);
    };

    loadReservations();

    // S'abonner aux changements en temps réel
    const subscription = supabase
      .from('reservations')
      .on('*', (payload) => {
        if (payload.eventType === 'INSERT') {
          setReservations([payload.new, ...reservations]);
        } else if (payload.eventType === 'UPDATE') {
          setReservations(
            reservations.map(r => r.id === payload.new.id ? payload.new : r)
          );
        }
      })
      .subscribe();

    return () => subscription.unsubscribe();
  }, [filter]);

  return (
    <div className="reservation-dashboard">
      <h1>Réservations</h1>
      {/* Afficher les réservations */}
    </div>
  );
}
```

### 2. Confirmer une réservation
```javascript
async function confirmReservation(reservationId) {
  const { data, error } = await supabase
    .from('reservations')
    .update({ statut: 'confirmee' })
    .eq('id', reservationId)
    .select();

  if (error) {
    console.error(error);
  } else {
    // Une notification sera envoyée via la fonction Supabase
    console.log('Réservation confirmée');
  }
}
```

## Triggers Supabase (Functions)

### Trigger: Créer une notification lors d'une nouvelle réservation
```sql
-- Créer une fonction qui crée une notification
CREATE OR REPLACE FUNCTION create_notification()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO notifications_reservation (
    utilisateur_id,
    reservation_id,
    type,
    titre,
    message
  ) VALUES (
    NEW.utilisateur_id,
    NEW.id,
    NEW.statut,
    'Réservation créée',
    'Votre réservation a été créée avec succès'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Créer un trigger
CREATE TRIGGER notification_on_reservation_created
  AFTER INSERT ON reservations
  FOR EACH ROW
  EXECUTE FUNCTION create_notification();
```

### Trigger: Notifier lors d'une mise à jour
```sql
CREATE OR REPLACE FUNCTION notify_on_reservation_update()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO notifications_reservation (
    utilisateur_id,
    reservation_id,
    type,
    titre,
    message
  ) VALUES (
    NEW.utilisateur_id,
    NEW.id,
    NEW.statut,
    CASE 
      WHEN NEW.statut = 'confirmee' THEN 'Réservation confirmée'
      WHEN NEW.statut = 'annulee' THEN 'Réservation annulée'
      ELSE 'Réservation mise à jour'
    END,
    CASE 
      WHEN NEW.statut = 'confirmee' THEN 'Votre réservation a été confirmée'
      WHEN NEW.statut = 'annulee' THEN 'Votre réservation a été annulée'
      ELSE 'Votre réservation a été mise à jour'
    END
  )
  WHERE NEW.statut != OLD.statut;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER notification_on_reservation_update
  AFTER UPDATE ON reservations
  FOR EACH ROW
  EXECUTE FUNCTION notify_on_reservation_update();
```

## Checklist d'intégration

- [ ] Schéma Supabase configuré (tables + indexes)
- [ ] Politiques RLS activées
- [ ] Fonctions et triggers créés
- [ ] Mobile: Créer réservations fonctionnelles
- [ ] Mobile: Afficher notifications de statut
- [ ] Admin web: Dashboard réservations
- [ ] Admin web: Confirmation/annulation
- [ ] Test temps réel (mobile ↔ web)
- [ ] Gestion des erreurs
- [ ] Documentation mise à jour

## Déploiement

1. **Configurer Supabase**: Exécuter les scripts SQL dans l'interface Supabase
2. **Déployer mobile**: Builder APK avec credentials Supabase corrects
3. **Déployer web**: Mettre à jour `admin-web/.env` avec Supabase URL/Key
4. **Tester**: Créer une réservation sur mobile, vérifier sur web

## Troubleshooting

**Problème**: Réservations ne s'affichent pas dans admin web
- Vérifier les politiques RLS
- Vérifier que l'utilisateur est authentifié correctement
- Vérifier la clé Supabase utilisée

**Problème**: Notifications ne s'envoient pas
- Vérifier les triggers Supabase
- Vérifier les fonctions créées
- Consulter les logs Supabase

**Problème**: Temps réel pas fonctionnel
- Vérifier la souscription Supabase
- Vérifier que RealtimeSubscriptions est activé
- Vérifier les permissions

