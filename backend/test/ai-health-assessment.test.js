'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const { assessPlayerHealth } = require('../src/ai-health-assessment');

test('insufficient history does not qualify a player for moderation', () => {
  assert.equal(assessPlayerHealth({ gamesReviewed: 2, completedGames: 1 }).recommendation, 'insufficient_data');
});

test('unresolved reports do not increase confirmed risk score', () => {
  const result = assessPlayerHealth({ gamesReviewed: 12, completedGames: 8, unresolvedReports: 9, confirmedViolations: [] });
  assert.equal(result.riskScore, 0);
  assert.equal(result.recommendation, 'no_major_confirmed_risk_found');
  assert.equal(result.unresolvedReportsExcludedFromRiskScore, true);
});

test('repeated confirmed violations recommend human review, not automatic punishment', () => {
  const result = assessPlayerHealth({
    gamesReviewed: 20, completedGames: 15,
    confirmedViolations: [
      { severity: 'high', detail: 'verified harassment' },
      { severity: 'high', detail: 'verified sabotage' },
      { severity: 'medium', detail: 'verified abuse' }
    ]
  });
  assert.equal(result.recommendation, 'not_recommended_pending_human_review');
  assert.equal(result.confirmedViolationCount, 3);
  assert.equal(result.requiresHumanDecision, true);
});
