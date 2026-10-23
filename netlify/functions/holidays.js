// Netlify Function: retrieve published Kuala Lumpur holidays without exposing private planner data.
exports.handler = async (event) => {
  const year = Number(event.queryStringParameters?.year);
  if (!Number.isInteger(year) || year < 2000 || year > 2100)
    return { statusCode: 400, body: JSON.stringify({ error: 'Year must be 2000–2100' }) };
  try {
    const url = `https://malaysia-holiday.dydxsoft.my/api/v1/holidays?year=${year}&state=KUL`;
    const response = await fetch(url, {headers:{Accept:'application/json'},signal:AbortSignal.timeout(12000)});
    if (!response.ok) throw new Error(`Provider status ${response.status}`);
    const payload = await response.json();
    if (!Array.isArray(payload.data)) throw new Error('Invalid provider response');
    const holidays = payload.data
      .filter(h => /^\d{4}-\d{2}-\d{2}$/.test(h.date) && typeof h.name === 'string')
      .map(h => ({date:h.date,name:h.name,provisional:Boolean(h.is_subject_to_change)}));
    return {statusCode:200,headers:{'Content-Type':'application/json','Cache-Control':'public, max-age=3600'},body:JSON.stringify({source:'Malaysia Holiday API (KUL)',holidays})};
  } catch (e) {
    return {statusCode:502,headers:{'Content-Type':'application/json'},body:JSON.stringify({error:'Holiday feed temporarily unavailable'})};
  }
};
