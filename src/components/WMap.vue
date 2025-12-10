<template>
  <main>
    <div id="grid-container" ref="gridContainer">
      <canvas id="grid-canvas" ref="gridCanvas"></canvas>
      <div id="waypoints" ref="waypointsRef"></div>
    </div>
  </main>
</template>

<script setup>
import {ref, onMounted, onBeforeUnmount, watch} from 'vue'

  const gridContainer = ref(null)
  const gridCanvas = ref(null)
  const waypointsRef = ref(null)

  onMounted(() => {
    // Configuration
    const CELL_SIZE = 50;

    // DOM, but for Vue
    const container = gridContainer.value;
    const canvas = gridCanvas.value;
    const ctx = canvas.getContext('2d');
    const waypointsLayer = waypointsRef.value;

    // Panning state
    let translateX = 0;
    let translateY = 0;
    let isPanning = false;
    let lastX, lastY;
    function resizeCanvas() {
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
    }

    window.addEventListener('resize', resizeCanvas);
    resizeCanvas(); // Call once on load
    const WAYPOINTS = [
      { name: "Start", x: 0, y: 0 },
      { name: "Alpha", x: 300, y: -200 },
      { name: "Beta", x: -400, y: 500 },
      { name: "Gamma", x: 800, y: 300 }
    ];
    function drawGrid() {
      const w = canvas.width;
      const h = canvas.height;
      ctx.clearRect(0, 0, w, h);

      // Offset so lines move with pan
      const offsetX = translateX % CELL_SIZE;
      const offsetY = translateY % CELL_SIZE;

      ctx.strokeStyle = '#ddd';
      ctx.lineWidth = 1;

      // Vertical lines
      for (let x = offsetX; x <= w; x += CELL_SIZE) {
        ctx.beginPath();
        ctx.moveTo(x, 0);
        ctx.lineTo(x, h);
        ctx.stroke();
      }

      // Horizontal lines
      for (let y = offsetY; y <= h; y += CELL_SIZE) {
        ctx.beginPath();
        ctx.moveTo(0, y);
        ctx.lineTo(w, y);
        ctx.stroke();
      }
    };
    drawGrid();
    watch([translateX, translateY, () => WAYPOINTS.length], renderWaypoints, { deep: true })
    function renderWaypoints() {
      waypointsLayer.innerHTML = '';
      WAYPOINTS.forEach(wp => {
        const screenX = wp.x + translateX;
        const screenY = wp.y + translateY;

        // Optional: skip off-screen waypoints (performance)
        const margin = 200;
        if (
            screenX < -margin || screenX > canvas.width + margin ||
            screenY < -margin || screenY > canvas.height + margin
        ) return;

        const dot = document.createElement('div');
        dot.className = 'waypoint';
        dot.style.left = `${screenX}px`;
        dot.style.top = `${screenY}px`;

        const label = document.createElement('div');
        label.className = 'waypoint-label';
        label.textContent = wp.name;

        dot.appendChild(label);
        waypointsLayer.appendChild(dot);
      });
    };
    renderWaypoints();
    container.addEventListener('mousedown', (e) => {
      isPanning = true;
      lastX = e.clientX;
      lastY = e.clientY;
      e.preventDefault();
    });

    window.addEventListener('mousemove', (e) => {
      if (!isPanning) return;
      const dx = e.clientX - lastX;
      const dy = e.clientY - lastY;
      translateX += dx;
      translateY += dy;
      lastX = e.clientX;
      lastY = e.clientY;
      drawGrid();
      renderWaypoints();
    });

    window.addEventListener('mouseup', () => {
      isPanning = false;
    });
  })


</script>

<style scoped>
main {
  display: flex;
  justify-content: center;
  align-items: center;
}

#grid-canvas {
  display: block;
  background: white;
}

#waypoints {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none; /* So canvas gets pan events */
}

.waypoint {
  position: absolute;
  width: 14px;
  height: 14px;
  background: #d32f2f;
  border: 2px solid white;
  border-radius: 50%;
  transform: translate(-50%, -50%);
  pointer-events: auto; /* Allow interaction if needed */
}

.waypoint-label {
  position: absolute;
  top: 18px;
  left: 50%;
  transform: translateX(-50%);
  font-size: 12px;
  font-weight: bold;
  color: #1976d2;
  white-space: nowrap;
  text-shadow: 1px 1px 2px white;
}
</style>