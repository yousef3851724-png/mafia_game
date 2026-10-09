'use strict';

/**
 * Deterministic, inspectable AI decision helpers for Mafia Radical.
 * This is a local rules engine, not a connected LLM and not yet wired into live rooms.
 */
const DIFFICULTIES = new Set(['easy', 'normal', 'hard']);
const ROLES = new Set(['mafia', 'citizen', 'doctor', 'detective']);

function pickByScore(candidates, score, random = Math.random) {
  if (!candidates.length) return null;
  const scored = candidates.map((candidate) => ({ candidate, score: score(candidate) }));
  const best = Math.max(...scored.map((x) => x.score));
  const tied = scored.filter((x) => x.score === best);
  return tied[Math.floor(random() * tied.length)].candidate;
}

function chooseNightAction({ role, selfId, players, difficulty = 'normal', random = Math.random }) {
  if (!ROLES.has(role) || !DIFFICULTIES.has(difficulty) || !Array.isArray(players)) return null;
  const alive = players.filter((p) => p && p.alive && p.id !== selfId);
  if (role === 'mafia') {
    const targets = alive.filter((p) => p.role !== 'mafia');
    return pickByScore(targets, (p) => {
      let score = 1;
      if (p.role === 'detective') score += difficulty === 'hard' ? 5 : 2;
      if (p.role === 'doctor') score += difficulty === 'hard' ? 4 : 1;
      return score;
    }, random)?.id ?? null;
  }
  if (role === 'doctor') {
    const self = players.find((p) => p && p.id === selfId && p.alive);
    const targets = [...alive, ...(self ? [self] : [])];
    return pickByScore(targets, (p) => (p.id === selfId ? 1 : 2), random)?.id ?? null;
  }
  if (role === 'detective') {
    const targets = alive.filter((p) => !p.isKnownMafia && !p.isKnownCitizen);
    return targets.length ? targets[Math.floor(random() * targets.length)].id : null;
  }
  return null;
}

function chooseVote({ selfId, players, knownMafiaIds = [], difficulty = 'normal', random = Math.random }) {
  if (!DIFFICULTIES.has(difficulty) || !Array.isArray(players)) return null;
  const known = new Set(knownMafiaIds);
  const alive = players.filter((p) => p && p.alive && p.id !== selfId);
  if (!alive.length) return null;
  return pickByScore(alive, (p) => {
    let score = 0;
    if (known.has(p.id)) score += 100;
    if (p.suspicion === 'high') score += difficulty === 'easy' ? 1 : 3;
    if (p.suspicion === 'medium') score += difficulty === 'hard' ? 2 : 1;
    if (p.isKnownCitizen) score -= 100;
    return score;
  }, random)?.id ?? null;
}

module.exports = { chooseNightAction, chooseVote };
