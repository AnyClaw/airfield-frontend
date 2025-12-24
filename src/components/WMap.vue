<template>
  <main>
    <div id="grid-container" ref="gridContainer">
      <canvas id="grid-canvas" ref="gridCanvas"></canvas>
      <div id="waypoints" ref="waypointsRef">
        <div
            v-for="wp in visibleWaypoints"
            :key="wp.id || wp.name"
            class="waypoint"
            :style="{
              left: (wp.x + translateX) + 'px',
              top: (wp.y + translateY) + 'px'
            }"
        >
          <div class="waypoint-label">{{ wp.name }}</div>
        </div>
      </div>
    </div>
  </main>
</template>

<script setup>
import {ref, onMounted, onBeforeUnmount, reactive, computed} from 'vue'
  const translateX = ref(0)
  const translateY = ref(0)

  const gridContainer = ref(null)
  const gridCanvas = ref(null)
  const waypointsRef = ref(null)

  const WAYPOINTS = reactive([
    { name: "Start", x: 0, y: 0 },
    { name: "Alpha", x: 300, y: -200 },
    { name: "Beta", x: -400, y: 500 },
    { name: "Gamma", x: 800, y: 300 }
  ]);
  const canvasSize = reactive({ width: 512, height: 512 })
  const visibleWaypoints = computed(() => {
    const margin = 200
    const { width, height } = canvasSize
    const tx = translateX.value
    const ty = translateY.value

    return WAYPOINTS.filter(wp => {
      const screenX = wp.x + tx
      const screenY = wp.y + ty

      return !(
          screenX < -margin ||
          screenX > width + margin ||
          screenY < -margin ||
          screenY > height + margin
      )
    })
  })

  onMounted(() => {
    // Configuration
    const CELL_SIZE = 50;

    // DOM, but for Vue
    const container = gridContainer.value;
    const canvas = gridCanvas.value;
    const context2d = canvas.getContext('2d');

    let isPanning = false;
    let lastX, lastY;
    function resizeCanvas() {
      canvasSize.width = canvas.width = canvas.clientWidth;
      canvasSize.height = canvas.height = canvas.clientHeight;
      drawGrid()
    }
    window.addEventListener('resize', resizeCanvas);
    resizeCanvas(); // Call once on load

    function drawGrid() {
      const w = canvasSize.width;
      const h = canvasSize.height;
      context2d.clearRect(0, 0, w, h);

      // Offset so lines move with pan
      const offsetX = translateX.value % CELL_SIZE;
      const offsetY = translateY.value % CELL_SIZE;

      context2d.strokeStyle = '#ddd';
      context2d.lineWidth = 1;

      // Vertical lines
      for (let x = offsetX; x <= w; x += CELL_SIZE) {
        context2d.beginPath();
        context2d.moveTo(x, 0);
        context2d.lineTo(x, h);
        context2d.stroke();
      }

      // Horizontal lines
      for (let y = offsetY; y <= h; y += CELL_SIZE) {
        context2d.beginPath();
        context2d.moveTo(0, y);
        context2d.lineTo(w, y);
        context2d.stroke();
      }
    }
    drawGrid();
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
      translateX.value += dx;
      translateY.value += dy;
      lastX = e.clientX;
      lastY = e.clientY;
      drawGrid();
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
  margin: 0;
  padding: 10px;
  box-sizing: border-box;
  width: auto;
  height: 100vh;
}

#grid-container {
  position: relative;
  overflow: hidden;
  font-family: sans-serif;
  border-radius: 20px;
  width: 100%;
  height: 100%;
}

#grid-canvas {
  display: block;
  background: white;
  width: 100%;
  height: 100%;
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