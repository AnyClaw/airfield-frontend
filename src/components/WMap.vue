<template>
  <main class="map-container">
    <div id="grid-container" ref="gridContainer">
      <canvas id="grid-canvas" ref="gridCanvas"></canvas>
      
      <!-- SVG для маршрутов -->
      <svg id="routes-svg" ref="routesSvg">
        <!-- Маршруты -->
        <line
            v-for="route in computedRoutes"
            :key="route.id"
            :x1="route.x1 + translateX"
            :y1="route.y1 + translateY"
            :x2="route.x2 + translateX"
            :y2="route.y2 + translateY"
            stroke="#1976d2"
            stroke-width="2"
        />
      </svg>
      
      <div id="waypoints" ref="waypointsRef">
        <div
            v-for="wp in WAYPOINTS"
            :key="wp.id"
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
import {ref, onMounted, reactive, computed, defineProps} from 'vue'

// Определяем входные параметры
const props = defineProps({
  // Старый формат: массив { fromId, toId }
  routes: {
    type: Array,
    default: () => []
  },
  // Новый формат: массив ваших объектов
  routeData: {
    type: Array,
    default: () => []
  },
  height: {
    type: String,
    default: '70vh'
  }
})

const translateX = ref(0)
const translateY = ref(0)
const gridContainer = ref(null)
const gridCanvas = ref(null)
const waypointsRef = ref(null)
const routesSvg = ref(null)

// Точки с координатами (можно также сделать параметром)
const WAYPOINTS = reactive([
    { id: 1, name: "VORON", x: 100.0, y: 150.0 },
    { id: 2, name: "ROSTA", x: 180.0, y: 200.0 },
    { id: 3, name: "BELKA", x: 250.0, y: 300.0 },
    { id: 4, name: "STREL", x: 350.0, y: 400.0 },
    { id: 5, name: "VETKA", x: 450.0, y: 350.0 },
    { id: 6, name: "KEDR", x: 300.0, y: 200.0 },
    { id: 7, name: "BUKET", x: 400.0, y: 250.0 },
    { id: 8, name: "OMEGA", x: 500.0, y: 300.0 },
    { id: 9, name: "ALPHA", x: 150.0, y: 400.0 },
    { id: 10, name: "BRAVO", x: 280.0, y: 450.0 },
    { id: 11, name: "CHARL", x: 420.0, y: 500.0 },
    { id: 12, name: "DELTA", x: 550.0, y: 450.0 },
    { id: 13, name: "ECHO", x: 600.0, y: 350.0 },
    { id: 14, name: "FOXT", x: 650.0, y: 250.0 },
    { id: 15, name: "GOLF", x: 200.0, y: 100.0 }
])

// Маршруты по умолчанию (если не переданы через props)
const defaultRoutes = [
    // Основные маршруты
    { fromId: 1, toId: 2 },
    { fromId: 1, toId: 15 },
    { fromId: 2, toId: 15 },
    { fromId: 2, toId: 3 },
    { fromId: 2, toId: 6 },
    { fromId: 3, toId: 9 },
    { fromId: 3, toId: 4 },
    { fromId: 9, toId: 10 },
    { fromId: 4, toId: 10 },
    { fromId: 4, toId: 11 },
    { fromId: 4, toId: 5 },
    { fromId: 11, toId: 12 },
    { fromId: 12, toId: 13 },
    { fromId: 13, toId: 5 },
    { fromId: 5, toId: 8 },
    { fromId: 5, toId: 7 },
    { fromId: 7, toId: 8 },
    { fromId: 7, toId: 6 },
    { fromId: 8, toId: 14 },
    
    // Обратные маршруты
    { fromId: 2, toId: 1 },
    { fromId: 15, toId: 1 },
    { fromId: 15, toId: 2 },
    { fromId: 3, toId: 2 },
    { fromId: 6, toId: 2 },
    { fromId: 9, toId: 3 },
    { fromId: 4, toId: 3 },
    { fromId: 10, toId: 9 },
    { fromId: 10, toId: 4 },
    { fromId: 11, toId: 4 },
    { fromId: 5, toId: 4 },
    { fromId: 12, toId: 11 },
    { fromId: 13, toId: 12 },
    { fromId: 5, toId: 13 },
    { fromId: 8, toId: 5 },
    { fromId: 7, toId: 5 },
    { fromId: 8, toId: 7 },
    { fromId: 6, toId: 7 },
    { fromId: 14, toId: 8 }
]

// Используем переданные маршруты или маршруты по умолчанию
const activeRoutes = computed(() => {
  return props.routes.length > 0 ? props.routes : defaultRoutes
})

// Вычисляемое свойство для маршрутов с координатами
const computedRoutes = computed(() => {
    // Если передан routeData (ваш формат)
    if (props.routeData.length > 0) {
        return props.routeData.map(route => {
            return {
                id: route.id,
                x1: route.fromWaypoint.x,
                y1: route.fromWaypoint.y,
                x2: route.toWaypoint.x,
                y2: route.toWaypoint.y,
                fromName: route.fromWaypoint.name,
                toName: route.toWaypoint.name,
                distance: route.distance
            }
        })
    }
    
    // Если передан routes (старый формат)
    if (props.routes.length > 0) {
        return props.routes.map(route => {
            const from = WAYPOINTS.find(w => w.id === route.fromId)
            const to = WAYPOINTS.find(w => w.id === route.toId)
            
            if (from && to) {
                return {
                    id: `${route.fromId}-${route.toId}`,
                    x1: from.x,
                    y1: from.y,
                    x2: to.x,
                    y2: to.y,
                    fromName: from.name,
                    toName: to.name
                }
            }
            return null
        }).filter(route => route !== null)
    }
    
    // Если ничего не передано, используем маршруты по умолчанию
    return defaultRoutes.map(route => {
        const from = WAYPOINTS.find(w => w.id === route.fromId)
        const to = WAYPOINTS.find(w => w.id === route.toId)
        
        if (from && to) {
            return {
                id: `${route.fromId}-${route.toId}`,
                x1: from.x,
                y1: from.y,
                x2: to.x,
                y2: to.y,
                fromName: from.name,
                toName: to.name
            }
        }
        return null
    }).filter(route => route !== null)
})

const canvasSize = reactive({ width: 512, height: 512 })

onMounted(() => {
    const CELL_SIZE = 50
    const container = gridContainer.value
    const canvas = gridCanvas.value
    const context2d = canvas.getContext('2d')
    const svg = routesSvg.value

    let isPanning = false
    let lastX, lastY

    function resizeCanvas() {
        canvasSize.width = canvas.width = container.clientWidth
        canvasSize.height = canvas.height = container.clientHeight
        
        if (svg) {
            svg.setAttribute('width', canvasSize.width)
            svg.setAttribute('height', canvasSize.height)
        }
        
        drawGrid()
    }

    window.addEventListener('resize', resizeCanvas)
    resizeCanvas()

    function drawGrid() {
        const w = canvasSize.width
        const h = canvasSize.height
        context2d.clearRect(0, 0, w, h)

        const offsetX = translateX.value % CELL_SIZE
        const offsetY = translateY.value % CELL_SIZE

        context2d.strokeStyle = '#f0f0f0'
        context2d.lineWidth = 1

        // Вертикальные линии
        for (let x = offsetX; x <= w; x += CELL_SIZE) {
            context2d.beginPath()
            context2d.moveTo(x, 0)
            context2d.lineTo(x, h)
            context2d.stroke()
        }

        // Горизонтальные линии
        for (let y = offsetY; y <= h; y += CELL_SIZE) {
            context2d.beginPath()
            context2d.moveTo(0, y)
            context2d.lineTo(w, y)
            context2d.stroke()
        }
        
        // Более темные линии каждые 5 клеток
        context2d.strokeStyle = '#ddd'
        context2d.lineWidth = 1.5
        
        for (let x = offsetX; x <= w; x += CELL_SIZE * 5) {
            context2d.beginPath()
            context2d.moveTo(x, 0)
            context2d.lineTo(x, h)
            context2d.stroke()
        }
        
        for (let y = offsetY; y <= h; y += CELL_SIZE * 5) {
            context2d.beginPath()
            context2d.moveTo(0, y)
            context2d.lineTo(w, y)
            context2d.stroke()
        }
    }

    container.addEventListener('mousedown', (e) => {
        isPanning = true
        lastX = e.clientX
        lastY = e.clientY
        e.preventDefault()
    })

    window.addEventListener('mousemove', (e) => {
        if (!isPanning) return
        const dx = e.clientX - lastX
        const dy = e.clientY - lastY
        translateX.value += dx
        translateY.value += dy
        lastX = e.clientX
        lastY = e.clientY
        drawGrid()
    })

    window.addEventListener('mouseup', () => {
        isPanning = false
    })
})
</script>

<style scoped>
.map-container {
  display: flex;
  justify-content: center;
  align-items: center;
  margin: 20px auto;
  padding: 10px;
  box-sizing: border-box;
  width: 90%;
  max-width: 1200px;
  height: v-bind(height); /* Используем переданную высоту */
}

#grid-container {
  position: relative;
  overflow: hidden;
  font-family: sans-serif;
  border-radius: 10px;
  width: 100%;
  height: 100%;
  border: 1px solid #ccc;
}

#grid-canvas {
  display: block;
  background: white;
  width: 100%;
  height: 100%;
}

#routes-svg {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: 1;
}

#waypoints {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: 2;
}

.waypoint {
  position: absolute;
  width: 14px;
  height: 14px;
  background: #d32f2f;
  border: 2px solid white;
  border-radius: 50%;
  transform: translate(-50%, -50%);
  pointer-events: auto;
  cursor: pointer;
  box-shadow: 0 2px 4px rgba(0,0,0,0.2);
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
  background: rgba(255, 255, 255, 0.8);
  padding: 2px 6px;
  border-radius: 3px;
  pointer-events: none;
}
</style>