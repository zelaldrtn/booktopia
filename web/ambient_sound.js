// Booktopia Web Audio Ambient Soundscapes Synthesizer
(function () {
  let audioCtx = null;
  const activeSounds = {};

  function getAudioContext() {
    if (!audioCtx) {
      const AudioContextClass = window.AudioContext || window.webkitAudioContext;
      if (AudioContextClass) {
        audioCtx = new AudioContextClass();
      }
    }
    if (audioCtx && audioCtx.state === 'suspended') {
      audioCtx.resume();
    }
    return audioCtx;
  }

  // Generates continuous noise buffer
  function createNoiseBuffer(ctx, durationSeconds, type) {
    const sampleRate = ctx.sampleRate;
    const bufferSize = sampleRate * durationSeconds;
    const buffer = ctx.createBuffer(1, bufferSize, sampleRate);
    const data = buffer.getChannelData(0);

    let b0 = 0, b1 = 0, b2 = 0, b3 = 0, b4 = 0, b5 = 0, b6 = 0;
    let lastBrown = 0.0;

    for (let i = 0; i < bufferSize; i++) {
      const white = Math.random() * 2 - 1;

      if (type === 'pink') {
        b0 = 0.99886 * b0 + white * 0.0555179;
        b1 = 0.99332 * b1 + white * 0.0750759;
        b2 = 0.96900 * b2 + white * 0.1538520;
        b3 = 0.86650 * b3 + white * 0.3104856;
        b4 = 0.55000 * b4 + white * 0.5329522;
        b5 = -0.7616 * b5 - white * 0.0168980;
        data[i] = (b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362) * 0.08;
        b6 = white * 0.115926;
      } else if (type === 'brown') {
        data[i] = (lastBrown + (0.02 * white)) / 1.02;
        lastBrown = data[i];
        data[i] *= 2.8;
      } else {
        data[i] = white * 0.15;
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
    masterGain.gain.setValueAtTime(volume * 0.65, ctx.currentTime);
    masterGain.connect(ctx.destination);

    const soundObj = { masterGain, nodes: [], intervals: [] };

    if (id === 'rain') {
      // Steady gentle rainfall: filtered pink noise with dynamic rain gusts
      const rainBuffer = createNoiseBuffer(ctx, 4, 'pink');
      const rainSrc = ctx.createBufferSource();
      rainSrc.buffer = rainBuffer;
      rainSrc.loop = true;

      const lpFilter = ctx.createBiquadFilter();
      lpFilter.type = 'lowpass';
      lpFilter.frequency.setValueAtTime(1400, ctx.currentTime);

      const hpFilter = ctx.createBiquadFilter();
      hpFilter.type = 'highpass';
      hpFilter.frequency.setValueAtTime(300, ctx.currentTime);

      rainSrc.connect(lpFilter);
      lpFilter.connect(hpFilter);
      hpFilter.connect(masterGain);
      rainSrc.start();
      soundObj.nodes.push(rainSrc);
    } else if (id === 'fireplace') {
      // Warm fireplace: low-frequency rumble + periodic crackle pops
      const rumbleBuffer = createNoiseBuffer(ctx, 4, 'brown');
      const rumbleSrc = ctx.createBufferSource();
      rumbleSrc.buffer = rumbleBuffer;
      rumbleSrc.loop = true;

      const rumbleFilter = ctx.createBiquadFilter();
      rumbleFilter.type = 'lowpass';
      rumbleFilter.frequency.setValueAtTime(220, ctx.currentTime);

      rumbleSrc.connect(rumbleFilter);
      rumbleFilter.connect(masterGain);
      rumbleSrc.start();
      soundObj.nodes.push(rumbleSrc);

      // Realistic crackle clicks
      const crackleInterval = setInterval(() => {
        if (!activeSounds[id]) return;
        if (Math.random() < 0.65) {
          const crackleSrc = ctx.createBufferSource();
          const len = Math.floor(ctx.sampleRate * 0.035);
          const crackleBuf = ctx.createBuffer(1, len, ctx.sampleRate);
          const crackleData = crackleBuf.getChannelData(0);
          for (let k = 0; k < len; k++) {
            crackleData[k] = (Math.random() * 2 - 1) * Math.exp(-k / 150);
          }
          crackleSrc.buffer = crackleBuf;
          const crackleGain = ctx.createGain();
          crackleGain.gain.setValueAtTime((Math.random() * 0.45 + 0.1), ctx.currentTime);
          crackleSrc.connect(crackleGain);
          crackleGain.connect(masterGain);
          crackleSrc.start();
        }
      }, 100);
      soundObj.intervals.push(crackleInterval);
    } else if (id === 'library') {
      // Old Library: Warm room presence and subtle calming tone
      const libBuffer = createNoiseBuffer(ctx, 5, 'brown');
      const libSrc = ctx.createBufferSource();
      libSrc.buffer = libBuffer;
      libSrc.loop = true;

      const libFilter = ctx.createBiquadFilter();
      libFilter.type = 'lowpass';
      libFilter.frequency.setValueAtTime(260, ctx.currentTime);

      libSrc.connect(libFilter);
      libFilter.connect(masterGain);
      libSrc.start();
      soundObj.nodes.push(libSrc);

      // Relaxing 136.1 Hz binaural meditation undertone
      const toneOsc = ctx.createOscillator();
      toneOsc.type = 'sine';
      toneOsc.frequency.setValueAtTime(136.1, ctx.currentTime);
      const toneGain = ctx.createGain();
      toneGain.gain.setValueAtTime(0.04, ctx.currentTime);
      toneOsc.connect(toneGain);
      toneGain.connect(masterGain);
      toneOsc.start();
      soundObj.nodes.push(toneOsc);
    } else if (id === 'cafe') {
      // Quiet Cafe: Soft ambient background hum
      const cafeBuffer = createNoiseBuffer(ctx, 4, 'pink');
      const cafeSrc = ctx.createBufferSource();
      cafeSrc.buffer = cafeBuffer;
      cafeSrc.loop = true;

      const cafeFilter = ctx.createBiquadFilter();
      cafeFilter.type = 'bandpass';
      cafeFilter.frequency.setValueAtTime(550, ctx.currentTime);
      cafeFilter.Q.setValueAtTime(0.6, ctx.currentTime);

      cafeSrc.connect(cafeFilter);
      cafeFilter.connect(masterGain);
      cafeSrc.start();
      soundObj.nodes.push(cafeSrc);
    }

    activeSounds[id] = soundObj;
  }

  function stopSound(id) {
    const soundObj = activeSounds[id];
    if (soundObj) {
      soundObj.intervals.forEach(clearInterval);
      soundObj.nodes.forEach(n => {
        try { n.stop(); } catch (e) {}
      });
      delete activeSounds[id];
    }
  }

  function setVolume(id, volume) {
    const soundObj = activeSounds[id];
    if (soundObj && soundObj.masterGain) {
      const ctx = getAudioContext();
      if (ctx) {
        soundObj.masterGain.gain.setValueAtTime(volume * 0.65, ctx.currentTime);
      }
    }
  }

  window.booktopiaPlayAudio = startSound;
  window.booktopiaStopAudio = stopSound;
  window.booktopiaSetAudioVolume = setVolume;
})();
