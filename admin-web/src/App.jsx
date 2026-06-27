import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import ProtectedRoute from './components/ProtectedRoute';
import AdminLayout from './pages/AdminLayout';
import {
  Dashboard,
  NotificationsPage,
  ParkingsPage,
  PaymentsPage,
  ReservationsPage,
  ReviewsPage,
  SettingsPage,
  UsersPage,
} from './pages/AdminPages';
import Login from './pages/Login';
import './styles/index.css';
import './styles/Admin.css';

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route
          path="/"
          element={
            <ProtectedRoute>
              <AdminLayout />
            </ProtectedRoute>
          }
        >
          <Route index element={<Dashboard />} />
          <Route path="parkings" element={<ParkingsPage />} />
          <Route path="reservations" element={<ReservationsPage />} />
          <Route path="users" element={<UsersPage />} />
          <Route path="payments" element={<PaymentsPage />} />
          <Route path="reviews" element={<ReviewsPage />} />
          <Route path="notifications" element={<NotificationsPage />} />
          <Route path="settings" element={<SettingsPage />} />
        </Route>
      </Routes>
    </Router>
  );
}

export default App;
