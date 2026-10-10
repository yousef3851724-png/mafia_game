'use strict';

// Explainable rules-based screening baseline; not a trained AI model.
// All recommendations require review by an authorized human.
const SEVERITY = Object.freeze({ low: 1, medium: 2, high: 3, critical: 4 });

function assessPlayerHealth(input) {
  const value = input && typeof input === 'object' ? input : {};
  const gamesReviewed = Math.max(0, Number.isInteger(value.gamesReviewed) ? value.gamesReviewed : 0);
  const confirmedViolations = Array.isArray(value.confirmedViolations) ? value.confirmedViolations : [];
  const unresolvedReports = Math.max(0, Number.isInteger(value.unresolvedReports) ? value.unresolvedReports : 0);
  const completedGames = Math.max(0, Number.isInteger(value.completedGames) ? value.completedGames : 0);
  const reasons = [];
  let riskScore = 0;
  for (const item of confirmedViolations) {
    if (!item || typeof item !== 'object' || !Object.hasOwn(SEVERITY, item.severity)) continue;
    riskScore += SEVERITY[item.severity];
    reasons.push({
      code: 'CONFIRMED_VIOLATION',
      severity: item.severity,
      detail: typeof item.detail === 'string' ? item.detail.slice(0, 240) : 'تخلف تأییدشده'
    });
  }
  const sufficientHistory = gamesReviewed >= 10 && completedGames >= 5;
  let recommendation = 'insufficient_data';
  if (sufficientHistory) {
    if (riskScore >= 8) recommendation = 'not_recommended_pending_human_review';
    else if (riskScore >= 3) recommendation = 'manual_review';
    else recommendation = 'no_major_confirmed_risk_found';
  }
  return {
    riskScore, recommendation, confidence: sufficientHistory ? 'medium' : 'low',
    gamesReviewed, completedGames, confirmedViolationCount: reasons.length,
    unresolvedReports, unresolvedReportsExcludedFromRiskScore: true, reasons,
    requiresHumanDecision: true
  };
}
module.exports = { assessPlayerHealth };
