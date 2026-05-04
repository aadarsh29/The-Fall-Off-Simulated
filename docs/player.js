/* ─── Element references ─────────────────────────────────── */
const audios = [document.getElementById('audio-0'), document.getElementById('audio-1')];
const fills  = [document.getElementById('fill-0'),  document.getElementById('fill-1')];
const curs   = [document.getElementById('cur-0'),   document.getElementById('cur-1')];
const durs   = [document.getElementById('dur-0'),   document.getElementById('dur-1')];
const btns   = [document.getElementById('btn-0'),   document.getElementById('btn-1')];
const cards  = [document.getElementById('card-0'),  document.getElementById('card-1')];
const vizzes = [document.getElementById('viz-0'),   document.getElementById('viz-1')];

/* ─── Build decorative waveform bars ─────────────────────── */
vizzes.forEach((viz) => {
  const BAR_COUNT = 60;
  for (let b = 0; b < BAR_COUNT; b++) {
    const bar = document.createElement('div');
    bar.className = 'bar';
    bar.style.height = Math.max(12, Math.random() * 100) + '%';
    bar.style.setProperty('--dur', (0.25 + Math.random() * 0.5).toFixed(2) + 's');
    bar.style.animationDelay = (Math.random() * 0.4).toFixed(2) + 's';
    viz.appendChild(bar);
  }
});

/* ─── Helpers ────────────────────────────────────────────── */
function fmt(seconds) {
  const m   = Math.floor(seconds / 60);
  const sec = Math.floor(seconds % 60).toString().padStart(2, '0');
  return `${m}:${sec}`;
}

function resetPlayer(i) {
  audios[i].pause();
  btns[i].innerHTML = '&#9654;';
  cards[i].classList.remove('active');
}

/* ─── Audio event listeners ──────────────────────────────── */
audios.forEach((audio, i) => {
  audio.addEventListener('loadedmetadata', () => {
    durs[i].textContent = fmt(audio.duration);
  });

  audio.addEventListener('timeupdate', () => {
    if (!audio.duration) return;
    fills[i].style.width = (audio.currentTime / audio.duration) * 100 + '%';
    curs[i].textContent  = fmt(audio.currentTime);
  });

  audio.addEventListener('ended', () => {
    resetPlayer(i);
    fills[i].style.width = '0%';
    curs[i].textContent  = '0:00';
  });
});

/* ─── Play / pause ───────────────────────────────────────── */
function togglePlay(i) {
  const other = 1 - i;

  if (!audios[i].paused) {
    resetPlayer(i);
  } else {
    resetPlayer(other);
    audios[i].play();
    btns[i].innerHTML = '&#9646;&#9646;';
    cards[i].classList.add('active');
  }
}

/* ─── Seek on progress bar click ────────────────────────── */
function seek(event, i) {
  const rect = event.currentTarget.getBoundingClientRect();
  const pct  = (event.clientX - rect.left) / rect.width;
  audios[i].currentTime = pct * audios[i].duration;
}
