'use strict';

const ROLES_BY_PLAYER_COUNT = Object.freeze([
  { min: 4, max: 5, mafia: 1, doctor: 1, detective: 1 },
  { min: 6, max: 8, mafia: 2, doctor: 1, detective: 1 },
  { min: 9, max: 12, mafia: 3, doctor: 1, detective: 1 },
  { min: 13, max: 16, mafia: 4, doctor: 1, detective: 1 },
  { min: 17, max: 20, mafia: 5, doctor: 1, detective: 1 }
]);

function getRoleCounts(playerCount) {
  if (!Number.isInteger(playerCount) || playerCount < 4 || playerCount > 20) {
    throw new RangeError('A Mafia Radical game requires 4 to 20 players.');
  }
  const band = ROLES_BY_PLAYER_COUNT.find(item => playerCount >= item.min && playerCount <= item.max);
  return {
    mafia: band.mafia,
    doctor: band.doctor,
    detective: band.detective,
    citizen: playerCount - band.mafia - band.doctor - band.detective
  };
}

// Fisher-Yates with a caller-provided cryptographically secure random source.
function shuffleSecure(items, randomInt) {
  const result = [...items];
  for (let i = result.length - 1; i > 0; i--) {
    const j = randomInt(i + 1);
    if (!Number.isInteger(j) || j < 0 || j > i) throw new Error('Invalid random source');
    [result[i], result[j]] = [result[j], result[i]];
  }
  return result;
}

function assignRoles(playerIds, randomInt) {
  if (!Array.isArray(playerIds)) throw new TypeError('playerIds must be an array');
  const counts = getRoleCounts(playerIds.length);
  if (new Set(playerIds).size !== playerIds.length) throw new Error('Player IDs must be unique');
  const roles = [
    ...Array(counts.mafia).fill('mafia'),
    ...Array(counts.doctor).fill('doctor'),
    ...Array(counts.detective).fill('detective'),
    ...Array(counts.citizen).fill('citizen')
  ];
  return shuffleSecure(roles, randomInt).map((role, index) => ({ playerId: playerIds[index], role }));
}

function getWinner(aliveRoles) {
  const mafia = aliveRoles.filter(role => role === 'mafia').length;
  const town = aliveRoles.length - mafia;
  if (mafia === 0) return 'town';
  if (mafia >= town) return 'mafia';
  return null;
}

module.exports = { getRoleCounts, shuffleSecure, assignRoles, getWinner };
