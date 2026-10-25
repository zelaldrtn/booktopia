// ==============================================================================
// BOOKTOPIA: High-Fidelity Ambient Soundscapes Synthesizer (Web Audio API)
// Profesyonel, temiz, boğukluk ve cızırtıdan arındırılmış dinamik ses motoru.
// Telif hakkı gerektirmeyen, sıfır ağ gecikmeli saf prosedürel ses sentezleyici.
// ==============================================================================

(function () {
  let audioCtx = null;
  let masterCompressor = null;
  const activeSounds = {};

  function getAudioContext() {
    if (!audioCtx) {
      const AudioContextClass = window.AudioContext || window.webkitAudioContext;
      if (AudioContextClass) {
        audioCtx = new AudioContextClass();

        // Çıkışta ses patlamalarını ve kırılmaları önleyen stüdyo kompresörü (Limiter)
        masterCompressor = audioCtx.createDynamicsCompressor();
        masterCompressor.threshold.setValueAtTime(-18, audioCtx.currentTime);
        masterCompressor.knee.setValueAtTime(12, audioCtx.currentTime);
        masterCompressor.ratio.setValueAtTime(6, audioCtx.currentTime);
        masterCompressor.attack.setValueAtTime(0.003, audioCtx.currentTime);
        masterCompressor.release.setValueAtTime(0.25, audioCtx.currentTime);
        masterCompressor.connect(audioCtx.destination);
      }
    }
    if (audioCtx && audioCtx.state === 'suspended') {
      audioCtx.resume();
    }
    return audioCtx;
  }

  // Yüksek kaliteli gürültü tamponları (Pink ve Brown noise)
  function createNoiseBuffer(ctx, durationSeconds, type) {
    const sampleRate = ctx.sampleRate;
    const bufferSize = sampleRate * durationSeconds;
    const buffer = ctx.createBuffer(2, bufferSize, sampleRate); // Stereo
    const leftData = buffer.getChannelData(0);
    const rightData = buffer.getChannelData(1);

    let b0L = 0, b1L = 0, b2L = 0, b3L = 0, b4L = 0, b5L = 0, b6L = 0;
    let b0R = 0, b1R = 0, b2R = 0, b3R = 0, b4R = 0, b5R = 0, b6R = 0;
    let lastBrownL = 0.0, lastBrownR = 0.0;

    for (let i = 0; i < bufferSize; i++) {
      const whiteL = Math.random() * 2 - 1;
      const whiteR = Math.random() * 2 - 1;

      if (type === 'pink') {
        // Paul Kellet filtresi (pürüzsüz pink noise)
        b0L = 0.99886 * b0L + whiteL * 0.0555179;
        b1L = 0.99332 * b1L + whiteL * 0.0750759;
        b2L = 0.96900 * b2L + whiteL * 0.1538520;
        b3L = 0.86650 * b3L + whiteL * 0.3104856;
        b4L = 0.55000 * b4L + whiteL * 0.5329522;
        b5L = -0.7616 * b5L - whiteL * 0.0168980;
        leftData[i] = (b0L + b1L + b2L + b3L + b4L + b5L + b6L + whiteL * 0.5362) * 0.09;
        b6L = whiteL * 0.115926;

        b0R = 0.99886 * b0R + whiteR * 0.0555179;
        b1R = 0.99332 * b1R + whiteR * 0.0750759;
        b2R = 0.96900 * b2R + whiteR * 0.1538520;
        b3R = 0.86650 * b3R + whiteR * 0.3104856;
        b4R = 0.55000 * b4R + whiteR * 0.5329522;
        b5R = -0.7616 * b5R - whiteR * 0.0168980;
        rightData[i] = (b0R + b1R + b2R + b3R + b4R + b5R + b6R + whiteR * 0.5362) * 0.09;
        b6R = whiteR * 0.115926;
      } else if (type === 'brown') {
        // Brown noise (Sıcak derin akustik)
        lastBrownL = (lastBrownL + (0.02 * whiteL)) / 1.02;
        leftData[i] = lastBrownL * 3.2;

        lastBrownR = (lastBrownR + (0.02 * whiteR)) / 1.02;
        rightData[i] = lastBrownR * 3.2;
      } else {
        leftData[i] = whiteL * 0.12;
        rightData[i] = whiteR * 0.12;
      }
    }
    return buffer;
  }

  function startSound(id, volume) {
    const ctx = getAudioContext();
    if (!ctx) return;

    if (activeSounds[id]) {
      stopSound(id);
    }

    const masterGain = ctx.createGain();
    const targetGain = Math.max(0.0001, volume * 0.75);
    // Tıklama olmadan yumuşak 40ms açılış (fade-in)
    masterGain.gain.setValueAtTime(0.0001, ctx.currentTime);
    masterGain.gain.exponentialRampToValueAtTime(targetGain, ctx.currentTime + 0.04);
    masterGain.connect(masterCompressor || ctx.destination);

    const soundObj = { masterGain, nodes: [], intervals: [] };

    if (id === 'rain') {
      // 1. HAFIZALI DİNGİN YAĞMUR:
      // Boğuk değil, temiz ve havadar (hava boşluğu + yaprak / pencere tıpırtısı)
      const rainBuffer = createNoiseBuffer(ctx, 4, 'pink');
      const rainSrc = ctx.createBufferSource();
      rainSrc.buffer = rainBuffer;
      rainSrc.loop = true;

      // Geniş frekans bandı: 450Hz ile 3400Hz arası ferah yağmur
      const hpFilter = ctx.createBiquadFilter();
      hpFilter.type = 'highpass';
      hpFilter.frequency.setValueAtTime(420, ctx.currentTime);

      const bpFilter = ctx.createBiquadFilter();
      bpFilter.type = 'bandpass';
      bpFilter.frequency.setValueAtTime(2100, ctx.currentTime);
      bpFilter.Q.setValueAtTime(0.85, ctx.currentTime);

      // Doğal hava esintisi (0.12 Hz LFO ile dalgalanma)
      const lfo = ctx.createOscillator();
      lfo.frequency.setValueAtTime(0.12, ctx.currentTime);
      const lfoGain = ctx.createGain();
      lfoGain.gain.setValueAtTime(300, ctx.currentTime);
      lfo.connect(bpFilter.frequency);
      lfo.start();

      rainSrc.connect(hpFilter);
      hpFilter.connect(bpFilter);
      bpFilter.connect(masterGain);
      rainSrc.start();
      soundObj.nodes.push(rainSrc, lfo);

      // Rastgele yumuşak damla tıklamaları (Damla hissi)
      const dropInterval = setInterval(() => {
        if (!activeSounds[id]) return;
        if (Math.random() < 0.45) {
          const dropOsc = ctx.createOscillator();
          const dropGain = ctx.createGain();
          const freq = 1200 + Math.random() * 800;
          dropOsc.frequency.setValueAtTime(freq, ctx.currentTime);
          dropOsc.frequency.exponentialRampToValueAtTime(freq * 0.7, ctx.currentTime + 0.035);

          const dropVol = (Math.random() * 0.08 + 0.03);
          dropGain.gain.setValueAtTime(dropVol, ctx.currentTime);
          dropGain.gain.exponentialRampToValueAtTime(0.0001, ctx.currentTime + 0.035);

          dropOsc.connect(dropGain);
          dropGain.connect(masterGain);
          dropOsc.start();
          dropOsc.stop(ctx.currentTime + 0.04);
        }
      }, 140);
      soundObj.intervals.push(dropInterval);

    } else if (id === 'fireplace') {
      // 2. MEŞE ŞÖMİNESİ:
      // Boğuk bir uğultu yerine sıcak bir dip tınısı + gerçekçi çıtırtı ve kor kıvılcımları
      const rumbleBuffer = createNoiseBuffer(ctx, 4, 'brown');
      const rumbleSrc = ctx.createBufferSource();
      rumbleSrc.buffer = rumbleBuffer;
      rumbleSrc.loop = true;

      const rumbleFilter = ctx.createBiquadFilter();
      rumbleFilter.type = 'lowpass';
      rumbleFilter.frequency.setValueAtTime(320, ctx.currentTime);

      const rumbleGain = ctx.createGain();
      rumbleGain.gain.setValueAtTime(0.4, ctx.currentTime);

      rumbleSrc.connect(rumbleFilter);
      rumbleFilter.connect(rumbleGain);
      rumbleGain.connect(masterGain);
      rumbleSrc.start();
      soundObj.nodes.push(rumbleSrc);

      // Gerçekçi Poisson odun çıtırtıları
      const crackleInterval = setInterval(() => {
        if (!activeSounds[id]) return;
        if (Math.random() < 0.6) {
          const crackleSrc = ctx.createBufferSource();
          const duration = 0.02 + Math.random() * 0.03;
          const len = Math.floor(ctx.sampleRate * duration);
          const crackleBuf = ctx.createBuffer(1, len, ctx.sampleRate);
          const data = crackleBuf.getChannelData(0);
          for (let k = 0; k < len; k++) {
            data[k] = (Math.random() * 2 - 1) * Math.exp(-k / (len * 0.25));
          }
          crackleSrc.buffer = crackleBuf;

          const crackleFilter = ctx.createBiquadFilter();
          crackleFilter.type = 'bandpass';
          crackleFilter.frequency.setValueAtTime(1100 + Math.random() * 1600, ctx.currentTime);
          crackleFilter.Q.setValueAtTime(1.5, ctx.currentTime);

          const crackleGain = ctx.createGain();
          crackleGain.gain.setValueAtTime(Math.random() * 0.35 + 0.08, ctx.currentTime);

          crackleSrc.connect(crackleFilter);
          crackleFilter.connect(crackleGain);
          crackleGain.connect(masterGain);
          crackleSrc.start();
        }
      }, 110);
      soundObj.intervals.push(crackleInterval);

    } else if (id === 'library') {
      // 3. TARİHİ KÜTÜPHANE & DERİN SESSİZLİK:
      // Rahatsız edici sinüs yerine huzurlu akustik oda tonu ve hafif sayfa hissi
      const libBuffer = createNoiseBuffer(ctx, 5, 'brown');
      const libSrc = ctx.createBufferSource();
      libSrc.buffer = libBuffer;
      libSrc.loop = true;

      const libFilter = ctx.createBiquadFilter();
      libFilter.type = 'lowpass';
      libFilter.frequency.setValueAtTime(280, ctx.currentTime);

      const libGain = ctx.createGain();
      libGain.gain.setValueAtTime(0.35, ctx.currentTime);

      libSrc.connect(libFilter);
      libFilter.connect(libGain);
      libGain.connect(masterGain);
      libSrc.start();
      soundObj.nodes.push(libSrc);

      // Çok yumuşak 432 Hz harmonik dinginlik tınısı (derin odaklanma)
      const toneOsc = ctx.createOscillator();
      toneOsc.type = 'sine';
      toneOsc.frequency.setValueAtTime(432.0, ctx.currentTime);
      const toneGain = ctx.createGain();
      toneGain.gain.setValueAtTime(0.012, ctx.currentTime); // Çok kısık, dinlendirici
      toneOsc.connect(toneGain);
      toneGain.connect(masterGain);
      toneOsc.start();
      soundObj.nodes.push(toneOsc);

    } else if (id === 'cafe') {
      // 4. SAKİN KİTAP KAFESİ:
      // Sıcak akustik ortam tınısı ve uzak porselen fincan dokunuşları
      const cafeBuffer = createNoiseBuffer(ctx, 4, 'pink');
      const cafeSrc = ctx.createBufferSource();
      cafeSrc.buffer = cafeBuffer;
      cafeSrc.loop = true;

      const formant1 = ctx.createBiquadFilter();
      formant1.type = 'bandpass';
      formant1.frequency.setValueAtTime(450, ctx.currentTime);
      formant1.Q.setValueAtTime(1.2, ctx.currentTime);

      const formant2 = ctx.createBiquadFilter();
      formant2.type = 'bandpass';
      formant2.frequency.setValueAtTime(1350, ctx.currentTime);
      formant2.Q.setValueAtTime(1.0, ctx.currentTime);

      const cafeGain = ctx.createGain();
      cafeGain.gain.setValueAtTime(0.4, ctx.currentTime);

      cafeSrc.connect(formant1);
      formant1.connect(cafeGain);
      cafeGain.connect(masterGain);

      cafeSrc.connect(formant2);
      formant2.connect(cafeGain);

      cafeSrc.start();
      soundObj.nodes.push(cafeSrc);

      // Ara sıra uzaktan gelen porselen tınısı
      const cupInterval = setInterval(() => {
        if (!activeSounds[id]) return;
        if (Math.random() < 0.25) {
          const cupOsc = ctx.createOscillator();
          const cupGain = ctx.createGain();
          cupOsc.type = 'sine';
          cupOsc.frequency.setValueAtTime(2600 + Math.random() * 400, ctx.currentTime);

          cupGain.gain.setValueAtTime(0.025, ctx.currentTime);
          cupGain.gain.exponentialRampToValueAtTime(0.0001, ctx.currentTime + 0.12);

          cupOsc.connect(cupGain);
          cupGain.connect(masterGain);
          cupOsc.start();
          cupOsc.stop(ctx.currentTime + 0.14);
        }
      }, 800);
      soundObj.intervals.push(cupInterval);
    }

    activeSounds[id] = soundObj;
  }

  function stopSound(id) {
    const soundObj = activeSounds[id];
    if (soundObj) {
      soundObj.intervals.forEach(clearInterval);
      const ctx = getAudioContext();
      if (ctx && soundObj.masterGain) {
        // Yumuşak fade-out (tıklama veya çatırtı yapmadan)
        try {
          soundObj.masterGain.gain.cancelScheduledValues(ctx.currentTime);
          soundObj.masterGain.gain.setValueAtTime(soundObj.masterGain.gain.value, ctx.currentTime);
          soundObj.masterGain.gain.exponentialRampToValueAtTime(0.0001, ctx.currentTime + 0.04);
        } catch (_) {}
      }

      setTimeout(() => {
        soundObj.nodes.forEach(n => {
          try { n.stop(); } catch (e) {}
        });
      }, 50);

      delete activeSounds[id];
    }
  }

  function setVolume(id, volume) {
    const soundObj = activeSounds[id];
    if (soundObj && soundObj.masterGain) {
      const ctx = getAudioContext();
      if (ctx) {
        const targetGain = Math.max(0.0001, volume * 0.75);
        soundObj.masterGain.gain.cancelScheduledValues(ctx.currentTime);
        soundObj.masterGain.gain.setValueAtTime(soundObj.masterGain.gain.value, ctx.currentTime);
        soundObj.masterGain.gain.linearRampToValueAtTime(targetGain, ctx.currentTime + 0.03);
      }
    }
  }

  function isAudioSupported() {
    return !!(window.AudioContext || window.webkitAudioContext);
  }

  window.booktopiaPlayAudio = startSound;
  window.booktopiaStopAudio = stopSound;
  window.booktopiaSetAudioVolume = setVolume;
  window.booktopiaIsAudioSupported = isAudioSupported;
})();
