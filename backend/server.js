'use strict';
const http = require('node:http');
const { WebSocketServer, WebSocket } = require('ws');

const PORT = Number(process.env.PORT || 8080);
const MAX_PLAYERS = Math.max(3, Math.min(20, Number(process.env.MAX_PLAYERS_PER_ROOM || 20)));
const MIN_PLAYERS = Math.max(3, Math.min(MAX_PLAYERS, Number(process.env.MIN_PLAYERS_TO_START || 5)));
const DURATIONS = { night: Number(process.env.NIGHT_SECONDS || 30), day: Number(process.env.DAY_SECONDS || 45), voting: Number(process.env.VOTING_SECONDS || 30) };
const rooms = new Map(), clients = new Map();
const server = http.createServer((req, res) => {
  if (req.url === '/' || req.url === '/health') {
    res.writeHead(200, { 'content-type': 'application/json; charset=utf-8', 'cache-control': 'no-store' });
    return res.end(JSON.stringify({ service: 'mafia-radical-backend', status: 'ok', websocket: 'available', rooms: rooms.size }));
  }
  res.writeHead(404, { 'content-type': 'application/json; charset=utf-8' }); res.end(JSON.stringify({ error: 'not_found' }));
});
const wss = new WebSocketServer({ server, maxPayload: 16 * 1024 });
const send = (ws, x) => { if (ws.readyState === WebSocket.OPEN) ws.send(JSON.stringify(x)); };
const err = (ws, message, code = 'invalid_action') => send(ws, { type: 'error', code, message });
function roomFor(id) {
  if (!rooms.has(id)) rooms.set(id, { id, players: new Map(), phase: 'lobby', round: 0, votes: new Map(), actions: new Map(), doctorTarget: null, timer: null, deadline: null, lastEvent: null });
  return rooms.get(id);
}
function stopTimer(r) { if (r.timer) clearTimeout(r.timer); r.timer = null; r.deadline = null; }
function broadcast(r, x) { for (const p of r.players.values()) send(p.ws, x); }
function publicPlayers(r, reveal = false) {
  return [...r.players.values()].map(p => ({ id: p.id, name: p.name, isHost: p.isHost, ready: p.ready, seat: p.seat, alive: p.alive, ...(reveal ? { role: p.role } : {}), votesAgainst: [...r.votes.values()].filter(id => id === p.id).length, hasActed: r.phase === 'night' ? r.actions.has(p.id) : r.votes.has(p.id) }));
}
function broadcastPlayers(r) { broadcast(r, { type: 'players', players: publicPlayers(r) }); }
function state(r, p) { return { type: 'game_state', phase: r.phase, round: r.round, seconds: r.deadline ? Math.max(0, Math.ceil((r.deadline - Date.now()) / 1000)) : 0, players: publicPlayers(r, r.phase === 'ended'), myRole: p.role || null, myTarget: r.votes.get(p.id) || r.actions.get(p.id) || null, message: r.lastEvent }; }
function sendStates(r) { for (const p of r.players.values()) send(p.ws, state(r, p)); }
function phase(r, name, seconds, message) {
  r.phase = name; r.deadline = seconds > 0 ? Date.now() + seconds * 1000 : null; r.lastEvent = message || null;
  broadcast(r, { type: 'phase_changed', phase: name, round: r.round, seconds, message: r.lastEvent });
  broadcastPlayers(r); sendStates(r);
}
function timer(r, seconds, fn) { stopTimer(r); r.deadline = Date.now() + seconds * 1000; r.timer = setTimeout(fn, seconds * 1000); r.timer.unref?.(); }
function finish(r, winner, message) {
  stopTimer(r); r.phase = 'ended'; r.lastEvent = message;
  broadcast(r, { type: 'phase_changed', phase: 'ended', round: r.round, seconds: 0, message });
  broadcast(r, { type: 'game_over', winner, message }); sendStates(r); broadcastPlayers(r);
}
function winnerCheck(r) {
  const alive = [...r.players.values()].filter(p => p.alive), mafia = alive.filter(p => p.role === 'mafia').length;
  if (!mafia) { finish(r, 'citizens', 'شهروندان برنده شدند.'); return true; }
  if (mafia >= alive.length - mafia) { finish(r, 'mafia', 'مافیا برنده شد.'); return true; }
  return false;
}
function beginNight(r) {
  if (r.phase === 'ended') return;
  r.round++; r.votes.clear(); r.actions.clear(); r.doctorTarget = null;
  phase(r, 'night', DURATIONS.night, 'شب فرا رسید.');
  timer(r, DURATIONS.night, () => resolveNight(r));
}
function resolveNight(r) {
  if (r.phase !== 'night') return;
  const targets = [...r.actions.entries()].filter(([id, target]) => target && r.players.get(id)?.alive && r.players.get(id)?.role === 'mafia').map(([, target]) => target);
  const counts = new Map(); targets.forEach(id => counts.set(id, (counts.get(id) || 0) + 1));
  const top = [...counts.entries()].sort((a,b) => b[1]-a[1]);
  const victim = top.length && (!top[1] || top[0][1] > top[1][1]) ? top[0][0] : null;
  if (victim && victim !== r.doctorTarget) { const p = r.players.get(victim); if (p) p.alive = false; r.lastEvent = 'صبح شد؛ یک بازیکن از بازی خارج شد.'; }
  else r.lastEvent = 'صبح شد؛ کسی از بازی خارج نشد.';
  if (winnerCheck(r)) return;
  phase(r, 'day', DURATIONS.day, r.lastEvent); timer(r, DURATIONS.day, () => beginVoting(r));
}
function beginVoting(r) { if (r.phase !== 'day') return; r.votes.clear(); phase(r, 'voting', DURATIONS.voting, 'رأی‌گیری آغاز شد.'); timer(r, DURATIONS.voting, () => resolveVoting(r)); }
function resolveVoting(r) {
  if (r.phase !== 'voting') return;
  const counts = new Map();
  for (const [voter, target] of r.votes) if (target && r.players.get(voter)?.alive && r.players.get(target)?.alive) counts.set(target, (counts.get(target)||0)+1);
  const max = Math.max(0, ...counts.values()), leaders = [...counts].filter(([,n]) => n === max && max > 0).map(([id])=>id);
  let message = 'رأی‌گیری بدون اخراج پایان یافت.';
  if (leaders.length === 1) { r.players.get(leaders[0]).alive = false; message = 'یک بازیکن با رأی شهر از بازی خارج شد.'; }
  else if (leaders.length > 1) message = 'رأی‌ها مساوی شد؛ کسی اخراج نشد.';
  if (winnerCheck(r)) return;
  phase(r, 'result', 3, message); timer(r, 3000, () => beginNight(r));
}
function startGame(r) {
  const ps = [...r.players.values()], mafiaCount = Math.max(1, Math.floor(ps.length / 4));
  if (ps.length < MIN_PLAYERS || ps.some(p => !p.ready) || r.phase !== 'lobby') return false;
  const roles = [...Array(mafiaCount).fill('mafia'), ...(ps.length >= 5 ? ['doctor','detective'] : [] )];
  while (roles.length < ps.length) roles.push('citizen');
  for (let i=roles.length-1;i>0;i--) { const j=Math.floor(Math.random()*(i+1)); [roles[i],roles[j]]=[roles[j],roles[i]]; }
  ps.forEach((p,i)=>{p.role=roles[i];p.alive=true;});
  r.round=0; beginNight(r); return true;
}
function remove(ws) {
  const c=clients.get(ws); if(!c)return; clients.delete(ws);
  const r=rooms.get(c.roomId), p=r?.players.get(c.playerId);
  if(!r)return;
  if(p?.ws===ws) r.players.delete(c.playerId);
  if(!r.players.size){stopTimer(r);rooms.delete(c.roomId);return;}
  if(![...r.players.values()].some(x=>x.isHost))[...r.players.values()][0].isHost=true;
  broadcastPlayers(r); if(r.phase!=='lobby'&&r.phase!=='ended')sendStates(r);
}
function join(ws,d) {
  const roomId=String(d.roomId||'').trim().slice(0,80), id=String(d.playerId||'').trim().slice(0,80);
  if(!roomId||!id)return err(ws,'roomId و playerId الزامی هستند.','bad_request');
  if(clients.has(ws))return err(ws,'این اتصال قبلاً وارد اتاق شده است.');
  const r=roomFor(roomId), old=r.players.get(id);
  if(r.phase!=='lobby'&&!old)return err(ws,'بازی شروع شده و ورود بازیکن جدید بسته است.');
  if(!old&&r.players.size>=MAX_PLAYERS)return err(ws,'ظرفیت اتاق تکمیل است.');
  if(old&&old.ws!==ws){clients.delete(old.ws);send(old.ws,{type:'replaced'});old.ws.close(4001,'replaced');}
  const p=old||{id,name:'بازیکن',isHost:r.players.size===0,ready:false,seat:r.players.size,alive:true,role:null,ws};
  p.ws=ws;p.name=String(d.name||p.name||'بازیکن').trim().slice(0,40);r.players.set(id,p);
  clients.set(ws,{roomId,playerId:id,rate:[]});
  send(ws,{type:'joined',roomId,playerId:id,isHost:p.isHost});broadcastPlayers(r);
  if(r.phase!=='lobby')send(ws,state(r,p));
}
function handle(ws,raw) {
  let d; try{d=JSON.parse(raw.toString());}catch{return err(ws,'فرمت پیام معتبر نیست.','bad_json');}
  if(!d||typeof d.type!=='string')return err(ws,'نوع پیام مشخص نشده است.','bad_request');
  let c=clients.get(ws);
  if(c){const now=Date.now();c.rate=c.rate.filter(t=>now-t<10000);if(c.rate.length>=40)return err(ws,'تعداد پیام‌ها بیش از حد مجاز است.','rate_limited');c.rate.push(now);}
  if(d.type==='join'||d.type==='game_join')return join(ws,d);
  if(!c)return err(ws,'ابتدا باید وارد اتاق شوید.','not_joined');
  const r=rooms.get(c.roomId),p=r?.players.get(c.playerId);
  if(!r||!p||p.ws!==ws)return err(ws,'اتاق یا بازیکن پیدا نشد.','not_found');
  switch(d.type){
    case 'ready': if(r.phase!=='lobby')return err(ws,'بازی شروع شده است.');p.ready=Boolean(d.value);broadcastPlayers(r);break;
    case 'seat': {if(r.phase!=='lobby')return err(ws,'تغییر صندلی پس از شروع مجاز نیست.');const s=Number(d.seat);if(!Number.isInteger(s)||s<0||s>=MAX_PLAYERS)return err(ws,'شماره صندلی معتبر نیست.');const o=[...r.players.values()].find(x=>x.seat===s&&x.id!==p.id);if(o)o.seat=p.seat;p.seat=s;broadcastPlayers(r);break;}
    case 'chat': {const text=String(d.text||'').trim().slice(0,500);if(!text)break;if(r.phase!=='lobby'&&!['day','voting'].includes(r.phase))return err(ws,'چت در این مرحله غیرفعال است.');if(r.phase!=='lobby'&&!p.alive)return err(ws,'بازیکن حذف‌شده نمی‌تواند پیام بدهد.');broadcast(r,{type:'chat',playerId:p.id,name:p.name,text,sentAt:new Date().toISOString()});break;}
    case 'kick': {if(r.phase!=='lobby'||!p.isHost)return err(ws,'فقط میزبان در لابی می‌تواند اخراج کند.');const t=r.players.get(String(d.playerId));if(!t||t.id===p.id)return err(ws,'بازیکن هدف معتبر نیست.');send(t.ws,{type:'error',code:'kicked',message:'از اتاق اخراج شدید.'});t.ws.close(4002,'kicked');remove(t.ws);break;}
    case 'start': if(!p.isHost)return err(ws,'فقط میزبان می‌تواند بازی را شروع کند.');if(!startGame(r))return err(ws, 'حداقل بازیکنان لازم باید حاضر و همگی آماده باشند.');break;
    case 'vote': {if(r.phase!=='voting'||!p.alive)return err(ws,'در حال حاضر امکان رأی‌دادن ندارید.');const id=String(d.targetId||'');const t=r.players.get(id);if(!t||!t.alive||id===p.id)return err(ws,'هدف رأی معتبر نیست.');r.votes.set(p.id,id);broadcastPlayers(r);sendStates(r);if([...r.players.values()].filter(x=>x.alive).every(x=>r.votes.has(x.id)))resolveVoting(r);break;}
    case 'night_action': {if(r.phase!=='night'||!p.alive)return err(ws,'اکشن شب فعال نیست.');const id=String(d.targetId||''),t=r.players.get(id);if(!t||!t.alive)return err(ws,'هدف اکشن معتبر نیست.');if(p.role==='mafia'){if(t.role==='mafia')return err(ws,'مافیا نمی‌تواند هم‌تیمی خود را هدف بگیرد.');r.actions.set(p.id,id);}else if(p.role==='doctor'){r.doctorTarget=id;r.actions.set(p.id,id);}else if(p.role==='detective'){r.actions.set(p.id,id);send(ws,{type:'investigation_result',targetId:id,isMafia:t.role==='mafia',message:t.role==='mafia'?'نتیجه بررسی: مافیا است.':'نتیجه بررسی: مافیا نیست.'});}else return err(ws,'نقش شما اکشن شب ندارد.');broadcastPlayers(r);sendStates(r);const living=[...r.players.values()].filter(x=>x.alive);if(living.filter(x=>x.role==='mafia').every(x=>r.actions.has(x.id))&&living.filter(x=>['doctor','detective'].includes(x.role)).every(x=>r.actions.has(x.id)))resolveNight(r);break;}
    case 'skip': if(r.phase==='voting'&&p.alive){r.votes.set(p.id,'');if([...r.players.values()].filter(x=>x.alive).every(x=>r.votes.has(x.id)))resolveVoting(r);}else if(r.phase==='night'&&['doctor','detective'].includes(p.role)){r.actions.set(p.id,'');const living=[...r.players.values()].filter(x=>x.alive);if(living.filter(x=>x.role==='mafia').every(x=>r.actions.has(x.id))&&living.filter(x=>['doctor','detective'].includes(x.role)).every(x=>r.actions.has(x.id)))resolveNight(r);}else return err(ws,'رد کردن در این مرحله مجاز نیست.');broadcastPlayers(r);sendStates(r);break;
    default:return err(ws,'نوع پیام پشتیبانی نمی‌شود.','unsupported_message');
  }
}
wss.on('connection',ws=>{ws.on('message',raw=>handle(ws,raw));ws.on('close',()=>remove(ws));ws.on('error',()=>remove(ws));});
server.listen(PORT,'0.0.0.0',()=>console.log(`Mafia Radical backend listening on port ${PORT}`));
function shutdown(){for(const r of rooms.values())stopTimer(r);for(const ws of wss.clients)ws.close(1001,'server_shutdown');server.close(()=>process.exit(0));setTimeout(()=>process.exit(1),5000).unref();}
process.on('SIGTERM',shutdown);process.on('SIGINT',shutdown);
