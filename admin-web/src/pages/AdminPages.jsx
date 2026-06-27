import { useCallback, useEffect, useMemo, useState } from 'react';
import {
  Bell,
  CalendarClock,
  CheckCircle2,
  CircleDollarSign,
  Clock,
  CreditCard,
  Edit3,
  FileText,
  Gauge,
  LocateFixed,
  Mail,
  MapPin,
  MessageSquareText,
  Navigation,
  ParkingCircle,
  Plus,
  ReceiptText,
  Save,
  Search,
  Send,
  Settings,
  Star,
  Trash2,
  UserCog,
  Users,
  X,
} from 'lucide-react';
import {
  notificationService,
  parkingService,
  paymentService,
  placeService,
  reservationService,
  reviewService,
  statsService,
  userService,
} from '../services/apiService';

const emptyParking = {
  nom: '',
  adresse: '',
  ville: 'Antananarivo',
  latitude: '',
  longitude: '',
  description: '',
  placeCount: 8,
  placePrefix: 'A',
  niveau: 'RDC',
  prixHeure: '',
  prixJour: '',
  tarif: [],
};

const formatDate = (value) => {
  if (!value) return '-';
  return new Intl.DateTimeFormat('fr-FR', {
    dateStyle: 'medium',
    timeStyle: 'short',
  }).format(new Date(value));
};

const formatMoney = (value) =>
  new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'MGA',
    maximumFractionDigits: 0,
  }).format(Number(value || 0));

function useAsyncList(loader) {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const load = useCallback(async () => {
    try {
      setLoading(true);
      setError('');
      setItems(await loader());
    } catch (err) {
      setError(err.message || 'Erreur de chargement');
    } finally {
      setLoading(false);
    }
  }, [loader]);

  useEffect(() => {
    let active = true;

    Promise.resolve()
      .then(loader)
      .then((data) => {
        if (active) setItems(data);
      })
      .catch((err) => {
        if (active) setError(err.message || 'Erreur de chargement');
      })
      .finally(() => {
        if (active) setLoading(false);
      });

    return () => {
      active = false;
    };
  }, [loader]);

  return { items, loading, error, setError, load };
}

function PageHeader({ title, subtitle, action, icon: Icon }) {
  return (
    <div className="page-heading">
      <div>
        <h2>
          {Icon && <Icon size={25} aria-hidden="true" />}
          {title}
        </h2>
        {subtitle && <p>{subtitle}</p>}
      </div>
      {action}
    </div>
  );
}

function IconTitle({ icon: Icon, children }) {
  return (
    <span className="icon-title">
      <Icon size={20} aria-hidden="true" />
      {children}
    </span>
  );
}

function Modal({ title, icon: Icon = FileText, children, onClose, size = 'md' }) {
  return (
    <div className="modal-backdrop" role="presentation" onMouseDown={onClose}>
      <section
        className={`modal-card modal-${size}`}
        role="dialog"
        aria-modal="true"
        aria-label={title}
        onMouseDown={(event) => event.stopPropagation()}
      >
        <header className="modal-header">
          <h3>
            <Icon size={20} aria-hidden="true" />
            {title}
          </h3>
          <button className="icon-btn" type="button" onClick={onClose} aria-label="Fermer">
            <X size={18} aria-hidden="true" />
          </button>
        </header>
        {children}
      </section>
    </div>
  );
}

function Alert({ type = 'error', children }) {
  if (!children) return null;
  return (
    <div className={`alert alert-${type}`}>
      <FileText size={17} aria-hidden="true" />
      {children}
    </div>
  );
}

function LoadingState() {
  return (
    <div className="state-panel">
      <Gauge size={24} aria-hidden="true" />
      Chargement...
    </div>
  );
}

function EmptyState({ text = 'Aucune donnee trouvee.' }) {
  return (
    <div className="state-panel">
      <Search size={24} aria-hidden="true" />
      {text}
    </div>
  );
}

function StatusBadge({ value }) {
  const normalized = String(value || '').toLowerCase();
  const tone =
    normalized.includes('annul') || normalized.includes('echec')
      ? 'danger'
      : normalized.includes('termin') || normalized.includes('paye')
        ? 'success'
        : 'info';
  return (
    <span className={`badge badge-${tone}`}>
      <CheckCircle2 size={13} aria-hidden="true" />
      {value || '-'}
    </span>
  );
}

function Dashboard() {
  const [stats, setStats] = useState(null);
  const [error, setError] = useState('');

  useEffect(() => {
    statsService
      .getDashboardStats()
      .then(setStats)
      .catch((err) => setError(err.message || 'Erreur de chargement'));
  }, []);

  const cards = [
    ['Utilisateurs', stats?.users, Users],
    ['Parkings', stats?.parkings, ParkingCircle],
    ['Places', stats?.places, MapPin],
    ['Reservations actives', stats?.activeReservations, CalendarClock],
    ['Reservations totales', stats?.reservations, ReceiptText],
    ['Revenu', stats ? formatMoney(stats.revenue) : undefined, CircleDollarSign],
    ['Note moyenne', stats ? `${stats.rating.toFixed(1)} / 5` : undefined, Star],
  ];

  return (
    <>
      <PageHeader
        title="Tableau de bord"
        icon={Gauge}
        subtitle="Vue globale de ce que les clients voient et utilisent dans l'application mobile."
      />
      <Alert>{error}</Alert>
      <div className="stats-grid">
        {cards.map(([label, value, Icon]) => (
          <div className="stat-card" key={label}>
            <span>
              <Icon size={18} aria-hidden="true" />
              {label}
            </span>
            <strong>{value ?? '...'}</strong>
          </div>
        ))}
      </div>
      <section className="info-band">
        <strong>
          <Navigation size={18} aria-hidden="true" />
          Logique reliee
        </strong>
        <p>
          Les donnees de cette console sont ecrites dans les memes tables Supabase
          que l'application Flutter: parking, place_parking, tarif, reservation,
          paiement, avis et notification.
        </p>
      </section>
    </>
  );
}

function ParkingForm({ initialValue, onSubmit, onCancel, saving }) {
  const [form, setForm] = useState(initialValue || emptyParking);

  const update = (field, value) => setForm((prev) => ({ ...prev, [field]: value }));

  return (
    <form className="form-grid" onSubmit={(event) => onSubmit(event, form)}>
      <label>
        <IconTitle icon={ParkingCircle}>Nom</IconTitle>
        <input required value={form.nom} onChange={(e) => update('nom', e.target.value)} />
      </label>
      <label>
        <IconTitle icon={MapPin}>Ville</IconTitle>
        <input value={form.ville} onChange={(e) => update('ville', e.target.value)} />
      </label>
      <label className="wide">
        <IconTitle icon={Navigation}>Adresse</IconTitle>
        <input required value={form.adresse} onChange={(e) => update('adresse', e.target.value)} />
      </label>
      <label>
        <IconTitle icon={LocateFixed}>Latitude</IconTitle>
        <input required type="number" step="any" value={form.latitude} onChange={(e) => update('latitude', e.target.value)} />
      </label>
      <label>
        <IconTitle icon={LocateFixed}>Longitude</IconTitle>
        <input required type="number" step="any" value={form.longitude} onChange={(e) => update('longitude', e.target.value)} />
      </label>
      <label>
        <IconTitle icon={Clock}>Prix heure</IconTitle>
        <input type="number" min="0" value={form.prixHeure} onChange={(e) => update('prixHeure', e.target.value)} />
      </label>
      <label>
        <IconTitle icon={CircleDollarSign}>Prix jour</IconTitle>
        <input type="number" min="0" value={form.prixJour} onChange={(e) => update('prixJour', e.target.value)} />
      </label>
      {!initialValue?.id && (
        <>
          <label>
            <IconTitle icon={ParkingCircle}>Nombre de places</IconTitle>
            <input type="number" min="0" value={form.placeCount} onChange={(e) => update('placeCount', e.target.value)} />
          </label>
          <label>
            <IconTitle icon={FileText}>Prefixe places</IconTitle>
            <input value={form.placePrefix} onChange={(e) => update('placePrefix', e.target.value)} />
          </label>
        </>
      )}
      <label>
        <IconTitle icon={Gauge}>Niveau</IconTitle>
        <input value={form.niveau} onChange={(e) => update('niveau', e.target.value)} />
      </label>
      <label className="wide">
        <IconTitle icon={MessageSquareText}>Description</IconTitle>
        <textarea value={form.description} onChange={(e) => update('description', e.target.value)} />
      </label>
      <div className="form-actions wide">
        <button className="btn btn-primary" type="submit" disabled={saving}>
          <Save size={16} aria-hidden="true" />
          {saving ? 'Enregistrement...' : 'Enregistrer'}
        </button>
        <button className="btn btn-ghost" type="button" onClick={onCancel}>
          <X size={16} aria-hidden="true" />
          Annuler
        </button>
      </div>
    </form>
  );
}

function ParkingsPage() {
  const { items, loading, error, setError, load } = useAsyncList(parkingService.getAll);
  const [editing, setEditing] = useState(null);
  const [showCreate, setShowCreate] = useState(false);
  const [showPlaceModal, setShowPlaceModal] = useState(false);
  const [saving, setSaving] = useState(false);
  const [placeForm, setPlaceForm] = useState({ parkingId: '', numero: '', niveau: 'RDC', occupe: false });

  const submitParking = async (event, form) => {
    event.preventDefault();
    try {
      setSaving(true);
      setError('');
      if (editing?.id) {
        await parkingService.update(editing.id, form);
      } else {
        await parkingService.create(form);
      }
      setEditing(null);
      setShowCreate(false);
      await load();
    } catch (err) {
      setError(err.message || 'Erreur pendant l enregistrement');
    } finally {
      setSaving(false);
    }
  };

  const editParking = (parking) => {
    const tarif = parking.tarif?.[0];
    setShowCreate(false);
    setEditing({
      ...parking,
      prixHeure: tarif?.prix_heure ?? '',
      prixJour: tarif?.prix_jour ?? '',
      tarif: parking.tarif || [],
    });
  };

  const deleteParking = async (id) => {
    if (!window.confirm('Supprimer ce parking et ses places ?')) return;
    try {
      await parkingService.delete(id);
      await load();
    } catch (err) {
      setError(err.message || 'Suppression impossible');
    }
  };

  const addPlace = async (event) => {
    event.preventDefault();
    try {
      await placeService.create(placeForm.parkingId, placeForm);
      setPlaceForm({ parkingId: '', numero: '', niveau: 'RDC', occupe: false });
      setShowPlaceModal(false);
      await load();
    } catch (err) {
      setError(err.message || 'Place impossible a creer');
    }
  };

  return (
    <>
      <PageHeader
        title="Parkings"
        icon={ParkingCircle}
        subtitle="Creation des parkings visibles dans l'application mobile."
        action={
          <div className="toolbar-actions">
            <button className="btn btn-secondary" type="button" onClick={() => setShowPlaceModal(true)}>
              <Plus size={16} aria-hidden="true" />
              Ajouter une place
            </button>
            <button className="btn btn-primary" type="button" onClick={() => { setShowCreate(true); setEditing(null); }}>
              <Plus size={16} aria-hidden="true" />
              Ajouter un parking
            </button>
          </div>
        }
      />
      <Alert>{error}</Alert>
      {(showCreate || editing) && (
        <Modal
          title={editing ? 'Modifier le parking' : 'Nouveau parking'}
          icon={editing ? Edit3 : ParkingCircle}
          size="lg"
          onClose={() => { setEditing(null); setShowCreate(false); }}
        >
          <ParkingForm
            initialValue={editing || emptyParking}
            saving={saving}
            onSubmit={submitParking}
            onCancel={() => { setEditing(null); setShowCreate(false); }}
          />
        </Modal>
      )}
      {showPlaceModal && (
        <Modal
          title="Ajouter une place"
          icon={ParkingCircle}
          onClose={() => setShowPlaceModal(false)}
        >
        <form className="inline-form" onSubmit={addPlace}>
          <label>
            <IconTitle icon={ParkingCircle}>Parking</IconTitle>
            <select required value={placeForm.parkingId} onChange={(e) => setPlaceForm((p) => ({ ...p, parkingId: e.target.value }))}>
              <option value="">Parking</option>
              {items.map((parking) => <option key={parking.id} value={parking.id}>{parking.nom}</option>)}
            </select>
          </label>
          <label>
            <IconTitle icon={FileText}>Numero</IconTitle>
            <input required placeholder="A-1" value={placeForm.numero} onChange={(e) => setPlaceForm((p) => ({ ...p, numero: e.target.value }))} />
          </label>
          <label>
            <IconTitle icon={Gauge}>Niveau</IconTitle>
            <input placeholder="RDC" value={placeForm.niveau} onChange={(e) => setPlaceForm((p) => ({ ...p, niveau: e.target.value }))} />
          </label>
          <label className="checkbox-label">
            <input type="checkbox" checked={placeForm.occupe} onChange={(e) => setPlaceForm((p) => ({ ...p, occupe: e.target.checked }))} />
            Occupee
          </label>
          <button className="btn btn-primary" type="submit">
            <Plus size={16} aria-hidden="true" />
            Ajouter
          </button>
        </form>
        </Modal>
      )}
      {loading ? <LoadingState /> : items.length === 0 ? <EmptyState /> : (
        <div className="parking-grid">
          {items.map((parking) => {
            const places = parking.place_parking || [];
            const occupied = places.filter((place) => place.occupe).length;
            const tarif = parking.tarif?.[0];
            return (
              <article className="parking-card" key={parking.id}>
                <div className="card-head">
                  <div>
                    <h3>{parking.nom}</h3>
                    <p>{parking.adresse}</p>
                  </div>
                  <StatusBadge value={`${places.length - occupied}/${places.length} libres`} />
                </div>
                <dl className="details-list">
                  <div><dt>Ville</dt><dd>{parking.ville}</dd></div>
                  <div><dt>GPS</dt><dd>{parking.latitude}, {parking.longitude}</dd></div>
                  <div><dt>Tarif</dt><dd>{formatMoney(tarif?.prix_heure)} / h</dd></div>
                </dl>
                <p className="muted">{parking.description || 'Sans description'}</p>
                <div className="place-list">
                  {places.slice(0, 18).map((place) => (
                    <button
                      key={place.id}
                      className={`place-chip ${place.occupe ? 'occupied' : ''}`}
                      type="button"
                      title={place.occupe ? 'Occupee' : 'Libre'}
                      onClick={async () => {
                        await placeService.update(place.id, { occupe: !place.occupe });
                        await load();
                      }}
                    >
                      {place.numero}
                    </button>
                  ))}
                </div>
                <div className="card-actions">
                  <button className="btn btn-secondary" type="button" onClick={() => editParking(parking)}>
                    <Edit3 size={16} aria-hidden="true" />
                    Modifier
                  </button>
                  <button className="btn btn-danger" type="button" onClick={() => deleteParking(parking.id)}>
                    <Trash2 size={16} aria-hidden="true" />
                    Supprimer
                  </button>
                </div>
              </article>
            );
          })}
        </div>
      )}
    </>
  );
}

function ReservationsPage() {
  const { items, loading, error, setError, load } = useAsyncList(reservationService.getAll);

  const updateStatus = async (id, statut) => {
    try {
      await reservationService.updateStatus(id, statut);
      await load();
    } catch (err) {
      setError(err.message || 'Statut impossible a modifier');
    }
  };

  return (
    <>
      <PageHeader title="Reservations" icon={CalendarClock} subtitle="Suivi et correction des reservations client." />
      <Alert>{error}</Alert>
      {loading ? <LoadingState /> : items.length === 0 ? <EmptyState /> : (
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Client</th>
                <th>Parking</th>
                <th>Place</th>
                <th>Vehicule</th>
                <th>Debut</th>
                <th>Fin</th>
                <th>Montant</th>
                <th>Statut</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              {items.map((reservation) => (
                <tr key={reservation.id}>
                  <td>{reservation.utilisateur?.prenom} {reservation.utilisateur?.nom}<small>{reservation.utilisateur?.email}</small></td>
                  <td>{reservation.parking?.nom || '-'}</td>
                  <td>{reservation.place_parking?.numero || '-'}</td>
                  <td>{reservation.vehicule?.plaque || '-'}</td>
                  <td>{formatDate(reservation.debut)}</td>
                  <td>{formatDate(reservation.fin)}</td>
                  <td>{formatMoney(reservation.montant)}</td>
                  <td><StatusBadge value={reservation.statut} /></td>
                  <td>
                    <select value={reservation.statut} onChange={(e) => updateStatus(reservation.id, e.target.value)}>
                      <option value="a_venir">a_venir</option>
                      <option value="en_cours">en_cours</option>
                      <option value="terminee">terminee</option>
                      <option value="annulee">annulee</option>
                    </select>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </>
  );
}

function UsersPage() {
  const { items, loading, error, setError, load } = useAsyncList(userService.getAll);

  const toggleAdmin = async (user) => {
    try {
      await userService.updateAdmin(user.id, !user.is_admin);
      await load();
    } catch (err) {
      setError(err.message || 'Droit admin impossible a modifier');
    }
  };

  return (
    <>
      <PageHeader title="Utilisateurs" icon={Users} subtitle={`${items.length} comptes clients et administrateurs.`} />
      <Alert>{error}</Alert>
      {loading ? <LoadingState /> : items.length === 0 ? <EmptyState /> : (
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Nom</th>
                <th>Email</th>
                <th>Telephone</th>
                <th>Role</th>
                <th>Creation</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              {items.map((user) => (
                <tr key={user.id}>
                  <td>{user.prenom} {user.nom}</td>
                  <td>{user.email}</td>
                  <td>{user.telephone || '-'}</td>
                  <td><StatusBadge value={user.is_admin ? 'admin' : 'client'} /></td>
                  <td>{formatDate(user.created_at)}</td>
                  <td>
                    <button className="btn btn-secondary" type="button" onClick={() => toggleAdmin(user)}>
                      <UserCog size={16} aria-hidden="true" />
                      {user.is_admin ? 'Retirer admin' : 'Rendre admin'}
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </>
  );
}

function PaymentsPage() {
  const { items, loading, error } = useAsyncList(paymentService.getAll);
  const total = useMemo(() => items.reduce((sum, item) => sum + Number(item.montant || 0), 0), [items]);

  return (
    <>
      <PageHeader title="Paiements" icon={CreditCard} subtitle={`Total encaisse: ${formatMoney(total)}`} />
      <Alert>{error}</Alert>
      {loading ? <LoadingState /> : items.length === 0 ? <EmptyState /> : (
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Client</th>
                <th>Parking</th>
                <th>Methode</th>
                <th>Montant</th>
                <th>Statut</th>
                <th>Date</th>
              </tr>
            </thead>
            <tbody>
              {items.map((payment) => (
                <tr key={payment.id}>
                  <td>{payment.utilisateur?.prenom} {payment.utilisateur?.nom}<small>{payment.utilisateur?.email}</small></td>
                  <td>{payment.reservation?.parking?.nom || '-'}</td>
                  <td>{payment.methode}</td>
                  <td>{formatMoney(payment.montant)}</td>
                  <td><StatusBadge value={payment.statut} /></td>
                  <td>{formatDate(payment.created_at)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </>
  );
}

function ReviewsPage() {
  const { items, loading, error, setError, load } = useAsyncList(reviewService.getAll);

  const remove = async (id) => {
    if (!window.confirm('Supprimer cet avis ?')) return;
    try {
      await reviewService.delete(id);
      await load();
    } catch (err) {
      setError(err.message || 'Suppression impossible');
    }
  };

  return (
    <>
      <PageHeader title="Avis" icon={MessageSquareText} subtitle="Retours clients affiches autour des parkings." />
      <Alert>{error}</Alert>
      {loading ? <LoadingState /> : items.length === 0 ? <EmptyState /> : (
        <div className="review-grid">
          {items.map((review) => (
            <article className="panel" key={review.id}>
              <div className="card-head">
                <div>
                  <h3>{review.parking?.nom || 'Parking'}</h3>
                  <p>{review.utilisateur?.prenom} {review.utilisateur?.nom}</p>
                </div>
                <StatusBadge value={`${review.note}/5`} />
              </div>
              <p>{review.commentaire || 'Sans commentaire'}</p>
              <div className="card-actions">
                <span className="muted">{formatDate(review.created_at)}</span>
                <button className="btn btn-danger" type="button" onClick={() => remove(review.id)}>
                  <Trash2 size={16} aria-hidden="true" />
                  Supprimer
                </button>
              </div>
            </article>
          ))}
        </div>
      )}
    </>
  );
}

function NotificationsPage() {
  const notifications = useAsyncList(notificationService.getAll);
  const users = useAsyncList(userService.getAll);
  const [form, setForm] = useState({ utilisateurId: 'all', titre: '', message: '' });
  const [showForm, setShowForm] = useState(false);
  const [saving, setSaving] = useState(false);

  const submit = async (event) => {
    event.preventDefault();
    try {
      setSaving(true);
      notifications.setError('');
      await notificationService.create(form);
      setForm({ utilisateurId: 'all', titre: '', message: '' });
      setShowForm(false);
      await notifications.load();
    } catch (err) {
      notifications.setError(err.message || 'Notification impossible a envoyer');
    } finally {
      setSaving(false);
    }
  };

  return (
    <>
      <PageHeader
        title="Notifications"
        icon={Bell}
        subtitle="Messages envoyes aux comptes client dans l'application mobile."
        action={
          <button className="btn btn-primary" type="button" onClick={() => setShowForm(true)}>
            <Send size={16} aria-hidden="true" />
            Envoyer une notification
          </button>
        }
      />
      <Alert>{notifications.error}</Alert>
      {showForm && (
        <Modal title="Envoyer une notification" icon={Send} onClose={() => setShowForm(false)}>
        <form className="form-grid" onSubmit={submit}>
          <label>
            <IconTitle icon={Users}>Destinataire</IconTitle>
            <select value={form.utilisateurId} onChange={(e) => setForm((p) => ({ ...p, utilisateurId: e.target.value }))}>
              <option value="all">Tous les utilisateurs</option>
              {users.items.map((user) => (
                <option key={user.id} value={user.id}>{user.prenom} {user.nom} - {user.email}</option>
              ))}
            </select>
          </label>
          <label>
            <IconTitle icon={Bell}>Titre</IconTitle>
            <input required value={form.titre} onChange={(e) => setForm((p) => ({ ...p, titre: e.target.value }))} />
          </label>
          <label className="wide">
            <IconTitle icon={Mail}>Message</IconTitle>
            <textarea required value={form.message} onChange={(e) => setForm((p) => ({ ...p, message: e.target.value }))} />
          </label>
          <div className="form-actions wide">
            <button className="btn btn-primary" type="submit" disabled={saving}>
              <Send size={16} aria-hidden="true" />
              {saving ? 'Envoi...' : 'Envoyer'}
            </button>
            <button className="btn btn-ghost" type="button" onClick={() => setShowForm(false)}>
              <X size={16} aria-hidden="true" />
              Annuler
            </button>
          </div>
        </form>
        </Modal>
      )}
      {notifications.loading ? <LoadingState /> : notifications.items.length === 0 ? <EmptyState /> : (
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Titre</th>
                <th>Client</th>
                <th>Message</th>
                <th>Etat</th>
                <th>Date</th>
              </tr>
            </thead>
            <tbody>
              {notifications.items.map((notification) => (
                <tr key={notification.id}>
                  <td>{notification.titre}</td>
                  <td>{notification.utilisateur?.email || '-'}</td>
                  <td>{notification.message}</td>
                  <td><StatusBadge value={notification.lu ? 'lue' : 'non lue'} /></td>
                  <td>{formatDate(notification.created_at)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </>
  );
}

function SettingsPage() {
  return (
    <>
      <PageHeader title="Parametres" icon={Settings} subtitle="Controle de configuration avant mise en production." />
      <section className="panel">
        <h3>Connexion Supabase</h3>
        <dl className="settings-list">
          <div>
            <dt>URL</dt>
            <dd>{import.meta.env.VITE_SUPABASE_URL ? 'Configuree' : 'Manquante'}</dd>
          </div>
          <div>
            <dt>Cle publique anon</dt>
            <dd>{import.meta.env.VITE_SUPABASE_ANON_KEY ? 'Configuree' : 'Manquante'}</dd>
          </div>
          <div>
            <dt>Compte admin</dt>
            <dd>Le champ utilisateur.is_admin doit etre true pour le compte administrateur.</dd>
          </div>
        </dl>
      </section>
      <section className="info-band">
        <strong>Avant utilisation reelle</strong>
        <p>
          Executez le schema Supabase mis a jour, creez ou connectez un compte,
          puis passez son champ is_admin a true dans la table utilisateur.
        </p>
      </section>
    </>
  );
}

export {
  Dashboard,
  NotificationsPage,
  ParkingsPage,
  PaymentsPage,
  ReservationsPage,
  ReviewsPage,
  SettingsPage,
  UsersPage,
};
