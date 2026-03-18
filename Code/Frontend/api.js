/**
 * VNEG – API Client Layer
 * All API calls go through this file.
 * Auth: X-Session-Token header (stored in localStorage as 'vneg_token')
 */

const API_BASE = 'http://localhost:5290'; // Change to your backend URL/port

function getToken() {
  return localStorage.getItem('vneg_token');
}

function saveToken(token, user) {
  localStorage.setItem('vneg_token', token);
  localStorage.setItem('vneg_user', JSON.stringify(user));
}

function clearToken() {
  localStorage.removeItem('vneg_token');
  localStorage.removeItem('vneg_user');
}

function getCurrentUser() {
  const raw = localStorage.getItem('vneg_user');
  try { return raw ? JSON.parse(raw) : null; } catch { return null; }
}

async function apiFetch(path, options = {}) {
  const token = getToken();
  const headers = { 'Content-Type': 'application/json', ...(options.headers || {}) };
  if (token) headers['X-Session-Token'] = token;

  const res = await fetch(`${API_BASE}${path}`, {
    ...options,
    headers,
    body: options.body ? JSON.stringify(options.body) : undefined,
  });

  let data;
  try { data = await res.json(); } catch { data = null; }
  return { ok: res.ok, status: res.status, data };
}

// ─── AUTH ───────────────────────────────────────────────────────────────────
const Auth = {
  async register(payload) {
    return apiFetch('/api/users/register', { method: 'POST', body: payload });
  },
  async login(email, password) {
    return apiFetch('/api/users/login', { method: 'POST', body: { email, password } });
  },
  async logout() {
    const token = getToken();
    const res = await apiFetch('/api/users/logout', { method: 'POST', body: { token } });
    clearToken();
    return res;
  },
  async getMe() {
    return apiFetch('/api/users/me');
  },
  async updateMe(dto) {
    return apiFetch('/api/users/me', { method: 'PUT', body: dto });
  },
  async changePassword(currentPassword, newPassword) {
    return apiFetch('/api/users/me/change-password', { method: 'POST', body: { currentPassword, newPassword } });
  },
};

// ─── MAPS ────────────────────────────────────────────────────────────────────
const Maps = {
  async getAll() {
    return apiFetch('/api/maps');
  },
};

// ─── GAMES ───────────────────────────────────────────────────────────────────
const Games = {
  async getByMap(mapId) {
    return apiFetch(`/api/game/by-map/${mapId}`);
  },
  async start(userId, gameId) {
    return apiFetch('/api/game/start', { method: 'POST', body: { userId, gameId } });
  },
  async getQuestions(sessionId) {
    return apiFetch(`/api/game/${sessionId}/questions`);
  },
  async submit(sessionId, answers) {
    // answers: [{questionId, selectedAnswerId}]
    return apiFetch(`/api/game/${sessionId}/submit`, { method: 'POST', body: { answers } });
  },
};

// ─── GRAMMAR ─────────────────────────────────────────────────────────────────
const Grammar = {
  async getTopics(grade = null) {
    const q = grade !== null ? `?grade=${grade}` : '';
    return apiFetch(`/api/grammar/topics${q}`);
  },
  async getMyProgress() {
    return apiFetch('/api/grammar/progress/me');
  },
};

// ─── TEAMS ───────────────────────────────────────────────────────────────────
const Teams = {
  async getMyTeams() {
    return apiFetch('/api/teams/me');
  },
  async getTeam(teamId) {
    return apiFetch(`/api/teams/${teamId}`);
  },
  async getMembers(teamId) {
    return apiFetch(`/api/teams/${teamId}/members`);
  },
  async create(name, description) {
    return apiFetch('/api/teams', { method: 'POST', body: { name, description } });
  },
  async join(inviteCode) {
    return apiFetch('/api/teams/join', { method: 'POST', body: { inviteCode } });
  },
  async leave(teamId) {
    return apiFetch(`/api/teams/${teamId}/leave`, { method: 'POST' });
  },
  async updateTeam(teamId, dto) {
    return apiFetch(`/api/team-owner/${teamId}`, { method: 'PUT', body: dto });
  },
  async removeMember(teamId, userId) {
    return apiFetch(`/api/team-owner/${teamId}/remove-member`, { method: 'POST', body: { userId } });
  },
  async deleteTeam(teamId) {
    return apiFetch(`/api/team-owner/${teamId}`, { method: 'DELETE' });
  },
};

// ─── ADMIN ───────────────────────────────────────────────────────────────────
const Admin = {
  users: {
    async getAll() { return apiFetch('/api/admin/users'); },
    async getById(id) { return apiFetch(`/api/admin/users/${id}`); },
    async setActive(id, isActive) {
      return apiFetch(`/api/admin/users/${id}/active`, { method: 'PATCH', body: { isActive } });
    },
    async setRole(id, role) {
      return apiFetch(`/api/admin/users/${id}/role`, { method: 'PATCH', body: { role } });
    },
  },
  games: {
    async getAll() { return apiFetch('/api/admin/games'); },
    async getById(id) { return apiFetch(`/api/admin/games/${id}`); },
    async create(dto) { return apiFetch('/api/admin/games', { method: 'POST', body: dto }); },
    async update(id, dto) { return apiFetch(`/api/admin/games/${id}`, { method: 'PUT', body: dto }); },
    async delete(id) { return apiFetch(`/api/admin/games/${id}`, { method: 'DELETE' }); },
  },
  grammarTopics: {
    async getAll() { return apiFetch('/api/admin/grammar-topics'); },
    async getById(id) { return apiFetch(`/api/admin/grammar-topics/${id}`); },
    async create(dto) { return apiFetch('/api/admin/grammar-topics', { method: 'POST', body: dto }); },
    async update(id, dto) { return apiFetch(`/api/admin/grammar-topics/${id}`, { method: 'PUT', body: dto }); },
    async delete(id) { return apiFetch(`/api/admin/grammar-topics/${id}`, { method: 'DELETE' }); },
  },
  questions: {
    async getAll() { return apiFetch('/api/admin/questions'); },
    async getById(id) { return apiFetch(`/api/admin/questions/${id}`); },
    async create(dto) { return apiFetch('/api/admin/questions', { method: 'POST', body: dto }); },
    async update(id, dto) { return apiFetch(`/api/admin/questions/${id}`, { method: 'PUT', body: dto }); },
    async delete(id) { return apiFetch(`/api/admin/questions/${id}`, { method: 'DELETE' }); },
  },
};

export { Auth, Maps, Games, Grammar, Teams, Admin, saveToken, clearToken, getCurrentUser, getToken };
