'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const { getRoleCounts, assignRoles, getWinner } = require('../src/game-rules');

test('role counts cover every supported table size without changing player count', () => {
  for (let count = 4; count <= 20; count++) {
    const roles = getRoleCounts(count);
    assert.equal(roles.mafia + roles.doctor + roles.detective + roles.citizen, count);
    assert.ok(roles.mafia >= 1);
  }
});

test('role counts reject player counts outside supported range', () => {
  assert.throws(() => getRoleCounts(3), RangeError);
  assert.throws(() => getRoleCounts(21), RangeError);
});

test('role assignment gives each unique player exactly one role', () => {
  const players = Array.from({ length: 20 }, (_, index) => `player-${index}`);
  const assigned = assignRoles(players, max => max - 1);
  assert.equal(assigned.length, players.length);
  assert.deepEqual(new Set(assigned.map(item => item.playerId)), new Set(players));
  assert.equal(assigned.filter(item => item.role === 'mafia').length, 5);
  assert.equal(assigned.filter(item => item.role === 'doctor').length, 1);
  assert.equal(assigned.filter(item => item.role === 'detective').length, 1);
});

test('role assignment rejects duplicate player IDs', () => {
  assert.throws(() => assignRoles(['same', 'same', 'x', 'y'], max => max - 1), /unique/);
});

test('victory is decided only when one side meets its terminal condition', () => {
  assert.equal(getWinner(['citizen', 'doctor']), 'town');
  assert.equal(getWinner(['mafia', 'citizen']), 'mafia');
  assert.equal(getWinner(['mafia', 'citizen', 'citizen']), null);
});
