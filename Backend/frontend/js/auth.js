/**
 * VNEG Auth Guard
 * Import in every protected page to enforce login and role-based access.
 */

export function getCurrentUser() {
    const raw = localStorage.getItem('vneg_user');
    try { return raw ? JSON.parse(raw) : null; } catch { return null; }
}

export function getToken() {
    return localStorage.getItem('vneg_token');
}

/**
 * Redirect to login page if no valid session.
 * Optionally restrict to specific roles.
 * @param {string[]} [allowedRoles] - e.g. ['admin'], ['user'], or omit for any logged-in user
 */
export function requireAuth(allowedRoles = null) {
    const token = getToken();
    const user = getCurrentUser();

    if (!token || !user) {
        window.location.href = '/frontend/index.html';
        return null;
    }

    if (allowedRoles && !allowedRoles.includes(user.role)) {
        // Redirect to their correct dashboard
        redirectByRole(user.role);
        return null;
    }

    return user;
}

/**
 * Redirect user to the correct dashboard based on role.
 */
export function redirectByRole(role) {
    const base = '/frontend/pages/';
    switch (role) {
        case 'admin':
        case 'staff':
            window.location.href = base + 'admin.html';
            break;
        case 'team_owner':
            window.location.href = base + 'dashboard.html';
            break;
        case 'user':
        default:
            window.location.href = base + 'dashboard.html';
            break;
    }
}

/**
 * Call on the landing page: if already logged in, redirect away.
 */
export function redirectIfLoggedIn() {
    const token = getToken();
    const user = getCurrentUser();
    if (token && user) {
        redirectByRole(user.role);
    }
}

export function logout() {
    localStorage.removeItem('vneg_token');
    localStorage.removeItem('vneg_user');
    window.location.href = '/frontend/index.html';
}
