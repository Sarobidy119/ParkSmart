import { supabase } from '../config/supabase';

const toNumber = (value, fallback = 0) => {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : fallback;
};

const cleanText = (value) => String(value ?? '').trim();

const handleResult = ({ data, error }) => {
  if (error) throw error;
  return data;
};

const listByCreatedAt = async (table) =>
  handleResult(
    await supabase.from(table).select('*').order('created_at', { ascending: false }),
  ) || [];

export const userService = {
  async getAll() {
    return listByCreatedAt('utilisateur');
  },

  async updateAdmin(id, isAdmin) {
    return handleResult(
      await supabase
        .from('utilisateur')
        .update({ is_admin: isAdmin })
        .eq('id', id)
        .select()
        .single(),
    );
  },

  async delete(id) {
    return handleResult(await supabase.from('utilisateur').delete().eq('id', id));
  },
};

export const parkingService = {
  async getAll() {
    return (
      handleResult(
        await supabase
          .from('parking')
          .select('*, place_parking(*), tarif(*)')
          .order('nom', { ascending: true }),
      ) || []
    );
  },

  async create(form) {
    const placeCount = Math.max(0, Math.floor(toNumber(form.placeCount, 0)));
    const payload = {
      nom: cleanText(form.nom),
      adresse: cleanText(form.adresse),
      ville: cleanText(form.ville) || 'Antananarivo',
      latitude: toNumber(form.latitude),
      longitude: toNumber(form.longitude),
      description: cleanText(form.description),
    };

    const parking = handleResult(
      await supabase.from('parking').insert(payload).select().single(),
    );

    if (placeCount > 0) {
      const prefix = cleanText(form.placePrefix) || 'A';
      const places = Array.from({ length: placeCount }, (_, index) => ({
        parking_id: parking.id,
        numero: `${prefix}-${index + 1}`,
        niveau: cleanText(form.niveau) || 'RDC',
        occupe: false,
      }));
      handleResult(await supabase.from('place_parking').insert(places));
    }

    const prixHeure = toNumber(form.prixHeure);
    const prixJour = toNumber(form.prixJour);
    if (prixHeure > 0 || prixJour > 0) {
      handleResult(
        await supabase.from('tarif').insert({
          parking_id: parking.id,
          prix_heure: prixHeure,
          prix_jour: prixJour,
        }),
      );
    }

    return parking;
  },

  async update(id, form) {
    const payload = {
      nom: cleanText(form.nom),
      adresse: cleanText(form.adresse),
      ville: cleanText(form.ville) || 'Antananarivo',
      latitude: toNumber(form.latitude),
      longitude: toNumber(form.longitude),
      description: cleanText(form.description),
    };

    const parking = handleResult(
      await supabase.from('parking').update(payload).eq('id', id).select().single(),
    );

    const prixHeure = toNumber(form.prixHeure);
    const prixJour = toNumber(form.prixJour);
    const existingTarif = Array.isArray(form.tarif) ? form.tarif[0] : null;

    if (existingTarif?.id) {
      handleResult(
        await supabase
          .from('tarif')
          .update({ prix_heure: prixHeure, prix_jour: prixJour })
          .eq('id', existingTarif.id),
      );
    } else if (prixHeure > 0 || prixJour > 0) {
      handleResult(
        await supabase.from('tarif').insert({
          parking_id: id,
          prix_heure: prixHeure,
          prix_jour: prixJour,
        }),
      );
    }

    return parking;
  },

  async delete(id) {
    return handleResult(await supabase.from('parking').delete().eq('id', id));
  },
};

export const placeService = {
  async create(parkingId, form) {
    return handleResult(
      await supabase
        .from('place_parking')
        .insert({
          parking_id: parkingId,
          numero: cleanText(form.numero),
          niveau: cleanText(form.niveau) || 'RDC',
          occupe: Boolean(form.occupe),
        })
        .select()
        .single(),
    );
  },

  async update(id, updates) {
    return handleResult(
      await supabase.from('place_parking').update(updates).eq('id', id).select().single(),
    );
  },

  async delete(id) {
    return handleResult(await supabase.from('place_parking').delete().eq('id', id));
  },
};

export const reservationService = {
  async getAll() {
    return (
      handleResult(
        await supabase
          .from('reservation')
          .select('*, utilisateur(nom, prenom, email), parking(nom, adresse), place_parking(numero), vehicule(plaque, marque, modele)')
          .order('debut', { ascending: false }),
      ) || []
    );
  },

  async updateStatus(id, statut) {
    return handleResult(
      await supabase.from('reservation').update({ statut }).eq('id', id).select().single(),
    );
  },
};

export const paymentService = {
  async getAll() {
    return (
      handleResult(
        await supabase
          .from('paiement')
          .select('*, utilisateur(nom, prenom, email), reservation(parking_id, debut, fin, parking(nom))')
          .order('created_at', { ascending: false }),
      ) || []
    );
  },
};

export const reviewService = {
  async getAll() {
    return (
      handleResult(
        await supabase
          .from('avis')
          .select('*, utilisateur(nom, prenom, email), parking(nom)')
          .order('created_at', { ascending: false }),
      ) || []
    );
  },

  async delete(id) {
    return handleResult(await supabase.from('avis').delete().eq('id', id));
  },
};

export const notificationService = {
  async getAll() {
    return (
      handleResult(
        await supabase
          .from('notification')
          .select('*, utilisateur(nom, prenom, email)')
          .order('created_at', { ascending: false }),
      ) || []
    );
  },

  async create(form) {
    const target = cleanText(form.utilisateurId);
    if (target === 'all') {
      const users = await userService.getAll();
      if (users.length === 0) return [];
      return handleResult(
        await supabase.from('notification').insert(
          users.map((user) => ({
            utilisateur_id: user.id,
            titre: cleanText(form.titre),
            message: cleanText(form.message),
            lu: false,
          })),
        ),
      );
    }

    return handleResult(
      await supabase.from('notification').insert({
        utilisateur_id: target,
        titre: cleanText(form.titre),
        message: cleanText(form.message),
        lu: false,
      }),
    );
  },

  async delete(id) {
    return handleResult(await supabase.from('notification').delete().eq('id', id));
  },
};

export const statsService = {
  async getDashboardStats() {
    const [users, parkings, places, reservations, activeReservations, payments, reviews] =
      await Promise.all([
        supabase.from('utilisateur').select('*', { count: 'exact', head: true }),
        supabase.from('parking').select('*', { count: 'exact', head: true }),
        supabase.from('place_parking').select('*', { count: 'exact', head: true }),
        supabase.from('reservation').select('*', { count: 'exact', head: true }),
        supabase
          .from('reservation')
          .select('*', { count: 'exact', head: true })
          .in('statut', ['en_cours', 'a_venir']),
        supabase.from('paiement').select('montant'),
        supabase.from('avis').select('note'),
      ]);

    const revenue = (payments.data || []).reduce(
      (sum, payment) => sum + toNumber(payment.montant),
      0,
    );
    const notes = reviews.data || [];
    const rating =
      notes.length > 0
        ? notes.reduce((sum, review) => sum + toNumber(review.note), 0) / notes.length
        : 0;

    return {
      users: users.count || 0,
      parkings: parkings.count || 0,
      places: places.count || 0,
      reservations: reservations.count || 0,
      activeReservations: activeReservations.count || 0,
      revenue,
      rating,
    };
  },
};
