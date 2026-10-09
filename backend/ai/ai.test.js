'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const { chooseNightAction, chooseVote } = require('./strategy');
const { moderateChat } = require('./moderation');
const { answerQuestion } = require('./assistant');

test('mafia night strategy excludes self and mafia teammates', () => {
  const players = [
    { id: 'm1', role: 'mafia', alive: true },
    { id: 'm2', role: 'mafia', alive: true },
    { id: 'c1', role: 'citizen', alive: true },
  ];
  assert.equal(chooseNightAction({ role: 'mafia', selfId: 'm1', players, random: () => 0 }), 'c1');
});

test('citizen cannot perform a night action', () => {
  assert.equal(chooseNightAction({ role: 'citizen', selfId: 'c1', players: [{ id: 'c1', alive: true }] }), null);
});

test('vote strategy prioritizes known mafia', () => {
  const players = [{ id: 'a', alive: true }, { id: 'b', alive: true }];
  assert.equal(chooseVote({ selfId: 'self', players, knownMafiaIds: ['b'], random: () => 0 }), 'b');
});

test('moderation blocks empty messages and accepts ordinary text', () => {
  assert.equal(moderateChat(' ').allowed, false);
  assert.equal(moderateChat('سلام، وقت بخیر').allowed, true);
});

test('assistant answers wallet questions without claiming to change balances', () => {
  const result = answerQuestion('چطور الماس بخرم؟');
  assert.match(result.answer, /هیچ سکه، الماس/);
});
