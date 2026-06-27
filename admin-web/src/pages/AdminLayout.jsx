import { NavLink, Outlet } from 'react-router-dom';
import {
  Bell,
  Car,
  CreditCard,
  LayoutDashboard,
  LogOut,
  MapPinned,
  MessageSquareText,
  Settings,
  Users,
} from 'lucide-react';
import { useAuth } from '../hooks/useAuth';

const navItems = [
  { to: '/', label: 'Tableau de bord', icon: LayoutDashboard },
  { to: '/parkings', label: 'Parkings', icon: MapPinned },
  { to: '/reservations', label: 'Reservations', icon: Car },
  { to: '/users', label: 'Utilisateurs', icon: Users },
  { to: '/payments', label: 'Paiements', icon: CreditCard },
  { to: '/reviews', label: 'Avis', icon: MessageSquareText },
  { to: '/notifications', label: 'Notifications', icon: Bell },
  { to: '/settings', label: 'Parametres', icon: Settings },
];

function AdminLayout() {
  const { user, logout } = useAuth();

  return (
    <div className="admin-shell">
      <aside className="admin-sidebar">
        <div className="brand-block">
          <span className="brand-mark">
            <img src="/logo.png" alt="" aria-hidden="true" />
          </span>
          <div>
            <strong>ParkSmart</strong>
            <small>Administration</small>
          </div>
        </div>

        <nav className="side-nav">
          {navItems.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.to === '/'}
              className={({ isActive }) => (isActive ? 'active' : undefined)}
            >
              <item.icon size={18} aria-hidden="true" />
              {item.label}
            </NavLink>
          ))}
        </nav>
      </aside>

      <div className="admin-workspace">
        <header className="topbar">
          <div>
            <span className="eyebrow">Console connectee a Supabase</span>
            <h1>Gestion de l'application mobile</h1>
          </div>
          <div className="account-box">
            <span>{user?.email}</span>
            <button className="btn btn-ghost" type="button" onClick={logout}>
              <LogOut size={16} aria-hidden="true" />
              Deconnexion
            </button>
          </div>
        </header>

        <main className="admin-main">
          <Outlet />
        </main>
      </div>
    </div>
  );
}

export default AdminLayout;
